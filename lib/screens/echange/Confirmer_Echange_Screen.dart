import 'package:flutter/material.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/Echange.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/services/echange_service.dart';
import 'package:uuid/uuid.dart';
class ConfirmerEchangeScreen extends StatelessWidget {
  final String idUtilisateur1;
  final String idUtilisateur2;
  final String idObjet1;
  final Objet objet2; // L'objet proposé par l'utilisateur2
  final String message;
  final Annonce annonce;
  final Objet objet; // L'objet supplémentaire

  ConfirmerEchangeScreen({
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
        title: Text("Confirmer l'échange"),
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
                String idEchange = uuid.v4();
                Echange echange = Echange(
                    id: idEchange, 
                  idUtilisateur1: idUtilisateur1,
                  idObjet1: idObjet1,
                  idUtilisateur2: idUtilisateur2,
                  idObjet2: objet2.id,
                  dateEchange: DateTime.now(),
                  annonce: annonce,
                  statut: 'en attente',
                  objet2: objet2,
                );

                await EchangeService().enregistrerEchange(echange);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Échange proposé avec succès !")),
                );

                Navigator.pop(context);
              },
              child: Text("Confirmer l'échange"),
            ),
          ],
        ),
      ),
    );
  }
}
