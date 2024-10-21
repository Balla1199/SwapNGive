import 'package:flutter/material.dart';
import 'package:swapngive/models/Notification.dart';
import 'package:swapngive/services/auth_service.dart';
import 'package:swapngive/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true; // Indicateur de chargement

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final currentUser = await _authService.getCurrentUserDetails();
    
    if (currentUser != null) {
      final notifications = await _notificationService.getNotificationsForUserWithSenderName(currentUser.id);
      setState(() {
        _notifications = notifications;
        _isLoading = false; // Chargement terminé
      });
    } else {
      setState(() {
        _isLoading = false; // Chargement terminé même en cas d'erreur
      });
      print('Aucun utilisateur connecté, impossible de charger les notifications.');
    }
  }

  Future<void> _deleteNotification(String notificationId) async {
    await _notificationService.supprimerNotification(notificationId);
    _loadNotifications();
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white, // Couleur de l'AppBar en blanc
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Centre le contenu de l'AppBar
        children: [
          // Logo aligné à gauche
          Container(
            margin: EdgeInsets.only(right: 8.0), // Espacement à droite du logo
            child: Image.asset(
              'assets/images/logosansnom.jpg', // Chemin vers votre logo
              height: 40, // Ajustez la hauteur du logo
              fit: BoxFit.contain, // Ajuste l'image pour garder ses proportions
            ),
          ),
          // Titre centré et en gras
          Expanded(
            child: Text(
              'Notifications',
              textAlign: TextAlign.center, // Centre le texte
              style: TextStyle(
                fontWeight: FontWeight.bold, // Texte en gras
              ),
            ),
          ),
        ],
      ),
    ),
    body: Container(
      color: Colors.white, // Couleur de fond de l'écran en blanc
      child: _isLoading
          ? Center(child: CircularProgressIndicator()) // Indicateur de chargement
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                final bool isNew = !notification.isRead; // Vérifier si la notification est non lue

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Container(
                    width: 300, // Spécifiez la largeur souhaitée
                    height: 180, // Spécifiez la hauteur souhaitée
                    child: Card(
                      color: isNew
                          ?Color.fromARGB(211, 217, 169, 169) // Couleur spéciale pour non lue
                          : Color.fromARGB(255, 116, 114, 114), // Couleur normale pour lue
                      elevation: 5, // Ombre pour un effet 3D
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0), // Bords arrondis
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  notification.titre,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // Couleur du texte
                                  ),
                                ),
                                if (isNew)
                                  Icon(Icons.circle, color: Colors.red, size: 12), // Indicateur pour non lue
                              ],
                            ),
                            SizedBox(height: 10),
                            Text(
                              notification.message,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white, // Couleur du texte
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: Icon(Icons.delete, color: Colors.white), // Bouton supprimer en blanc
                                onPressed: () => _deleteNotification(notification.id),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    ),
  );
}


}
