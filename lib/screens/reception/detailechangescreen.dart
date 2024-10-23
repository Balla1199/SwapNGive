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
import 'package:swapngive/services/avis_service.dart';
import 'package:swapngive/services/echange_service.dart';
import 'package:swapngive/services/notification_service.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/services/utilisateur_service.dart';
class DetailEchangeScreen extends StatelessWidget {
  final Echange echange;
  final UtilisateurService utilisateurService = UtilisateurService();
  final EchangeService echangeService = EchangeService();
  final NotificationService notificationService = NotificationService();
  final AvisService avisService = AvisService();

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
      backgroundColor: Colors.white,
  // AppBar de l'écran
  appBar: AppBar(
  backgroundColor: Color(0xFFD9A9A9), // Couleur de l'AppBar modifiée
  title: Text(
    'Détails de l\'Échange',
    style: TextStyle(
      color: Colors.white, // Titre de l'AppBar en blanc
      fontWeight: FontWeight.bold, // Texte en gras
    ),
  ),
  leading: IconButton(
    icon: Icon(Icons.chevron_left, color: Colors.white), // Icône de retour modifiée
    onPressed: () {
      Navigator.pop(context); // Action de retour
    },
  ),
),


  // Body du Scaffold
  body: SingleChildScrollView(
    // Définir la couleur de fond de l'écran en F9F9F9
    // Utilisation de Container pour appliquer la couleur
    child: Container(
    //  color: Color(0xFFF9F9F9), // Couleur de fond
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Affichage d'un carousel d'images
          CarouselSlider(
            options: CarouselOptions(autoPlay: true),
            items: images.map((image) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: SizedBox(
                    width: 400,
                    height: 150,
                    child: Image.network(image, fit: BoxFit.cover),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Récupération des détails de l'utilisateur actuel
          FutureBuilder<Utilisateur?>(
            future: AuthService().getCurrentUserDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Erreur de récupération de l\'utilisateur');
              } else {
                final utilisateur = snapshot.data;
                final isCurrentUser = utilisateur != null && utilisateur.id != echange.idUtilisateur2;

                return isCurrentUser
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Bouton pour refuser l'échange
                          IconButton(
                            onPressed: () {
                              _mettreAJourStatut(echange.id, "refusé", context);
                            },
                            icon: Icon(Icons.clear),
                            iconSize: 30,
                            color: Colors.red,
                            tooltip: 'Refuser',
                          ),
                          // Bouton pour accepter l'échange
                          IconButton(
                            onPressed: () {
                              _mettreAJourStatut(echange.id, "accepté", context);
                            },
                            icon: Icon(Icons.handshake),
                            iconSize: 30,
                            color: Color(0xFFD9A9A9),
                            tooltip: 'Accepter',
                          ),
                          // Bouton pour discuter
                          IconButton(
                            onPressed: () {
                              _discuter(context);
                            },
                            icon: Icon(Icons.chat),
                            iconSize: 30,
                            color: Colors.black,
                            tooltip: 'Discuter',
                          ),
                        ],
                      )
                    : SizedBox.shrink();
              }
            },
          ),
          const SizedBox(height: 16),

          // Affichage du nom de l'objet
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              nomObjet2,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD9A9A9),
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 8),

          // Affichage de la description de l'objet
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              descriptionObjet2,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 16),

          // Affichage de l'état de l'objet
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'État : ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold, // Texte "État" en gras
                      color: Colors.black, // Couleur du texte
                    ),
                  ),
                  TextSpan(
                    text: '\n$etatObjet2',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black, // Couleur du texte pour $etatObjet2
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 8),

          // Affichage du message échangé
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Message : ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold, // Texte "Message" en gras
                      color: Colors.black, // Couleur du texte
                    ),
                  ),
                  TextSpan(
                    text: '\n$messageEchange',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black, // Même couleur pour le message
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 16),

          // Affichage de la photo de profil de l'utilisateur
          FutureBuilder<String?>(
            future: utilisateurService.getProfilePhotoUrl(echange.idUtilisateur2),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Erreur lors de la récupération de la photo de profil.');
              } else {
                String imageUrl = snapshot.data ?? 'assets/images/user.png';
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                    const SizedBox(width: 10),

                    // Récupération et affichage des détails de l'utilisateur
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
                              // Nom de l'utilisateur
                              Text(
                                utilisateur.nom,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFD9A9A9),
                                ),
                              ),
                              // Affichage des étoiles de notation
                              FutureBuilder<double>(
                                future: avisService.getMoyenneNotes(utilisateur.id),
                                builder: (context, ratingSnapshot) {
                                  if (ratingSnapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (ratingSnapshot.hasError) {
                                    return Text('Erreur de récupération de la note.');
                                  } else {
                                    double moyenneNotes = ratingSnapshot.data ?? 0.0;
                                    return Row(
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          index < moyenneNotes
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.yellow,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              // Email de l'utilisateur
                              Text(
                                '${utilisateur.email}',
                                style: TextStyle(fontSize: 14),
                              ),
                              // Numéro de téléphone de l'utilisateur
                              Text(
                                '${utilisateur.telephone}',
                                style: TextStyle(fontSize: 14),
                              ),
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
  ),
);

  }

  Future<void> _mettreAJourStatut(String idEchange, String nouveauStatut, BuildContext context) async {
    try {
      await echangeService.mettreAJourStatut(idEchange, nouveauStatut);
      // Gestion du statut accepté ou refusé avec notification
      // ...
    } catch (e) {
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
