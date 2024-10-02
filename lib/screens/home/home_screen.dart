import 'package:flutter/material.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/screens/etat/etat_list_screen.dart';
import 'package:swapngive/screens/profil/profile_screen.dart';
import 'package:swapngive/screens/categorie/categorie_list_screen.dart';
import 'package:swapngive/screens/utilisateur/utilisateur_list_screen.dart';
import 'package:swapngive/screens/objet/objet_list_screen.dart';
import 'package:swapngive/screens/annonce/annonce_list_screen.dart';
import 'package:swapngive/screens/reception/reception_screen.dart';
import 'package:swapngive/screens/notification/notification_screen.dart'; 

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
      ObjetListScreen(),
      AnnonceListScreen(),
      ReceptionScreen(),
      NotificationScreen(), // Ajout de l'écran de notifications
      if (widget.utilisateur != null)
        ProfileScreen(utilisateur: widget.utilisateur),
    ];

    print('Liste des écrans configurés : ${_screens.map((e) => e.runtimeType).toList()}');
  }

  void _onItemTapped(int index) {
    print('Item tap index : $index');

    if (index == 8 && widget.utilisateur == null) {
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
        title: _selectedIndex == 0 ? const Text('Home Screen') : null,
        automaticallyImplyLeading: _selectedIndex == 0,
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
            icon: Icon(Icons.local_offer),
            label: 'Objets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.announcement),
            label: 'Annonces',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inbox),
            label: 'Réception',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications), // Icône pour les notifications
            label: 'Notifications',
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
