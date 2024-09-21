import 'package:flutter/material.dart';
import 'package:swapngive/models/Categorie.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/screens/etat/etat_form_screen.dart';
import 'package:swapngive/screens/etat/etat_list_screen.dart';
import 'package:swapngive/screens/home/home_screen.dart';
import 'package:swapngive/screens/inscription/inscription_screen.dart';
import 'package:swapngive/screens/login/login_screen.dart';
import 'package:swapngive/screens/profil/profile_screen.dart';
import 'package:swapngive/screens/categorie/categorie_list_screen.dart';
import 'package:swapngive/screens/categorie/categorie_form_screen.dart';
import 'package:swapngive/screens/objet/objet_details_screen.dart'; // Importer l'écran des détails d'objet
import 'package:swapngive/screens/objet/objet_form_screen.dart'; // Importer ObjetFormScreen
import 'package:swapngive/screens/objet/objet_list_screen.dart'; // Importer ObjetListScreen
import 'package:swapngive/screens/utilisateur/utilisateur_form_screen.dart'; // Importer UtilisateurFormScreen
import 'package:swapngive/screens/utilisateur/utilisateur_list_screen.dart'; // Importer UtilisateurListScreen

class AppRoutes {
  static const String home = '/';
  static const String userList = '/user_list';
  static const String addUser = '/add_user';
  static const String categorieList = '/categorie_list';
  static const String categorieForm = '/categorie_form';
  static const String etatList = '/etat_list';
  static const String etatForm = '/etat_form';
  static const String objetList = '/objet_list'; // Nouvelle route pour la liste d'objets
  static const String objetForm = '/objet_form'; // Nouvelle route pour le formulaire d'objet
  static const String objetDetails = '/objet_details'; // Nouvelle route pour les détails d'objet

  // Routes pour la connexion et l'inscription
  static const String login = '/login';
  static const String inscription = '/inscription';

  // Route pour l'écran de profil
  static const String profile = '/profile';

  // Routes pour UtilisateurListScreen et UtilisateurFormScreen
  static const String utilisateurList = '/utilisateur_list';
  static const String utilisateurForm = '/utilisateur_form';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      
      case categorieList:
        return MaterialPageRoute(builder: (_) => CategorieListScreen());
      case categorieForm:
        final args = settings.arguments as Map<String, dynamic>?; 
        final categorie = args != null ? args['categorie'] as Categorie? : null;
        return MaterialPageRoute(
          builder: (_) => CategorieFormScreen(categorie: categorie),
        );
      case etatList:
        return MaterialPageRoute(builder: (_) => EtatListScreen());
      case etatForm:
        final args = settings.arguments as Map<String, dynamic>?; 
        final etat = args != null ? args['etat'] : null;
        return MaterialPageRoute(
          builder: (_) => EtatFormScreen(etat: etat),
        );

      case objetList:
        return MaterialPageRoute(builder: (_) => ObjetListScreen()); // Ajouter la route pour ObjetListScreen

      case objetForm:
        final args = settings.arguments as Map<String, dynamic>?; 
        final objet = args != null ? args['objet'] as Objet? : null;
        return MaterialPageRoute(
          builder: (_) => ObjetFormScreen(objet: objet), // Passer l'objet si disponible
        );

      case objetDetails:
        final args = settings.arguments as Map<String, dynamic>?; 
        final objet = args != null ? args['objet'] as Objet : null; // Récupérer l'objet passé
        return MaterialPageRoute(
          builder: (_) => ObjetDetailsScreen(objet: objet!), // Passer l'objet
        );

      // Routes pour la connexion, l'inscription et le profil
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case inscription:
        return MaterialPageRoute(builder: (_) => InscriptionScreen());
      case profile:
        final args = settings.arguments as Map<String, dynamic>?; 
        final utilisateur = args != null ? args['utilisateur'] as Utilisateur : null;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(utilisateur: utilisateur!),
        );

      // Cas pour UtilisateurListScreen
      case utilisateurList:
        return MaterialPageRoute(builder: (_) => UtilisateurListScreen());

      // Cas pour UtilisateurFormScreen
      case utilisateurForm:
        final args = settings.arguments as Map<String, dynamic>?; 
        final utilisateur = args != null ? args['utilisateur'] as Utilisateur? : null;
        return MaterialPageRoute(
          builder: (_) => UtilisateurFormScreen(utilisateur: utilisateur),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Page non trouvée')),
          ),
        );
    }
  }
}
