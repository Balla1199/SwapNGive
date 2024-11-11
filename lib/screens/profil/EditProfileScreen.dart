import 'package:flutter/material.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/services/utilisateur_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Utilisateur? utilisateur;

  const EditProfileScreen({Key? key, required this.utilisateur}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _nom;
  late String _email;
  late String _motDePasse;
  late String _adresse;
  late String _telephone;

  final UtilisateurService _utilisateurService = UtilisateurService();

  @override
  void initState() {
    super.initState();

    // Handle the null case
    if (widget.utilisateur != null) {
      _nom = widget.utilisateur!.nom;
      _email = widget.utilisateur!.email;
      _motDePasse = widget.utilisateur!.motDePasse;
      _adresse = widget.utilisateur!.adresse;
      _telephone = widget.utilisateur!.telephone;
    } else {
      _nom = '';
      _email = '';
      _motDePasse = '';
      _adresse = '';
      _telephone = '';
    }
  }

  void _saveProfileChanges() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (widget.utilisateur != null) {
        // Update user data
        Utilisateur utilisateur = widget.utilisateur!;
        utilisateur.nom = _nom;
        utilisateur.email = _email;
        utilisateur.motDePasse = _motDePasse;
        utilisateur.adresse = _adresse;
        utilisateur.telephone = _telephone;

        try {
          await _utilisateurService.updateUtilisateur(utilisateur.id!, utilisateur);
          print('Profil mis à jour avec succès');
          Navigator.pop(context);
        } catch (e) {
          print('Erreur lors de la mise à jour du profil : $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Erreur lors de la mise à jour du profil")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _nom,
                decoration: InputDecoration(labelText: 'Nom'),
                onSaved: (value) => _nom = value!,
              ),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'Email'),
                onSaved: (value) => _email = value!,
              ),
              TextFormField(
                initialValue: _motDePasse,
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                onSaved: (value) => _motDePasse = value!,
              ),
              TextFormField(
                initialValue: _adresse,
                decoration: InputDecoration(labelText: 'Adresse'),
                onSaved: (value) => _adresse = value!,
              ),
              TextFormField(
                initialValue: _telephone,
                decoration: InputDecoration(labelText: 'Téléphone'),
                onSaved: (value) => _telephone = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfileChanges,
                child: Text('Sauvegarder'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
