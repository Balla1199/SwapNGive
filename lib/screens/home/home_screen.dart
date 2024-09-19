import 'package:flutter/material.dart';
import 'package:swapngive/screens/etat/etat_list_screen.dart';
import 'package:swapngive/screens/utilisateur/user_list_screen.dart';
import 'package:swapngive/screens/categorie/categorie_list_screen.dart'; // Import de la page des catégorie
import 'package:swapngive/screens/objet/objet_list_screen.dart'; // Import de la page des objets

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Center(child: Text('Home Screen Content')), // L'écran d'accueil réel
    UserListScreen(), // Écran pour la liste des utilisateurs
    CategorieListScreen(), // Écran pour la liste des catégories
    EtatListScreen(), // Écran pour la liste des états
    ObjetListScreen(), // Écran pour la liste des objets
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: _screens[_selectedIndex], // Affichez l'écran correspondant à l'index sélectionné
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Etats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Objets',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,  // Color for the selected item
        unselectedItemColor: Colors.black, // Color for the unselected items
        onTap: _onItemTapped,
      ),
    );
  }
}
