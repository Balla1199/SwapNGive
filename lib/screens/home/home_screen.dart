import 'package:flutter/material.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/screens/Historique/Historiquescreen.dart';
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
import 'package:swapngive/services/auth_service.dart';
import 'package:swapngive/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  final Utilisateur? utilisateur;

  HomeScreen({this.utilisateur});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _unreadCount = 0; // Compteur pour les notifications non lues

  List<Widget> _adminScreens = [];
  List<Widget> _clientScreens = [];
  final NotificationService _notificationService = NotificationService(); // Instancier NotificationService

  @override
  void initState() {
    super.initState();
    _loadUnreadNotificationCount(); // Charger les notifications non lues

    // Vérifiez si 'utilisateur' n'est pas null
    String? utilisateurId = widget.utilisateur?.id;

    if (utilisateurId == null) {
      // Gérer le cas où l'utilisateur n'est pas connecté ou n'a pas d'ID
      // Vous pourriez naviguer vers une page de connexion ici
      return;
    }

    // Configuration des écrans pour l'admin
    _adminScreens = [
      DashboardScreen(),
      UtilisateurListScreen(),
      CategorieListScreen(),
      EtatListScreen(),
      ProfileScreen(
        utilisateurId: utilisateurId,
        utilisateur: widget.utilisateur,
        isDifferentUser: false, // Ajuster selon la logique
      ),
    ];

    // Configuration des écrans pour le client
    _clientScreens = [
      AnnonceListScreen(),
      ObjetListScreen(),
      ReceptionScreen(),
      NotificationScreen(),
      HistoriqueScreen(),
      ProfileScreen(
        utilisateurId: utilisateurId,
        utilisateur: widget.utilisateur,
        isDifferentUser: false, // Ajuster selon la logique
      ),
    ];
  }

  Future<void> _loadUnreadNotificationCount() async {
    final currentUser = await AuthService().getCurrentUserDetails();
    if (currentUser != null) {
      final notifications = await _notificationService.getNotificationsForUserWithSenderName(currentUser.id);
      setState(() {
        _unreadCount = notifications.where((n) => !n.isRead).length;
      });
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
      // Vue client avec bottom navigation bar
      return _clientScreens.isNotEmpty
          ? ClientBottomNavigationBar(
              screens: _clientScreens,
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              unreadNotificationCount: _unreadCount, // Passez le compteur ici
              currentUserId: widget.utilisateur?.id ?? '', // Assurez-vous de passer l'ID de l'utilisateur courant
            )
          : Scaffold(
              appBar: AppBar(title: Text('Erreur')),
              body: Center(child: Text('Aucun écran client disponible.')),
            );
    }
  }
}
