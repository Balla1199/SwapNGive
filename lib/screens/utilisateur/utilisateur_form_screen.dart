import 'package:flutter/material.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/services/utilisateur_service.dart';

class UtilisateurFormScreen extends StatefulWidget {
  final Utilisateur? utilisateur;

  UtilisateurFormScreen({this.utilisateur});

  @override
  _UtilisateurFormScreenState createState() => _UtilisateurFormScreenState();
}

class _UtilisateurFormScreenState extends State<UtilisateurFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _nom, _email, _motDePasse, _adresse, _telephone;
  Role _role = Role.client;

  @override
  void initState() {
    super.initState();
    if (widget.utilisateur != null) {
      _nom = widget.utilisateur!.nom;
      _email = widget.utilisateur!.email;
      _motDePasse = ''; // Ne pas pré-remplir le mot de passe pour des raisons de sécurité
      _adresse = widget.utilisateur!.adresse;
      _telephone = widget.utilisateur!.telephone;
      _role = widget.utilisateur!.role;
    } else {
      _nom = '';
      _email = '';
      _motDePasse = '';
      _adresse = '';
      _telephone = '';
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Utilisateur utilisateur = Utilisateur(
        id: widget.utilisateur?.id ?? DateTime.now().toString(),
        nom: _nom,
        email: _email,
        motDePasse: _motDePasse, // Ce champ peut être ignoré lors de l'enregistrement dans Firestore
        adresse: _adresse,
        telephone: _telephone,
        dateInscription: widget.utilisateur?.dateInscription ?? DateTime.now(),
        role: _role,
      );

      if (widget.utilisateur == null) {
        // Créer un nouvel utilisateur dans Firebase Auth et Firestore
        try {
          await UtilisateurService().createUtilisateur(utilisateur, _email, _motDePasse);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Utilisateur créé avec succès')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
        }
      } else {
        // Mettre à jour l'utilisateur existant dans Firestore
        await UtilisateurService().updateUtilisateur(widget.utilisateur!.id, utilisateur);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Utilisateur mis à jour avec succès')));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.utilisateur == null ? 'Créer un utilisateur' : 'Modifier un utilisateur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _nom,
                decoration: InputDecoration(labelText: 'Nom'),
                onSaved: (value) => _nom = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'Email'),
                onSaved: (value) => _email = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un email';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mot de passe'),
                onSaved: (value) => _motDePasse = value!,
                validator: (value) {
                  if (widget.utilisateur == null && (value == null || value.isEmpty)) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  return null;
                },
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
              DropdownButtonFormField<Role>(
                value: _role,
                onChanged: (Role? newValue) {
                  setState(() {
                    _role = newValue!;
                  });
                },
                items: Role.values.map((Role role) {
                  return DropdownMenuItem<Role>(
                    value: role,
                    child: Text(role.toString().split('.').last),
                  );
                }).toList(),
              ),
              ElevatedButton(
                onPressed: _saveForm,
                child: Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
