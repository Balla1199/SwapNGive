import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Message.dart';
import 'package:swapngive/models/Conversation.dart';
import 'package:swapngive/services/conversation_service.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ConversationService _conversationService = ConversationService(); // Instance of ConversationService

  // Envoi d'un message
  Future<void> sendMessage(Message message) async {
    try {
      // Le chemin dépendra du type d'annonce (échange ou don)
      String collectionPath = message.typeAnnonce == "echange"
          ? "echange"
          : "don";

      // Envoyer le message dans Firestore
      await _firestore
          .collection(collectionPath)
          .doc(message.annonceId)
          .collection('messages')
          .add(message.toMap());

      // Vérifier si une conversation existe déjà pour cet utilisateur et l'annonce
      QuerySnapshot conversationSnapshot = await _firestore
          .collection('conversations')
          .where('participants', arrayContains: message.senderId)
          .where('annonceId', isEqualTo: message.annonceId)
          .limit(1)
          .get();

      if (conversationSnapshot.docs.isEmpty) {
        // Créer une nouvelle conversation si elle n'existe pas
        DocumentReference docRef = await _firestore.collection('conversations').add({
          'annonceId': message.annonceId,
          'typeAnnonce': message.typeAnnonce,
          'participants': [message.senderId, message.receiverId],
          'lastMessage': message.content,
          'lastMessageTimestamp': DateTime.now(),
        });
// Créer un nouvel objet Conversation avec l'ID généré par Firestore
Conversation newConversation = Conversation(
  id: docRef.id, // Utiliser l'ID généré par Firestore
  annonceId: message.annonceId,
  typeAnnonce: message.typeAnnonce,
  senderId: message.senderId, // Remplacer participants par senderId
  receiverId: message.receiverId, // Ajouter receiverId
  lastMessage: message.content,
  lastMessageTimestamp: DateTime.now(),
);


        // Appel de la méthode createOrUpdateConversation
        await _conversationService.createOrUpdateConversation(newConversation);
        print('Nouvelle conversation créée et enregistrée.');
      } else {
        // Mettre à jour le dernier message de la conversation existante
        String conversationId = conversationSnapshot.docs.first.id;
        await _conversationService.updateLastMessage(conversationId, message.content);
        print('Dernier message de la conversation mise à jour.');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
    }
  }

  // Récupérer les messages d'une annonce spécifique
  Stream<List<Message>> getMessages(String annonceId, String typeAnnonce) {
    String collectionPath = typeAnnonce == "echange"
        ? "echange"
        : "don";

    return _firestore
        .collection(collectionPath)
        .doc(annonceId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }
}
