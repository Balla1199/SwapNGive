import 'package:flutter/material.dart';
import 'package:swapngive/models/Message.dart';
import 'package:swapngive/models/Conversation.dart';
import 'package:swapngive/services/message_service.dart';
import 'package:swapngive/services/conversation_service.dart';
import 'package:swapngive/widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String annonceId; // ID de l'annonce (échange ou don)
  final String typeAnnonce; // Type de l'annonce (échange ou don)
  final String senderId; // ID de l'expéditeur
  final String receiverId; // ID du destinataire
  final String conversationId;

  ChatScreen({
    required this.annonceId,
    required this.typeAnnonce,
    required this.senderId,
    required this.receiverId,
    required this.conversationId,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final MessageService _messageService = MessageService();
  final ConversationService _conversationService = ConversationService();

  String? conversationId; // ID de la conversation (champ optionnel)

  @override
  void initState() {
    super.initState();
    _createConversation(); // Créer la conversation lors de l'initialisation
  }

  Future<void> _createConversation() async {
  // Créez ou récupérez la conversation associée
  final conversation = Conversation(
    id: '', // L'ID sera généré par Firestore
    annonceId: widget.annonceId,
    typeAnnonce: widget.typeAnnonce,
    senderId: widget.senderId, // Utiliser senderId
    receiverId: widget.receiverId, // Utiliser receiverId
    lastMessage: '', // Initialement vide
    lastMessageTimestamp: DateTime.now(), // Timestamp actuel
    hasUnreadMessages: false, // Valeur par défaut
  );

  // Sauvegardez la conversation dans Firestore et obtenez son ID
  final newConversationId = await _conversationService.createOrUpdateConversation(conversation);
  setState(() {
    conversationId = newConversationId; // Assignation de l'ID de la conversation
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messageService.getMessages(widget.annonceId, widget.typeAnnonce),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Aucun message'));
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true, // Pour afficher les derniers messages en bas
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == widget.senderId;
                    return MessageBubble(message: message, isMe: isMe);
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Écrire un message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    // Vérifiez si le message est vide ou si conversationId n'est pas encore initialisé
    if (_messageController.text.trim().isEmpty || conversationId == null) return;

    final message = Message(
      id: '', // ID sera généré par Firestore
      conversationId: conversationId!, // Utilisez l'ID de la conversation
      annonceId: widget.annonceId,
      typeAnnonce: widget.typeAnnonce,
      senderId: widget.senderId,
      receiverId: widget.receiverId,
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    // Envoyer le message
    await _messageService.sendMessage(message);
// Mettre à jour la conversation avec le dernier message
final updatedConversation = Conversation(
  id: conversationId!, // Utilisez l'ID de la conversation existante
  annonceId: widget.annonceId,
  typeAnnonce: widget.typeAnnonce,
  senderId: widget.senderId, // Utiliser l'ID de l'expéditeur
  receiverId: widget.receiverId, // Utiliser l'ID du destinataire
  lastMessage: message.content, // Dernier message envoyé
  lastMessageTimestamp: DateTime.now(), // Timestamp actuel
  hasUnreadMessages: true, // Optionnel : définissez si nécessaire
);


    // Créer ou mettre à jour la conversation dans Firestore
    await _conversationService.createOrUpdateConversation(updatedConversation);

    // Réinitialiser l'input
    _messageController.clear();
  }
}
