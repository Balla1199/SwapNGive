import 'package:flutter/material.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/Don.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/services/don_service.dart';
import 'package:swapngive/services/auth_service.dart'; // Importez le service Auth pour récupérer l'utilisateur

class MessageDonScreen extends StatefulWidget {
  final String idObjet;     // ID de l'objet à donner
  final Annonce annonce;    // Objet Annonce associé au don

  MessageDonScreen({
    required this.idObjet,
    required this.annonce,
  });

  @override
  _MessageDonScreenState createState() => _MessageDonScreenState();
}

class _MessageDonScreenState extends State<MessageDonScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _message;
  String? _idDonneur; // ID de l'utilisateur qui fait le don
  String? _idReceveur; // ID de l'utilisateur qui reçoit le don

  @override
  void initState() {
    super.initState();
    // Récupérer l'ID de l'utilisateur à partir de l'annonce
    _idDonneur = widget.annonce.utilisateur.id; // Assurez-vous que l'annonce a la référence à l'utilisateur
    _getCurrentUserId(); // Appel de la méthode pour obtenir l'ID de l'utilisateur actuel
  }

  Future<void> _getCurrentUserId() async {
    Utilisateur? currentUser = await AuthService().getCurrentUserDetails();
    if (currentUser != null) {
      setState(() {
        _idReceveur = currentUser.id; // Stockez l'ID de l'utilisateur actuel dans idreceveur
      });
    }
  }

  // Fonction pour enregistrer le don avec le message
  Future<void> _enregistrerDon() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
// Créez un nouvel objet Don
Don don = Don(
  id: '', // ID généré par Firestore lors de l'ajout
  dateDon: DateTime.now(), // Utilisation du bon nom de paramètre
  idDonneur: _idDonneur!, // Utiliser l'ID du donneur récupéré
  idReceveur: _idReceveur!, // Utiliser l'ID de l'utilisateur actuel
  idObjet: widget.idObjet, // Assurez-vous que widget.idObjet est défini
  message: _message, // Champ optionnel
  annonce: widget.annonce, // Assurez-vous que widget.annonce est défini
  statut: 'attente', // Statut par défaut
);

      // Enregistrez le don via le service
      await DonService().enregistrerDon(don);

      // Affichez un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Don enregistré avec succès !")),
      );

      // Retournez à l'écran précédent
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajouter un message au don"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Message (optionnel)",
                ),
                maxLines: 3, // Permet d'avoir plusieurs lignes
                onSaved: (value) {
                  _message = value; // Sauvegarde le message
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _enregistrerDon,
                child: Text("Enregistrer le don"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
