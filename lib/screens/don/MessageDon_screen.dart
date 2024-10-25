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
  Utilisateur? _receveur; // L'utilisateur qui reçoit le don (instance de Utilisateur)

  @override
  void initState() {
    super.initState();
    // Récupérer l'ID de l'utilisateur à partir de l'annonce
    _idDonneur = widget.annonce.utilisateur.id; // Assurez-vous que l'annonce a la référence à l'utilisateur
    _getCurrentUser(); // Appel de la méthode pour obtenir les détails de l'utilisateur actuel
  }

  Future<void> _getCurrentUser() async {
    Utilisateur? currentUser = await AuthService().getCurrentUserDetails();
    if (currentUser != null) {
      setState(() {
        _receveur = currentUser; // Stockez l'utilisateur actuel (instance de Utilisateur)
      });
    }
  }

  // Fonction pour enregistrer le don avec le message
  Future<void> _enregistrerDon() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Vérifiez que _receveur est bien défini avant de créer l'objet Don
      if (_receveur != null) {
        // Créez un nouvel objet Don
        Don don = Don(
          id: '', // ID généré par Firestore lors de l'ajout
          dateDon: DateTime.now(), // Utilisation du bon nom de paramètre
          idDonneur: _idDonneur!, // Utiliser l'ID du donneur récupéré
          receveur: _receveur!, // Utiliser l'objet Utilisateur pour le receveur
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
      } else {
        // Gérer le cas où _receveur est null
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: utilisateur actuel non trouvé")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xFFD9A9A9),
      leading: IconButton(
        icon: Icon(Icons.chevron_left),
        color: Colors.white,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      title: Text(
        "Ajouter un message au don",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    ),
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centre les widgets verticalement
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Message...",
                  labelStyle: TextStyle(color: Color(0xFFD9A9A9)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color(0xFFD9A9A9)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color(0xFFD9A9A9)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color(0xFFD9A9A9)),
                  ),
                ),
                maxLines: 3,
                onSaved: (value) {
                  _message = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _enregistrerDon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD9A9A9),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text("Enregistrer le don", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}
