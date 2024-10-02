import 'package:flutter/material.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/Echange.dart';
import 'package:swapngive/models/Notification.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/services/echange_service.dart';
import 'package:swapngive/services/notification_service.dart';
import 'package:swapngive/services/utilisateur_service.dart';

class ConfirmerEchangeScreen extends StatefulWidget {
  final String idUtilisateur1; 
  final String idUtilisateur2; 
  final String idObjet1;  
  final Objet objet2; // Passer l'objet ici
  final Annonce annonce; 

  ConfirmerEchangeScreen({
    required this.idUtilisateur1,
    required this.idUtilisateur2,
    required this.idObjet1,
    required this.objet2, // Prendre l'objet
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
            Text("En échange de l'objet : ${widget.objet2.nom}"), // Assurez-vous que l'objet a une propriété 'nom'
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
      // Message personnalisé avec le nom de l'utilisateur2
      message: " vous a fait une proposition d'échange pour l'objet : ${widget.idObjet1}",
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