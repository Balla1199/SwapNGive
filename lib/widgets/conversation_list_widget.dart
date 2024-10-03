import 'package:flutter/material.dart';
import 'package:swapngive/models/Conversation.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/screens/chat/chatscreen.dart';
import 'package:swapngive/services/conversation_service.dart';
import 'package:swapngive/services/utilisateur_service.dart';
import 'package:intl/intl.dart'; 


class ConversationListWidget extends StatelessWidget {
  final String userId;

  const ConversationListWidget({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Conversation>>(
      stream: ConversationService().getConversations(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('Aucune conversation trouvée.'),
          );
        }

        final conversations = snapshot.data!;

        // Utiliser un Set pour stocker les conversations uniques par annonce et participants
        final Set<String> uniqueConversationsKeys = {};
        final List<Conversation> uniqueConversations = conversations.where((conversation) {
          // Générer une clé unique pour chaque combinaison d'annonce et de participants
          final participantsKey = conversation.annonceId +
              '-' +
              (conversation.senderId.compareTo(conversation.receiverId) < 0
                  ? '${conversation.senderId}-${conversation.receiverId}'
                  : '${conversation.receiverId}-${conversation.senderId}');

          final isUnique = !uniqueConversationsKeys.contains(participantsKey);
          if (isUnique) {
            uniqueConversationsKeys.add(participantsKey);
          }
          return isUnique;
        }).toList();

        return ListView.builder(
          padding: EdgeInsets.all(8.0),
          itemCount: uniqueConversations.length,
          itemBuilder: (context, index) {
            final conversation = uniqueConversations[index];
            final otherUserId = conversation.senderId == userId
                ? conversation.receiverId
                : conversation.senderId;

            return FutureBuilder<Utilisateur?>(
              future: UtilisateurService().getUtilisateurById(otherUserId),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(
                    title: Text('Chargement...'),
                    subtitle: Text('Chargement du message...'),
                  );
                }

                String otherUserName = userSnapshot.data?.nom ?? 'Utilisateur inconnu';
                String formattedTime = DateFormat('HH:mm').format(conversation.lastMessageTimestamp);

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    otherUserName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    conversation.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // Limite le texte à une seule ligne avec "..." si trop long
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formattedTime, // Heure du dernier message
                        style: TextStyle(color: Colors.grey, fontSize: 12.0),
                      ),
                      SizedBox(height: 4),
                      if (conversation.hasUnreadMessages)
                        Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green, // Cercle vert pour indiquer un nouveau message
                          ),
                          child: Text(
                            '1', // Peut être modifié pour afficher le nombre de messages non lus
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.0,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          annonceId: conversation.annonceId,
                          typeAnnonce: conversation.typeAnnonce,
                          conversationId: conversation.id,
                          senderId: userId,
                          receiverId: otherUserId,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}