import 'package:flutter/material.dart';
import 'package:swapngive/models/Categorie.dart';
import 'package:swapngive/models/etat.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/screens/Historique/Historiquescreen.dart';
import 'package:swapngive/screens/Historique/historique_detail_don_screen.dart';
import 'package:swapngive/screens/Historique/historique_detail_echange_screen.dart';
import 'package:swapngive/screens/annonce/annonce_form_screen.dart';
import 'package:swapngive/screens/annonce/annonce_list_screen.dart';
import 'package:swapngive/screens/annonce/annonce_details_screen.dart';
import 'package:swapngive/screens/avis/Avis_Form_Screen.dart';
import 'package:swapngive/screens/chat/chatscreen.dart';
import 'package:swapngive/screens/dashbord/Dashboard_Screen.dart';
import 'package:swapngive/screens/don/MessageDon_screen.dart';
import 'package:swapngive/screens/echange/Confirmer_Echange_Screen.dart';
import 'package:swapngive/screens/echange/objetechange_screen.dart';
import 'package:swapngive/screens/etat/etat_form_screen.dart';
import 'package:swapngive/screens/etat/etat_list_screen.dart';
import 'package:swapngive/screens/home/home_screen.dart';
import 'package:swapngive/screens/inscription/inscription_screen.dart';
import 'package:swapngive/screens/login/login_screen.dart';
import 'package:swapngive/screens/notification/notification_screen.dart';
import 'package:swapngive/screens/profil/profile_screen.dart';
import 'package:swapngive/screens/categorie/categorie_list_screen.dart';
import 'package:swapngive/screens/categorie/categorie_form_screen.dart';
import 'package:swapngive/screens/objet/objet_details_screen.dart';
import 'package:swapngive/screens/objet/objet_form_screen.dart';
import 'package:swapngive/screens/objet/objet_list_screen.dart';
import 'package:swapngive/screens/reception/detaildonscreen.dart';
import 'package:swapngive/screens/reception/detailechangescreen.dart';
import 'package:swapngive/screens/reception/reception_screen.dart';
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

  // Nouvelle route pour MessageDonScreen
  static const String messageDon = '/message_don';

  // Nouvelles routes pour les écrans de réception et de détails
  static const String receptionScreen = '/reception_screen';
  static const String detailEchangeScreen = '/detail_echange_screen';
  static const String detailDonScreen = '/detail_don_screen';

  // Nouvelle route pour NotificationScreen
  static const String notificationScreen = '/notification_screen';

  // Nouvelles routes pour ChatScreen et ConversationScreen
  static const String chatScreen = '/chat_screen';
  static const String conversationScreen = '/conversation_screen';

  // Nouvelle route pour AvisFormScreen
  static const String avisFormScreen = '/avis_form_screen';

  static const String dashboardScreen = '/dashboard_screen';

   // Nouvelle route pour HistoriqueScreen
  static const String historiqueScreen = '/historique_screen';
   
  static const String historiqueDetailDonScreen = '/historique_detail_don_screen';
  static const String historiqueDetailEchangeScreen = '/historique_detail_change_screen';

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

    case profile:
  final args = settings.arguments as Map<String, dynamic>?; 
  final utilisateur = args != null ? args['utilisateur'] as Utilisateur : null;
  final utilisateurId = utilisateur?.id; // Assurez-vous d'avoir l'ID utilisateur ici
  
  // Déterminez si l'utilisateur actuel est différent de l'utilisateur affiché
  bool isDifferentUser = true; // Changez cette logique en fonction de votre cas d'utilisation

  return MaterialPageRoute(
    builder: (_) => ProfileScreen(
      utilisateurId: utilisateurId!, // Assurez-vous que cet ID n'est jamais null
      isDifferentUser: isDifferentUser, // Ajoutez cet argument
      utilisateur: utilisateur,
    ),
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
      final idObjet = args?['idObjet'] as String; 
      final message = args?['message'] as String; 
      final annonce = args?['annonce'] as Annonce; 

      return MaterialPageRoute(
        builder: (_) => ChoisirObjetEchangeScreen(
          annonce: annonce,
          idObjet: idObjet,
          message: message,
        ),
      );
 case confirmerEchange:
  final args = settings.arguments as Map<String, dynamic>?; 
  final idUtilisateur1 = args?['idUtilisateur1'] as String;
  final idUtilisateur2 = args?['idUtilisateur2'] as String;
  final idObjet1 = args?['idObjet1'] as String;
  final objet2 = args?['objet2'] as Objet; 
  final annonce = args?['annonce'] as Annonce; 

  return MaterialPageRoute(
    builder: (_) => ConfirmerEchangeScreen(
      idUtilisateur1: idUtilisateur1,
      idUtilisateur2: idUtilisateur2,
      idObjet1: idObjet1,
      objet2: objet2, 
      annonce: annonce, 
    ),
  );

    // Route pour MessageDonScreen
    case messageDon:
      final args = settings.arguments as Map<String, dynamic>?; 
      final annonce = args?['annonce'] as Annonce;
      final idObjet = args?['idObjet'] as String;      
  return MaterialPageRoute(
    builder: (_) => MessageDonScreen(idObjet: idObjet, annonce: annonce),
  );

   // Routes pour DetailDonScreen
case detailDonScreen:
  final args = settings.arguments as Map<String, dynamic>?; 
  final don = args != null ? args['don'] : null; 
  final currentUserId = args != null ? args['currentUserId'] : ''; 
  return MaterialPageRoute(
    builder: (_) => DetailDonScreen(
      don: don!,
      currentUserId: currentUserId, 
    ),
  );
      
      // Routes pour ReceptionScreen
      case receptionScreen:
        return MaterialPageRoute(builder: (_) => ReceptionScreen());

      // Routes pour DetailEchangeScreen
      case detailEchangeScreen:
        final args = settings.arguments as Map<String, dynamic>?; 
        final echange = args != null ? args['echange'] : null;
        return MaterialPageRoute(
          builder: (_) => DetailEchangeScreen(echange: echange!),
        );

    // Route pour NotificationScreen
    case notificationScreen:
      return MaterialPageRoute(builder: (_) => NotificationScreen());

    // Nouvelle route pour ChatScreen
    case chatScreen:
      final args = settings.arguments as Map<String, dynamic>?; 
      final annonceId = args?['annonceId'] as String;
      final typeAnnonce = args?['typeAnnonce'] as String;
      final conversationId = args?['conversationId'] as String;
      final senderId = args?['senderId'] as String;
      final receiverId = args?['receiverId'] as String;

      return MaterialPageRoute(
        builder: (_) => ChatScreen(
          annonceId: annonceId,
          typeAnnonce: typeAnnonce,
          conversationId: conversationId,
          senderId: senderId,
          receiverId: receiverId,
    
        ),
      );
    
    case avisFormScreen:
  final args = settings.arguments as Map<String, dynamic>?; 
  final avis = args != null ? args['avis'] : null; 
  final utilisateurEvalueId = args != null ? args['utilisateurEvalueId'] : null; 
  final typeAnnonce = args != null ? args['typeAnnonce'] : null; // Ajoutez cette ligne pour récupérer typeAnnonce
  final annonceId = args != null ? args['annonceId'] : null; // Ajoutez cette ligne pour récupérer annonceId

  // Vérifiez si les ID nécessaires sont disponibles
  if (utilisateurEvalueId == null) {
    throw Exception("utilisateurEvalueId est requis");
  }
  if (typeAnnonce == null) {
    throw Exception("typeAnnonce est requis"); // Vérifiez si typeAnnonce est requis
  }
  if (annonceId == null) {
    throw Exception("annonceId est requis"); // Vérifiez si annonceId est requis
  }

  return MaterialPageRoute(
    builder: (_) => AvisFormScreen(
      avis: avis, 
      utilisateurEvalueId: utilisateurEvalueId,
      typeAnnonce: typeAnnonce, // Passez typeAnnonce ici
      annonceId: annonceId, // Passez annonceId ici
    ),
  );

  // Ajout du cas pour DashboardScreen
      case dashboardScreen:
        return MaterialPageRoute(builder: (_) => DashboardScreen());

        
      // Routes pour la connexion, l'inscription et le profil
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());

      case inscription:
        return MaterialPageRoute(builder: (_) => InscriptionScreen());

      case historiqueScreen:
        return MaterialPageRoute(builder: (_) => HistoriqueScreen());


       // Route pour HistoriqueDetailDonScreen
      case historiqueDetailDonScreen:
        final args = settings.arguments as Map<String, dynamic>?; 
        final don = args != null ? args['don'] : null; 
        return MaterialPageRoute(
          builder: (_) => HistoriqueDetailDonScreen(don: don!),
        );

      // Route pour HistoriqueDetailChangeScreen
      case historiqueDetailEchangeScreen:
        final args = settings.arguments as Map<String, dynamic>?; 
        final echange = args != null ? args['echange'] : null; 
        return MaterialPageRoute(
          builder: (_) => HistoriqueDetailEchangeScreen(echange: echange!),
        );

           

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
