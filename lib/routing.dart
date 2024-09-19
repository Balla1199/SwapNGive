import 'package:flutter/material.dart';
import 'package:swapngive/models/Categorie.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/screens/etat/etat_form_screen.dart';
import 'package:swapngive/screens/etat/etat_list_screen.dart';
import 'package:swapngive/screens/home/home_screen.dart';
import 'package:swapngive/screens/inscription/inscription_screen.dart';
import 'package:swapngive/screens/login/login_screen.dart';
import 'package:swapngive/screens/utilisateur/add_user_screen.dart';
import 'package:swapngive/screens/utilisateur/user_list_screen.dart';
import 'package:swapngive/screens/categorie/categorie_list_screen.dart';
import 'package:swapngive/screens/categorie/categorie_form_screen.dart';
import 'package:swapngive/screens/objet/objet_list_screen.dart';
import 'package:swapngive/screens/objet/objet_form_screen.dart';


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
  
  // New routes for Login and Inscription screens
  static const String login = '/login';
  static const String inscription = '/inscription';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case userList:
        return MaterialPageRoute(builder: (_) => UserListScreen());
      case addUser:
        return MaterialPageRoute(builder: (_) => AddUserScreen());
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
        
      // New cases for login and registration screens
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case inscription:
        return MaterialPageRoute(builder: (_) => InscriptionScreen());
        
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Page non trouvée')),
          ),
        );
    }
  }
}
