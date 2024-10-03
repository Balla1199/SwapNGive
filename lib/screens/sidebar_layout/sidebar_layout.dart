import 'package:flutter/material.dart';

class SidebarLayout extends StatelessWidget {
  final List<Widget> screens;
  final int selectedIndex;
  final Function(int) onItemTapped;

  SidebarLayout({
    required this.screens,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          // Sidebar menu
          Container(
            width: 250, // Set the width of the sidebar
            color: Colors.blueGrey[800], // Sidebar background color
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.blue, // Header background color
                  width: double.infinity,
                  child: Text(
                    'Admin Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  selected: selectedIndex == 0,
                  title: Text(
                    'Users',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    onItemTapped(0); // Navigates to UtilisateurListScreen
                  },
                ),
                ListTile(
                  selected: selectedIndex == 1,
                  title: Text(
                    'Categories',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    onItemTapped(1); // Navigates to CategorieListScreen
                  },
                ),
                ListTile(
                  selected: selectedIndex == 2,
                  title: Text(
                    'Etats',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    onItemTapped(2); // Navigates to EtatListScreen
                  },
                ),
                ListTile(
                  selected: selectedIndex == 3,
                  title: Text(
                    'Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    onItemTapped(3); // Navigates to ProfileScreen
                  },
                ),
              ],
            ),
          ),

          // Main content area
          Expanded(
            child: screens[selectedIndex], // Affiche la section sélectionnée sans boutons de retour
          ),
        ],
      ),
    );
  }
}
