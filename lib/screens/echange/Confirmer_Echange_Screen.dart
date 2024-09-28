import 'package:flutter/material.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/Echange.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/services/echange_service.dart';

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
                  objet2: widget.objet2, // Passer directement l'objet
                  dateEchange: DateTime.now(),
                  annonce: widget.annonce,
                  message: _messageController.text,

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