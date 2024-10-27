import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Conversation.dart';

class ConversationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour obtenir toutes les conversations d'un utilisateur
  Stream<List<Conversation>> getConversations(String userId) async* {
    try {
      print('Recherche des conversations pour l\'utilisateur: $userId');

      // Récupérer les conversations où l'utilisateur est soit le receveur soit l'expéditeur
      QuerySnapshot<Map<String, dynamic>> conversationSnapshot = await _firestore
          .collection('conversations')
          .where('receiverId', isEqualTo: userId)
          .get();

      QuerySnapshot<Map<String, dynamic>> senderSnapshot = await _firestore
          .collection('conversations')
          .where('senderId', isEqualTo: userId)
          .get();

      // Combinez les deux résultats
      List<QueryDocumentSnapshot<Map<String, dynamic>>> allConversations = [
        ...conversationSnapshot.docs,
        ...senderSnapshot.docs
      ];

      // Vérifiez si des conversations ont été trouvées
      if (allConversations.isEmpty) {
        print('Aucune conversation trouvée pour l\'utilisateur: $userId');
        yield []; // Retournez une liste vide si aucune conversation n'est trouvée
      } else {
        print('Conversations trouvées pour l\'utilisateur: ${allConversations.length}');

        // Créer la liste des conversations
        List<Conversation> conversationList = allConversations.map((doc) {
          print('Conversation trouvée: ${doc.id}');
          return Conversation.fromMap(doc.id, doc.data()!);
        }).toList();

        print('Nombre total de conversations trouvées: ${conversationList.length}');
        yield conversationList; // Retournez la liste des conversations
      }
    } catch (e) {
      print('Erreur lors de la récupération des conversations: $e');
      throw e; // Lancez l'erreur pour la gestion des exceptions
    }
  }

  // Méthode pour obtenir les conversations non lues d'un utilisateur
  Future<List<Conversation>> getUnreadConversations(String userId) async {
    try {
      print('Recherche des conversations non lues pour l\'utilisateur: $userId');

      QuerySnapshot<Map<String, dynamic>> conversationSnapshot = await _firestore
          .collection('conversations')
          .where('hasUnreadMessages', isEqualTo: true)
          .where('receiverId', isEqualTo: userId)
          .get();

      List<Conversation> unreadConversations = conversationSnapshot.docs.map((doc) {
        return Conversation.fromMap(doc.id, doc.data()!);
      }).toList();

      print('Nombre de conversations non lues trouvées: ${unreadConversations.length}');
      return unreadConversations;
    } catch (e) {
      print('Erreur lors de la récupération des conversations non lues: $e');
      throw e;
    }
  }

  // Mettre à jour le dernier message d'une conversation
  Future<void> updateLastMessage(String conversationId, String lastMessage) async {
    await _firestore.collection('conversations').doc(conversationId).update({
      'lastMessage': lastMessage,
      'lastMessageTimestamp': DateTime.now(),
    });
  }

  // Créer ou mettre à jour une conversation et renvoyer son ID
  Future<String> createOrUpdateConversation(Conversation conversation) async {
    // Vérifiez si l'ID de la conversation est vide
    if (conversation.id.isNotEmpty) {
      print('ID de la conversation à vérifier : ${conversation.id}');
      // Référence à la conversation
      final conversationRef = _firestore.collection('conversations').doc(conversation.id);
      // Obtenez le snapshot de la conversation
      final snapshot = await conversationRef.get();

      if (snapshot.exists) {
        // Si la conversation existe, mettez à jour le dernier message
        print('Conversation existante trouvée : ${conversation.id}');
        await updateLastMessage(conversation.id, conversation.lastMessage);
        return conversation.id; // Retournez l'ID de la conversation existante
      } 
    }

    // Sinon, créez une nouvelle conversation
    print('Création d\'une nouvelle conversation.');

    // Vérifiez les données de la conversation avant de les envoyer
    print('Données de la conversation : ${conversation.toMap()}');

    // Créez une nouvelle référence de document pour obtenir un ID
    DocumentReference docRef = _firestore.collection('conversations').doc();
    conversation.id = docRef.id; // Mettez à jour l'ID de la conversation

    // Enregistrez la conversation
    await docRef.set(conversation.toMap());

    // Vérifiez que l'ID du document est bien généré
    if (docRef.id.isNotEmpty) {
      print('Nouvelle conversation créée avec l\'ID : ${docRef.id}');
    } else {
      print('Erreur : L\'ID de la nouvelle conversation est vide.');
    }

    return docRef.id; // Retournez l'ID de la nouvelle conversation
  }

  // Méthode pour marquer une conversation comme lue
  Future<void> marquerCommeLue(String conversationId) async {
    await _firestore.collection('conversations').doc(conversationId).update({
      'hasUnreadMessages': false,
    });
  }

// Méthode pour récupérer les identifiants des conversations non lues
Future<List<String>> getUnreadConversationIds(String userId) async {
  try {
    List<String> unreadConversationIds = [];

    // Récupérer les conversations où l'utilisateur est le receveur
    QuerySnapshot<Map<String, dynamic>> conversationSnapshot = await _firestore
        .collection('conversations')
        .where('receiverId', isEqualTo: userId)
        .where('hasUnreadMessages', isEqualTo: true) // Vérifier si des messages sont non lus
        .get();

    // Récupérer les conversations où l'utilisateur est l'expéditeur
    QuerySnapshot<Map<String, dynamic>> senderSnapshot = await _firestore
        .collection('conversations')
        .where('senderId', isEqualTo: userId)
        .where('hasUnreadMessages', isEqualTo: true) // Vérifier si des messages sont non lus
        .get();

    // Rassembler tous les IDs des conversations non lues
    for (var doc in conversationSnapshot.docs) {
      unreadConversationIds.add(doc.id);
    }

    for (var doc in senderSnapshot.docs) {
      unreadConversationIds.add(doc.id);
    }

    return unreadConversationIds; // Retourner la liste des IDs
  } catch (e) {
    print('Erreur lors de la récupération des conversations non lues: $e');
    throw e;
  }
}
}
