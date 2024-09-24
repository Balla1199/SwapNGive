
import 'package:flutter/material.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/Echange.dart';
import 'package:swapngive/services/echange_service.dart';
class ConfirmerEchangeScreen extends StatelessWidget {
  final String idUtilisateur1; // l'utilisateur de l'annonce
  final String idUtilisateur2; // l'utilisateur actuellement connecté
  final String idObjet1;  // L'objet de l'annonce de l'utilisateur1
  final String idObjet2; // L'objet proposé par l'utilisateur2
  final String message;
  final Annonce annonce; // Ajoutez cette ligne

  ConfirmerEchangeScreen({
    required this.idUtilisateur1,
    required this.idUtilisateur2,
    required this.idObjet1,
    required this.idObjet2,
    required this.message,
    required this.annonce, // Ajoutez cette ligne
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirmer l'échange"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Vous proposez l'objet : $idObjet1"),
            Text("En échange de l'objet : $idObjet2"),
            Text("Message : $message"),
            ElevatedButton(
              onPressed: () async {
                // Appel du service d'échange pour enregistrer l'échange
                Echange echange = Echange(
                  idUtilisateur1: idUtilisateur1,
                  idObjet1: idObjet1,
                  idUtilisateur2: idUtilisateur2,
                  idObjet2: idObjet2,
                  dateEchange: DateTime.now(),
                  annonce: annonce, // Ajoutez cette ligne
                );

                await EchangeService().enregistrerEchange(echange);

                // Afficher un message de confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Échange proposé avec succès !")),
                );

                Navigator.pop(context); // Retourner à l'écran précédent
              },
              child: Text("Confirmer l'échange"),
            ),
          ],
        ),
      ),
    );
  }
}
