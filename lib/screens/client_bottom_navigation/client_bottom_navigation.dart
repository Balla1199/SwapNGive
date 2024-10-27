import 'package:flutter/material.dart'; 
import 'package:swapngive/services/conversation_service.dart';

class ClientBottomNavigationBar extends StatelessWidget {
  final List<Widget> screens;
  final int selectedIndex;
  final Function(int) onItemTapped;
  final int unreadNotificationCount; // Compteur de notifications non lues
  final String currentUserId; // ID de l'utilisateur actuel
  
  ClientBottomNavigationBar({
    required this.screens,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.unreadNotificationCount,
    required this.currentUserId,
  });

  final ConversationService _conversationService = ConversationService();

  void _handleInboxTap() async {
    // Marquer toutes les conversations comme lues
    List<String> conversationIds = await _conversationService.getUnreadConversationIds(currentUserId);
    for (String conversationId in conversationIds) {
      await _conversationService.marquerCommeLue(conversationId);
    }
    print('Toutes les conversations marquées comme lues pour l\'utilisateur: $currentUserId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Annonces',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer),
            label: 'Objets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'Réception',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                // Icône de notification en arrière-plan
                Icon(Icons.notifications),
                // Affichage conditionnel du badge de notification
                if (unreadNotificationCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2), // Réduire le padding
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14, // Réduire la largeur minimale
                        minHeight: 14, // Réduire la hauteur minimale
                      ),
                      child: Text(
                        '$unreadNotificationCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10, // Réduire la taille de la police
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Color(0xFF9B9B9B),
        backgroundColor: Colors.black,
        onTap: (index) {
          if (index == 2) { // Si l'icône de réception est cliquée
            _handleInboxTap();
          }
          onItemTapped(index); // Appeler la fonction onItemTapped
        },
      ),
    );
  }
}
