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
    // Récupérer l'utilisateur actuel
    final currentUser = await _authService.getCurrentUserDetails();
    
    if (currentUser != null) {
      // Charger les notifications de l'utilisateur actuel avec le nom de l'expéditeur
      final notifications = await _notificationService.getNotificationsForUserWithSenderName(currentUser.id);
      setState(() {
        _notifications = notifications;
      });
    } else {
      // Gérer le cas où aucun utilisateur n'est connecté
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
        title: Text('Notifications'),
      ),
      body: ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return ListTile(
            title: Text(notification.titre),
            subtitle: Text(notification.message),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteNotification(notification.id),
            ),
          );
        },
      ),
    );
  }
}
