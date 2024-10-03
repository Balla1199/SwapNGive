import 'package:flutter/material.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/screens/client_bottom_navigation/client_bottom_navigation.dart';
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

    // Admin Screens for Sidebar
    _adminScreens = [
      UtilisateurListScreen(),
      CategorieListScreen(),
      EtatListScreen(),
      ProfileScreen(utilisateur: widget.utilisateur),
    ];

    // Client Screens for BottomNavigationBar
    _clientScreens = [
      AnnonceListScreen(),
      ObjetListScreen(),
      ReceptionScreen(),
      NotificationScreen(),
      ProfileScreen(utilisateur: widget.utilisateur),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the user's role is admin
    bool isAdmin = widget.utilisateur?.role == Role.admin;

    if (isAdmin) {
      // Admin view with sidebar
      return SidebarLayout(
        screens: _adminScreens,
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      );
    } else {
      // Client view with bottom navigation bar
      return ClientBottomNavigationBar(
        screens: _clientScreens,
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      );
    }
  }
}
