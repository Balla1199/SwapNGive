import 'dart:math';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swapngive/models/Echange.dart';
import 'package:swapngive/models/Notification.dart';
import 'package:swapngive/screens/avis/Avis_Form_Screen.dart';
import 'package:swapngive/screens/chat/chatscreen.dart';
import 'package:swapngive/services/auth_service.dart';
import 'package:swapngive/services/echange_service.dart';
import 'package:swapngive/services/notification_service.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/services/utilisateur_service.dart';

class DetailEchangeScreen extends StatelessWidget {
  final Echange echange;
  final EchangeService echangeService = EchangeService();
  final NotificationService notificationService = NotificationService(); // Instance de NotificationService

  DetailEchangeScreen({Key? key, required this.echange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var objet2 = echange.annonce.objet; 
    var images = objet2.imageUrl.split(',');
    var nomObjet2 = objet2.nom;
    var descriptionObjet2 = objet2.description;
    var etatObjet2 = objet2.etat.nom; 
    var categorieObjet2 = objet2.categorie.nom;

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'Échange'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(autoPlay: true),
              items: images.map((image) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: Image.network(image, fit: BoxFit.cover),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(nomObjet2, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(descriptionObjet2, style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            Text('État : $etatObjet2', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Catégorie : $categorieObjet2', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            // Récupération de l'utilisateur actuel
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

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: isCurrentUser ? [
                      ElevatedButton(
                        onPressed: () {
                          print("Accepter l'échange: ${echange.id}");
                          _mettreAJourStatut(echange.id, "accepté", context);
                        },
                        child: Text('Accepter'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          print("Refuser l'échange: ${echange.id}");
                          _mettreAJourStatut(echange.id, "refusé", context);
                        },
                        child: Text('Refuser'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          print("Discussion sur l'échange: ${echange.id}");
                          _discuter(context);
                        },
                        child: Text('Discuter'),
                      ),
                    ] : [],
                  );
                }
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _mettreAJourStatut(String idEchange, String nouveauStatut, BuildContext context) async {
  try {
    print("Mise à jour du statut pour l'échange ID: $idEchange avec le nouveau statut: $nouveauStatut");

    // Mettre à jour le statut de l'échange
    await echangeService.mettreAJourStatut(idEchange, nouveauStatut);

    // Récupérer les informations de l'utilisateur2
    var utilisateur2 = await UtilisateurService().getUtilisateurById(echange.idUtilisateur2);

    // Création de la notification
    NotificationModel? notification; // Type nullable
    if (nouveauStatut == "accepté") {
      // Message pour l'acceptation
      notification = NotificationModel(
        id: idEchange, // Utiliser l'ID de l'échange
        fromUserId: echange.idUtilisateur1, // Utilisateur qui fait l'acceptation
        toUserId: echange.idUtilisateur2, // Utilisateur qui reçoit la notification
        titre: "Échange accepté",
        message: "a accepté votre proposition d'échange pour l'objet : ${echange.annonce.objet.nom}. Merci d'avoir finalisé votre échange ! Nous vous invitons à évaluer votre expérience.",
        date: DateTime.now(),
      );

      // Envoi de l'invitation à évaluer avec un bouton
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Expanded(
                child: Text("Échange finalisé ! Laissez une évaluation."),
              ),
             ElevatedButton(
  onPressed: () {
    // Assurez-vous d'avoir les valeurs nécessaires
    String utilisateurEvalueId = echange.idUtilisateur2; // Remplacez par l'ID approprié
    String typeAnnonce = echange.annonce.type.toString().split('.').last; // Remplacez par le type d'annonce approprié
    String annonceId = echange.annonce.id; // Remplacez par l'ID de l'annonce approprié

    // Redirection vers l'écran d'évaluation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvisFormScreen(
          utilisateurEvalueId: utilisateurEvalueId,
          typeAnnonce: typeAnnonce,
          annonceId: annonceId,
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
      // Message pour le refus
      notification = NotificationModel(
        id: idEchange, // Utiliser l'ID de l'échange
        fromUserId: echange.idUtilisateur1, // Utilisateur qui fait le refus
        toUserId: echange.idUtilisateur2, // Utilisateur qui reçoit la notification
        titre: "Échange refusé",
        message: "a refusé votre proposition d'échange pour l'objet : ${echange.annonce.objet.nom}",
        date: DateTime.now(),
      );
    }

    // Vérification de la notification non nulle avant l'enregistrement
    if (notification != null) {
      await NotificationService().enregistrerNotification(notification);
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


void _discuter(BuildContext context) async {
  // Récupérer les détails de l'utilisateur actuel
  var currentUser = await AuthService().getCurrentUserDetails();

  if (currentUser != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          annonceId: echange.annonce.id, // Supposons que 'echange.annonce.id' contient l'ID de l'annonce
          typeAnnonce: echange.annonce.type.toString().split('.').last, // Convertir TypeAnnonce en String
          conversationId: echange.id, // Utiliser l'ID d'échange comme ID de conversation
          senderId: currentUser.id, // Utilisateur actuel connecté
          receiverId: echange.idUtilisateur2, // L'autre utilisateur dans l'échange
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erreur : Impossible de récupérer les détails de l\'utilisateur actuel.')),
    );
  }
}


}
