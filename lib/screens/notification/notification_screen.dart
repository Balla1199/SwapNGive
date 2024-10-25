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
  bool _isLoading = true;
  int _unreadCount = 0; // Compteur de notifications non lues

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final currentUser = await _authService.getCurrentUserDetails();
    
    if (currentUser != null) {
      final notifications = await _notificationService.getNotificationsForUserWithSenderName(currentUser.id);

      // Marquer les notifications non lues comme lues
      for (var notification in notifications) {
        if (!notification.isRead) {
          await _notificationService.marquerCommeLue(notification.id);
        }
      }

      setState(() {
        _notifications = notifications..sort((a, b) => b.date.compareTo(a.date));
        _unreadCount = _notifications.where((notification) => !notification.isRead).length;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
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
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(right: 8.0),
              child: Image.asset(
                'assets/images/logosansnom.jpg',
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Text(
                'Notifications',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Afficher le badge de notifications non lues
            Stack(
              children: [
                Icon(Icons.notifications, color: Colors.black),
                if (_unreadCount > 0)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_unreadCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  final bool isNew = !notification.isRead;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Container(
                      width: 300,
                      height: 180,
                      child: Card(
                        color: isNew ? Color.fromARGB(211, 217, 169, 169) : Color.fromARGB(255, 116, 114, 114),
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
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
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (isNew)
                                    Icon(Icons.circle, color: Colors.red, size: 12),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                notification.message,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.white),
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
