import 'package:flutter/material.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/Echange.dart';
import 'package:swapngive/models/Notification.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/services/echange_service.dart';
import 'package:swapngive/services/notification_service.dart';
import 'package:swapngive/services/utilisateur_service.dart';

class ConfirmerEchangeScreen extends StatefulWidget {
  final String idUtilisateur1; // Utilisateur de l'annonce
  final String idUtilisateur2; // Utilisateur qui propose l'échange
  final String idObjet1; // ID de l'objet de l'annonce (non utilisé ici pour le message)
  final Objet objet2; // Objet proposé par l'utilisateur 2
  final Annonce annonce; // Annonce contenant l'objet d'origine

  ConfirmerEchangeScreen({
    required this.idUtilisateur1,
    required this.idUtilisateur2,
    required this.idObjet1,
    required this.objet2,
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
            // Remplacement de l'ID de l'objet par son nom
            Text("Vous proposez l'objet : ${widget.objet2.nom}"), 
            Text("En échange de l'objet : ${widget.annonce.objet.nom}"), // Nom de l'objet 2
            SizedBox(height: 20),

            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: "Message personnalisé",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                // Création de l'échange
                String nouvelId = DateTime.now().millisecondsSinceEpoch.toString();
                Echange echange = Echange(
                  id: nouvelId,
                  idUtilisateur1: widget.idUtilisateur1,
                  idObjet1: widget.idObjet1,
                  idUtilisateur2: widget.idUtilisateur2,
                  objet2: widget.objet2,
                  dateEchange: DateTime.now(),
                  annonce: widget.annonce,
                  message: _messageController.text,
                );

                await EchangeService().enregistrerEchange(echange);

                // Récupérer les informations de l'utilisateur2
                var utilisateur2 = await UtilisateurService().getUtilisateurById(widget.idUtilisateur2);
                
                // Création de la notification pour l'utilisateur1 (le destinataire)
                NotificationModel notification = NotificationModel(
                  id: nouvelId, // Utiliser le même ID que l'échange
                  fromUserId: widget.idUtilisateur2, // Utilisateur qui fait la proposition
                  toUserId: widget.idUtilisateur1, // Utilisateur qui reçoit la proposition
                  titre: "Nouvelle proposition d'échange",
                  // Message personnalisé avec le nom de l'objet et l'utilisateur 2
                  message: " vous a fait une proposition d'échange pour l'objet : ${widget.annonce.objet.nom}",
                  date: DateTime.now(),
                );

                // Enregistrer la notification dans Firebase
                await NotificationService().enregistrerNotification(notification);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Échange proposé avec succès et notification envoyée !")),
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
