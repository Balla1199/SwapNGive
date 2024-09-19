import 'package:flutter/material.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/services/utilisateur_service.dart'; // Assurez-vous que ce chemin est correct

class AddUserScreen extends StatefulWidget {
  final Utilisateur? utilisateur; // Utilisateur à modifier, peut être null pour un nouvel utilisateur

  AddUserScreen({this.utilisateur});

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _utilisateurService = UtilisateurService();

  late Utilisateur _utilisateur;
  late TextEditingController _nomController;
  late TextEditingController _emailController;
  late TextEditingController _motDePasseController;
  late TextEditingController _adresseController;
  late TextEditingController _telephoneController;

  @override
  void initState() {
    super.initState();
    _utilisateur = widget.utilisateur ?? Utilisateur(
      id: '', // id temporaire, sera généré lors de la création
      nom: '',
      email: '',
      motDePasse: '',
      adresse: '',
      telephone: '',
      dateInscription: DateTime.now(),
      role: '',
    );

    _nomController = TextEditingController(text: _utilisateur.nom);
    _emailController = TextEditingController(text: _utilisateur.email);
    _motDePasseController = TextEditingController(text: _utilisateur.motDePasse);
    _adresseController = TextEditingController(text: _utilisateur.adresse);
    _telephoneController = TextEditingController(text: _utilisateur.telephone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.utilisateur == null ? 'Ajouter un utilisateur' : 'Modifier un utilisateur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom'),
                validator: (value) => value?.isEmpty ?? true ? 'Entrez un nom' : null,
                onSaved: (value) => _utilisateur.nom = value!,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) => value?.isEmpty ?? true ? 'Entrez un email' : null,
                onSaved: (value) => _utilisateur.email = value!,
              ),
              TextFormField(
                controller: _motDePasseController,
                decoration: InputDecoration(labelText: 'Mot de passe'),
                validator: (value) => value?.isEmpty ?? true ? 'Entrez un mot de passe' : null,
                onSaved: (value) => _utilisateur.motDePasse = value!,
              ),
              TextFormField(
                controller: _adresseController,
                decoration: InputDecoration(labelText: 'Adresse'),
                validator: (value) => value?.isEmpty ?? true ? 'Entrez une adresse' : null,
                onSaved: (value) => _utilisateur.adresse = value!,
              ),
              TextFormField(
                controller: _telephoneController,
                decoration: InputDecoration(labelText: 'Téléphone'),
                validator: (value) => value?.isEmpty ?? true ? 'Entrez un numéro de téléphone' : null,
                onSaved: (value) => _utilisateur.telephone = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.utilisateur == null ? 'Ajouter' : 'Modifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.utilisateur == null) {
        // Ajouter un nouvel utilisateur
        _utilisateur.id = DateTime.now().toString(); // Générer un ID temporaire
        _utilisateurService.creerUtilisateur(_utilisateur);
      } else {
        // Modifier un utilisateur existant
        _utilisateurService.modifierUtilisateur(_utilisateur);
      }

      Navigator.pop(context);
    }
  }
}
