import 'package:flutter/material.dart';
import 'package:swapngive/models/Categorie.dart';
import 'package:swapngive/models/etat.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/screens/annonce/annonce_form_screen.dart';
import 'package:swapngive/screens/annonce/annonce_list_screen.dart';
import 'package:swapngive/screens/annonce/annonce_details_screen.dart';
import 'package:swapngive/screens/echange/Confirmer_Echange_Screen.dart';
import 'package:swapngive/screens/echange/objetechange_screen.dart';
import 'package:swapngive/screens/etat/etat_form_screen.dart';
import 'package:swapngive/screens/etat/etat_list_screen.dart';
import 'package:swapngive/screens/home/home_screen.dart';
import 'package:swapngive/screens/inscription/inscription_screen.dart';
import 'package:swapngive/screens/login/login_screen.dart';
import 'package:swapngive/screens/profil/profile_screen.dart';
import 'package:swapngive/screens/categorie/categorie_list_screen.dart';
import 'package:swapngive/screens/categorie/categorie_form_screen.dart';
import 'package:swapngive/screens/objet/objet_details_screen.dart';
import 'package:swapngive/screens/objet/objet_form_screen.dart';
import 'package:swapngive/screens/objet/objet_list_screen.dart';
import 'package:swapngive/screens/utilisateur/utilisateur_form_screen.dart';
import 'package:swapngive/screens/utilisateur/utilisateur_list_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String userList = '/user_list';
  static const String addUser = '/add_user';
  static const String categorieList = '/categorie_list';
  static const String categorieForm = '/categorie_form';
  static const String etatList = '/etat_list';
  static const String etatForm = '/etat_form';
  static const String objetList = '/objet_list';
  static const String objetForm = '/objet_form';
  static const String objetDetails = '/objet_details';

  // Routes pour Annonce
  static const String annonceList = '/annonce_list';
  static const String annonceForm = '/annonce_form';
  static const String annonceDetails = '/annonce_details';

  // Routes pour la connexion et l'inscription
  static const String login = '/login';
  static const String inscription = '/inscription';

  // Route pour l'écran de profil
  static const String profile = '/profile';

  // Routes pour UtilisateurListScreen et UtilisateurFormScreen
  static const String utilisateurList = '/utilisateur_list';
  static const String utilisateurForm = '/utilisateur_form';

  // Nouvelles routes pour l'échange
  static const String choisirObjetEchange = '/choisir_objet_echange';
  static const String confirmerEchange = '/confirmer_echange';

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
        return MaterialPageRoute(builder: (_) => ObjetListScreen());
      case objetForm:
        final args = settings.arguments as Map<String, dynamic>?; 
        final objet = args != null ? args['objet'] as Objet? : null;
        return MaterialPageRoute(
          builder: (_) => ObjetFormScreen(objet: objet),
        );
      case objetDetails:
        final args = settings.arguments as Map<String, dynamic>?; 
        final objet = args != null ? args['objet'] as Objet : null;
        return MaterialPageRoute(
          builder: (_) => ObjetDetailsScreen(objet: objet!),
        );

      // Routes pour Annonce
      case annonceList:
        return MaterialPageRoute(builder: (_) => AnnonceListScreen());
      case annonceForm:
        final args = settings.arguments as Map<String, dynamic>?; 
        final annonce = args != null ? args['annonce'] as Annonce? : null;

        // Ensure the objet is passed or create a default one
        final objet = args != null && args['objet'] != null 
            ? args['objet'] as Objet 
            : Objet(
                id: 'default-id',
                nom: 'Objet par défaut',
                description: 'Description par défaut',
                etat: Etat(id: 'default-etat-id', nom: 'État par défaut'),
                categorie: Categorie(id: 'default-categorie-id', nom: 'Catégorie par défaut'),
                dateAjout: DateTime.now(),
                utilisateur: Utilisateur(
                  id: 'default-utilisateur-id', 
                  nom: 'Utilisateur par défaut', 
                  email: 'user@default.com',
                  motDePasse: 'default-password',
                  adresse: 'Adresse par défaut',
                  telephone: '0000000000',
                  dateInscription: DateTime.now(),
                  role: Role.user,
                ),
                imageUrl: 'default-image-url',
              );

        return MaterialPageRoute(
          builder: (_) => AnnonceFormScreen(annonce: annonce, objet: objet),
        );

      case annonceDetails:
        final args = settings.arguments as Map<String, dynamic>?; 
        final annonce = args != null ? args['annonce'] as Annonce : null;
        return MaterialPageRoute(
          builder: (_) => AnnonceDetailsScreen(annonce: annonce!),
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

    // Routes pour choisir et confirmer l'échange
case choisirObjetEchange:
  final args = settings.arguments as Map<String, dynamic>?; 
  final idObjet = args?['idObjet'] as String; // Récupérer l'idObjet des arguments
  final message = args?['message'] as String; // Récupérer le message des arguments
  final annonce = args?['annonce'] as Annonce; // Récupérer l'objet Annonce des arguments

  return MaterialPageRoute(
    builder: (_) => ChoisirObjetEchangeScreen(
      annonce: annonce, // Passer l'objet Annonce au constructeur
      idObjet: idObjet, // Passer idObjet au constructeur
      message: message, // Passer message au constructeur
    ),
  );


    case confirmerEchange:
  final args = settings.arguments as Map<String, dynamic>?; 
  final idUtilisateur1 = args?['idUtilisateur1'] as String;
  final idUtilisateur2 = args?['idUtilisateur2'] as String;
  final idObjet1 = args?['idObjet1'] as String;
  final idObjet2 = args?['idObjet2'] as String;
  final message = args?['message'] as String;
  final annonce = args?['annonce'] as Annonce; // Récupérez l'objet Annonce ici

  return MaterialPageRoute(
    builder: (_) => ConfirmerEchangeScreen(
      idUtilisateur1: idUtilisateur1,
      idUtilisateur2: idUtilisateur2,
      idObjet1: idObjet1,
      idObjet2: idObjet2,
      message: message,
      annonce: annonce, // Passez l'objet Annonce ici
    ),
  );


      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Erreur: Route non définie')),
          ),
        );
    }
  }
}
