import 'package:flutter/material.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/screens/etat/etat_list_screen.dart';
import 'package:swapngive/screens/profil/profile_screen.dart';
import 'package:swapngive/screens/categorie/categorie_list_screen.dart';
import 'package:swapngive/screens/utilisateur/utilisateur_list_screen.dart';
import 'package:swapngive/screens/objet/objet_list_screen.dart'; // Import de l'écran de liste d'objets

class HomeScreen extends StatefulWidget {
  final Utilisateur? utilisateur;

  HomeScreen({this.utilisateur}) {
    print('Constructeur HomeScreen : Utilisateur = ${utilisateur?.email}');
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    print('Utilisateur connecté dans HomeScreen : ${widget.utilisateur?.email}');

    _screens = [
      Center(child: Text('Home Screen Content')),
      UtilisateurListScreen(),
      CategorieListScreen(),
      EtatListScreen(),
      ObjetListScreen(), // Ajout de l'écran de liste d'objets
      if (widget.utilisateur != null)
        ProfileScreen(utilisateur: widget.utilisateur),
    ];

    print('Liste des écrans configurés : ${_screens.map((e) => e.runtimeType).toList()}');
  }

  void _onItemTapped(int index) {
    print('Item tap index : $index');

    if (index == 5 && widget.utilisateur == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aucun utilisateur connecté')),
      );
      print('Erreur : Aucun utilisateur connecté');
    } else {
      setState(() {
        _selectedIndex = index;
        print('Index sélectionné : $_selectedIndex');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Construction du widget HomeScreen...');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: _screens.length > _selectedIndex
          ? _screens[_selectedIndex]
          : Center(child: Text('Aucun contenu disponible')),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
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
            icon: Icon(Icons.local_offer), // Icône pour les objets
            label: 'Objets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
