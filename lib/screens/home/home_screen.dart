import 'package:flutter/material.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/screens/client_bottom_navigation/client_bottom_navigation.dart';
import 'package:swapngive/screens/dashbord/Dashboard_Screen.dart';
import 'package:swapngive/screens/sidebar_layout/sidebar_layout.dart';
import 'package:swapngive/screens/utilisateur/utilisateur_list_screen.dart';
import 'package:swapngive/screens/categorie/categorie_list_screen.dart';
import 'package:swapngive/screens/etat/etat_list_screen.dart';
import 'package:swapngive/screens/profil/profile_screen.dart';
import 'package:swapngive/screens/annonce/annonce_list_screen.dart';
import 'package:swapngive/screens/objet/objet_list_screen.dart';
import 'package:swapngive/screens/reception/reception_screen.dart';
import 'package:swapngive/screens/notification/notification_screen.dart';


class HomeScreen extends StatefulWidget {
  final Utilisateur? utilisateur;

  HomeScreen({this.utilisateur});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> _adminScreens = [];
  List<Widget> _clientScreens = [];

  @override
  void initState() {
    super.initState();

    // Vérifiez si 'utilisateur' n'est pas null
    String? utilisateurId = widget.utilisateur?.id;

    if (utilisateurId == null) {
      // Gérer le cas où l'utilisateur n'est pas connecté ou n'a pas d'ID
      // Vous pourriez naviguer vers une page de connexion ici
      return;
    }

  _adminScreens = [
  DashboardScreen(),
  UtilisateurListScreen(),
  CategorieListScreen(),
  EtatListScreen(),
  ProfileScreen(
    utilisateurId: utilisateurId, 
    utilisateur: widget.utilisateur,
    isDifferentUser: false, // Ajoutez isDifferentUser ici, à ajuster selon votre logique
  ),
];

   _clientScreens = [
  AnnonceListScreen(),
  ObjetListScreen(),
  ReceptionScreen(),
  NotificationScreen(),
  ProfileScreen(
    utilisateurId: utilisateurId, 
    utilisateur: widget.utilisateur,
    isDifferentUser: false, // Ajoutez isDifferentUser ici, à ajuster selon votre logique
  ),
];


    // Imprimer la longueur des listes pour le débogage
    print('Longueur des écrans admin: ${_adminScreens.length}');
    print('Longueur des écrans client: ${_clientScreens.length}');

    // Vérifiez que les listes contiennent des éléments avant de les utiliser
    if (_clientScreens.isEmpty) {
      print('Aucun écran client disponible.'); // Message d'erreur
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Vérifier si l'utilisateur est admin
    bool isAdmin = widget.utilisateur?.role == Role.admin;

    if (isAdmin) {
      // Vue admin avec sidebar
      return SidebarLayout(
        screens: _adminScreens,
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      );
    } else {
      // Client view avec bottom navigation bar
      if (_clientScreens.isNotEmpty) {
        return ClientBottomNavigationBar(
          screens: _clientScreens,
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        );
      } else {
        // Gérer le cas où la liste est vide
        return Scaffold(
          appBar: AppBar(title: Text('Erreur')),
          body: Center(child: Text('Aucun écran client disponible.')),
        );
      }
    }
  }
}
