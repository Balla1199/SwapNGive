import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Notification.dart';
import 'package:swapngive/services/utilisateur_service.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UtilisateurService _utilisateurService = UtilisateurService();

  // Enregistrer une notification dans Firebase
  Future<void> enregistrerNotification(NotificationModel notification) async {
    await _firestore.collection('notifications').doc(notification.id).set(notification.toMap());
  }

  // Supprimer une notification
  Future<void> supprimerNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  // Récupérer les notifications pour un utilisateur, avec les noms des utilisateurs qui font des propositions
  Future<List<NotificationModel>> getNotificationsForUser(String userId) async {
    final querySnapshot = await _firestore.collection('notifications')
        .where('toUserId', isEqualTo: userId).get();
    
    final notifications = querySnapshot.docs.map((doc) => NotificationModel.fromMap(doc.data())).toList();

    // Ajouter le nom de l'utilisateur qui fait la proposition
    for (var notification in notifications) {
      final userPropose = await _utilisateurService.getUtilisateurById(notification.fromUserId);
      notification.titre = '${userPropose?.nom} vous a fait une proposition d\'échange';
    }

    return notifications;
  }
  
  // Méthode pour récupérer le nom de l'utilisateur à partir de son ID
  Future<String?> getUserNameById(String userId) async {
    try {
      print('Récupération du nom de l\'utilisateur pour l\'ID : $userId');
      DocumentSnapshot doc = await _firestore.collection('utilisateurs').doc(userId).get();
      
      if (doc.exists) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        String userName = userData['nom'] ?? 'Utilisateur inconnu';
        return userName;
      } else {
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération du nom de l\'utilisateur : $e');
      return null;
    }
  }

  // Méthode pour récupérer les notifications avec le nom de l'expéditeur
  Future<List<NotificationModel>> getNotificationsForUserWithSenderName(String userId) async {
    print("Récupération des notifications pour l'utilisateur : $userId");

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('notifications')
          .where('toUserId', isEqualTo: userId)
          .get();

      print("Nombre de notifications trouvées : ${snapshot.docs.length}");

      List<NotificationModel> notifications = [];

      for (var doc in snapshot.docs) {
        Map<String, dynamic> notificationData = doc.data() as Map<String, dynamic>;
        
        // Récupérer le nom de l'expéditeur (fromUserId)
        String? fromUserName = await getUserNameById(notificationData['fromUserId']);
        
        print("Notification trouvée de $fromUserName : ${doc.data()}");

        // Ajouter le nom de l'expéditeur au message ou à un autre champ si nécessaire
        notifications.add(NotificationModel(
          id: notificationData['id'],
          fromUserId: notificationData['fromUserId'],
          toUserId: notificationData['toUserId'],
          titre: notificationData['titre'],
          message: fromUserName != null
              ? "${fromUserName}${notificationData['message']}"
              : notificationData['message'],
          date: DateTime.parse(notificationData['date']),
          isRead: notificationData['isRead'] ?? false,
        ));
      }

      return notifications;
    } catch (e) {
      print("Erreur lors de la récupération des notifications : $e");
      return [];
    }
  }
 // Marquer une notification comme lue
Future<void> marquerCommeLue(String notificationId) async {
  await _firestore.collection('notifications').doc(notificationId).update({
    'isRead': true,
  });
}

}
