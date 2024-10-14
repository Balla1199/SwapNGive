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
      });
    } else {
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
        automaticallyImplyLeading: false,
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Card(
              color: Color(0xFFD9A9A9), // Couleur de fond de la carte
              elevation: 5, // Ombre pour un effet 3D
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // Bords arrondis
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.titre,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Couleur du texte
                      ),
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
          );
        },
      ),
    );
  }
}
