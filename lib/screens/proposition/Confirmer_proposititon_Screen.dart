import 'package:flutter/material.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/proposition.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/services/proposition_service.dart';
import 'package:uuid/uuid.dart';

class ConfirmerPropositionScreen extends StatelessWidget {
  final String idUtilisateur1;
  final String idUtilisateur2;
  final String idObjet1;
  final Objet objet2; // L'objet proposé par l'utilisateur2
  final String message;
  final Annonce annonce;
  final Objet objet; // L'objet supplémentaire

  ConfirmerPropositionScreen({
    required this.idUtilisateur1,
    required this.idUtilisateur2,
    required this.idObjet1,
    required this.objet2,
    required this.message,
    required this.annonce,
    required this.objet, // Assurez-vous que cet objet est requis
  });

  @override
  Widget build(BuildContext context) {
    var uuid = Uuid();
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirmer la proposition"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Vous proposez l'objet : ${objet2.nom}"),
            Text("En échange de l'objet : $idObjet1"),
            Text("Message : $message"),
            ElevatedButton(
              onPressed: () async {
                String idProposition = uuid.v4();
                
                // Création de la proposition avec le type récupéré depuis annonce.type
                Proposition proposition = Proposition(
                  id: idProposition, 
                  idUtilisateur1: idUtilisateur1,
                  idObjet1: idObjet1,
                  idUtilisateur2: idUtilisateur2,
                  idObjet2: objet2.id,
                  dateProposition: DateTime.now(),
                  annonce: annonce,
                  statut: 'en attente',
                  objet2: objet2,
                  type: annonce.type.toString().split('.').last, // Utilisation du type d'annonce
                );

                // Appel à la méthode enregistrerProposition pour sauvegarder dans Firestore
                await PropositionService().enregistrerProposition(proposition);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Proposition faite avec succès !")),
                );

                Navigator.pop(context);
              },
              child: Text("Confirmer la proposition"),
            ),
          ],
        ),
      ),
    );
  }
}
