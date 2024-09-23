import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/services/annonceservice.dart';
import 'package:swapngive/screens/annonce/annonce_list_screen.dart'; 

class AnnonceFormScreen extends StatefulWidget {
  final Objet objet; // Objet à partir duquel l'annonce est créée
  final Annonce? annonce; // Annonce à modifier (si applicable)

  AnnonceFormScreen({required this.objet, this.annonce}); // Constructeur

  @override
  _AnnonceFormScreenState createState() => _AnnonceFormScreenState();
}

class _AnnonceFormScreenState extends State<AnnonceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titreController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _type; // Don ou Échange

  final AnnonceService _annonceService = AnnonceService();

  @override
  void initState() {
    super.initState();
    // Pré-remplir les champs si l'annonce est fournie
    if (widget.annonce != null) {
      _titreController.text = widget.annonce!.titre;
      _descriptionController.text = widget.annonce!.description;
      _type = widget.annonce!.type == TypeAnnonce.don ? 'Don' : 'Échange';
    } else {
      // Pré-remplir la description à partir de l'objet
      _descriptionController.text = widget.objet.description;
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Méthode pour soumettre le formulaire et ajouter ou modifier une annonce
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Annonce newAnnonce = Annonce(
        id: widget.annonce != null ? widget.annonce!.id : FirebaseFirestore.instance.collection('annonces').doc().id,
        titre: _titreController.text,
        description: _descriptionController.text,
        date: DateTime.now(),
        type: _type == 'Don' ? TypeAnnonce.don : TypeAnnonce.echange,
        utilisateur: widget.objet.utilisateur,
        categorie: widget.objet.categorie,
        objet: widget.objet,
      );

      try {
        if (widget.annonce == null) {
          await _annonceService.ajouterAnnonce(newAnnonce);
        } else {
          await _annonceService.modifierAnnonce(newAnnonce); // Ajoutez cette méthode pour modifier l'annonce
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Annonce ${widget.annonce == null ? "ajoutée" : "modifiée"} avec succès !')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AnnonceListScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.annonce == null ? 'Créer une annonce' : 'Modifier l\'annonce'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Champ Titre
              TextFormField(
                controller: _titreController,
                decoration: InputDecoration(labelText: 'Titre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un titre';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Champ Description (modifiable)
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Sélecteur Type (Don ou Échange)
              DropdownButtonFormField<String>(
                value: _type,
                decoration: InputDecoration(labelText: 'Type'),
                items: ['Don', 'Échange'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _type = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez sélectionner un type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),

              // Bouton de soumission
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Créer l\'annonce'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
