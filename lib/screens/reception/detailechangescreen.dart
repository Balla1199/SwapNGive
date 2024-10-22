import 'dart:math';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/Echange.dart';
import 'package:swapngive/models/Notification.dart';
import 'package:swapngive/screens/avis/Avis_Form_Screen.dart';
import 'package:swapngive/screens/chat/chatscreen.dart';
import 'package:swapngive/services/annonceservice.dart';
import 'package:swapngive/services/auth_service.dart';
import 'package:swapngive/services/echange_service.dart';
import 'package:swapngive/services/notification_service.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/services/utilisateur_service.dart';

class DetailEchangeScreen extends StatelessWidget {
  final Echange echange;
  final UtilisateurService utilisateurService = UtilisateurService();
  final EchangeService echangeService = EchangeService();
  final NotificationService notificationService = NotificationService();

  DetailEchangeScreen({Key? key, required this.echange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var objet2 = echange.objet2; 
    var images = objet2.imageUrl.split(',');
    var nomObjet2 = objet2.nom;
    var descriptionObjet2 = objet2.description;
    var etatObjet2 = objet2.etat.nom; 
    var messageEchange = echange.message; 

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'Échange'),
      ),
      body: SingleChildScrollView(
        child:Column(
  crossAxisAlignment: CrossAxisAlignment.start, // Ajout pour aligner les éléments à gauche
  children: [
    CarouselSlider(
  options: CarouselOptions(autoPlay: true),
  items: images.map((image) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0), // Rayon de la bordure
        child: SizedBox(
          width: 400,  // Largeur de l'image
          height: 200, // Hauteur de l'image
          child: Image.network(image, fit: BoxFit.cover),
        ),
      ),
    );
  }).toList(),
),
const SizedBox(height: 16),



    // Boutons Accepter, Refuser, et Discuter
    FutureBuilder<Utilisateur?>(
      future: AuthService().getCurrentUserDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Erreur de récupération de l\'utilisateur');
        } else {
          final utilisateur = snapshot.data;

          // Vérifier si l'utilisateur actuel est celui impliqué dans l'échange
          final isCurrentUser = utilisateur != null && utilisateur.id != echange.idUtilisateur2;

          // Afficher les boutons d'action uniquement si c'est l'utilisateur courant
          return isCurrentUser
              ?Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    // Bouton Refuser avec icône rouge
    IconButton(
      onPressed: () {
        _mettreAJourStatut(echange.id, "refusé", context);
      },
      icon: Icon(Icons.clear), // Icône pour Refuser
      iconSize: 30, // Taille de l'icône
      color: Colors.red, // Couleur rouge pour Refuser
      tooltip: 'Refuser', // Astuce pour indiquer la fonction
    ),

    // Bouton Accepter avec icône couleur D9A9A9
    IconButton(
      onPressed: () {
        _mettreAJourStatut(echange.id, "accepté", context);
      },
      icon: Icon(Icons.handshake), // Icône pour Accepter
      iconSize: 30, // Taille de l'icône
      color: Color(0xFFD9A9A9), // Couleur personnalisée D9A9A9 pour Accepter
      tooltip: 'Accepter', // Astuce pour indiquer la fonction
    ),

    // Bouton Discuter avec icône noire
    IconButton(
      onPressed: () {
        _discuter(context);
      },
      icon: Icon(Icons.chat), // Icône pour Discuter
      iconSize: 30, // Taille de l'icône
      color: Colors.black, // Couleur noire pour Discuter
      tooltip: 'Discuter', // Astuce pour indiquer la fonction
    ),
  ],
)


              : SizedBox.shrink();
        }
      },
    ),
    const SizedBox(height: 16),

    // Nom de l'objet2 avec couleur D9A9A9
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        nomObjet2,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFFD9A9A9), // Couleur D9A9A9
        ),
        textAlign: TextAlign.left, // Alignement à gauche
      ),
    ),
    const SizedBox(height: 8),

    // Description de l'objet2
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        descriptionObjet2,
        style: TextStyle(fontSize: 16),
        textAlign: TextAlign.left, // Alignement à gauche
      ),
    ),
    const SizedBox(height: 16),

    // État de l'objet2
   Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  child: Text(
    'État :\n$etatObjet2',  // Saut de ligne ajouté avant la valeur de l'état
    style: TextStyle(fontSize: 18),
    textAlign: TextAlign.left, // Alignement à gauche
  ),
),
const SizedBox(height: 8),

    // Message de l'échange
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'Message : \n$messageEchange',
        style: TextStyle(fontSize: 18),
        textAlign: TextAlign.left, // Alignement à gauche
      ),
    ),
    const SizedBox(height: 16),

    // Récupérer et afficher la photo de profil de l'utilisateur 2
    FutureBuilder<String?>(
      future: utilisateurService.getProfilePhotoUrl(echange.idUtilisateur2),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Erreur lors de la récupération de la photo de profil.');
        } else {
          String imageUrl = snapshot.data ?? 'assets/images/user.png'; // Image par défaut
          return Row(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(imageUrl),
              ),
              const SizedBox(width: 10),
              FutureBuilder<Utilisateur?>(
                future: utilisateurService.getUtilisateurById(echange.idUtilisateur2),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (userSnapshot.hasError) {
                    return Text('Erreur lors de la récupération des détails de l\'utilisateur.');
                  } else if (userSnapshot.hasData && userSnapshot.data != null) {
                    final utilisateur = userSnapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(utilisateur.nom, style: TextStyle(fontSize: 18,  fontWeight: FontWeight.bold,
          color: Color(0xFFD9A9A9), )),
                        Text('${utilisateur.email}', style: TextStyle(fontSize: 14,)),
                        Text('${utilisateur.telephone}', style: TextStyle(fontSize: 14)),
                      ],
                    );
                  } else {
                    return Text('Utilisateur non trouvé.', style: TextStyle(fontSize: 18));
                  }
                },
              ),
            ],
          );
        }
      },
    ),
    const SizedBox(height: 16),
  ],
),


      ),
    );
  }

  // Méthode pour mettre à jour le statut de l'échange
  Future<void> _mettreAJourStatut(String idEchange, String nouveauStatut, BuildContext context) async {
    try {
      print("Mise à jour du statut pour l'échange ID: $idEchange avec le nouveau statut: $nouveauStatut");

      await echangeService.mettreAJourStatut(idEchange, nouveauStatut);

      if (nouveauStatut == "accepté") {
        await AnnonceService().mettreAJourStatut(echange.annonce.id, StatutAnnonce.indisponible);
      } else if (nouveauStatut == "refusé") {
        await AnnonceService().mettreAJourStatut(echange.annonce.id, StatutAnnonce.disponible);
      }

      // Récupérer les informations de l'utilisateur2
      var utilisateur2 = await utilisateurService.getUtilisateurById(echange.idUtilisateur2);

      // Création de la notification
      NotificationModel? notification; 
      if (nouveauStatut == "accepté") {
        notification = NotificationModel(
          id: idEchange,
          fromUserId: echange.idUtilisateur1,
          toUserId: echange.idUtilisateur2,
          titre: "Échange accepté",
          message: "a accepté votre proposition d'échange pour l'objet : ${echange.annonce.objet.nom}. Merci d'avoir finalisé votre échange ! Nous vous invitons à évaluer votre expérience.",
          date: DateTime.now(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Expanded(
                  child: Text("Échange finalisé ! Laissez une évaluation."),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvisFormScreen(
                          utilisateurEvalueId: echange.idUtilisateur2,
                          typeAnnonce: echange.annonce.type.toString().split('.').last,
                          annonceId: echange.annonce.id,
                        ),
                      ),
                    );
                  },
                  child: Text('Évaluer'),
                ),
              ],
            ),
          ),
        );
      } else if (nouveauStatut == "refusé") {
        notification = NotificationModel(
          id: idEchange,
          fromUserId: echange.idUtilisateur1,
          toUserId: echange.idUtilisateur2,
          titre: "Échange refusé",
          message: "a refusé votre proposition d'échange pour l'objet : ${echange.annonce.objet.nom}",
          date: DateTime.now(),
        );
      }

      if (notification != null) {
        await notificationService.enregistrerNotification(notification);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut mis à jour en: $nouveauStatut')),
      );
    } catch (e) {
      print("Erreur lors de la mise à jour du statut: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du statut: $e')),
      );
    }
  }

  // Méthode pour discuter
  void _discuter(BuildContext context) async {
    var currentUser = await AuthService().getCurrentUserDetails();

    if (currentUser != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            annonceId: echange.annonce.id,
            typeAnnonce: echange.annonce.type.toString().split('.').last,
            conversationId: echange.id,
            senderId: currentUser.id,
            receiverId: echange.idUtilisateur2,
          ),
        ),
      );
    } else {
      print("Utilisateur non connecté.");
    }
  }
}
