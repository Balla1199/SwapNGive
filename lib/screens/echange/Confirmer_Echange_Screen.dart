import 'package:flutter/material.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/Echange.dart';
import 'package:swapngive/services/echange_service.dart';

class ConfirmerEchangeScreen extends StatefulWidget {
  final String idUtilisateur1; // l'utilisateur de l'annonce
  final String idUtilisateur2; // l'utilisateur actuellement connecté
  final String idObjet1;  // L'objet de l'annonce de l'utilisateur1
  final String idObjet2; // L'objet proposé par l'utilisateur2
  final Annonce annonce; // Annonce associée

  ConfirmerEchangeScreen({
    required this.idUtilisateur1,
    required this.idUtilisateur2,
    required this.idObjet1,
    required this.idObjet2,
    required this.annonce,
  });

  @override
  _ConfirmerEchangeScreenState createState() => _ConfirmerEchangeScreenState();
}

class _ConfirmerEchangeScreenState extends State<ConfirmerEchangeScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confirmer l'échange"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Vous proposez l'objet : ${widget.idObjet1}"),
            Text("En échange de l'objet : ${widget.idObjet2}"),
            SizedBox(height: 20),
            
            // Champ de saisie pour le message personnalisé
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: "Message personnalisé",
                border: OutlineInputBorder(),
              ),
              maxLines: 3, // Limiter à 3 lignes de texte
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                // Appel du service d'échange pour enregistrer l'échange
                Echange echange = Echange(
                  idUtilisateur1: widget.idUtilisateur1,
                  idObjet1: widget.idObjet1,
                  idUtilisateur2: widget.idUtilisateur2,
                  idObjet2: widget.idObjet2,
                  dateEchange: DateTime.now(),
                  annonce: widget.annonce,
                  message: _messageController.text, // Message saisi par l'utilisateur
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
