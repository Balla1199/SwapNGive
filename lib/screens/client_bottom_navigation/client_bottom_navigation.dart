import 'package:flutter/material.dart';

class ClientBottomNavigationBar extends StatelessWidget {
  final List<Widget> screens;
  final int selectedIndex;
  final Function(int) onItemTapped;

  ClientBottomNavigationBar({
    required this.screens,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Enlever l'AppBar ici pour ne pas avoir de titre ou de bouton retour
      body: screens[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history), // Icone pour l'historique
            label: 'Historique',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        onTap: onItemTapped,
      ),
    );
  }
}
