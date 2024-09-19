import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:swapngive/models/Categorie.dart';

import 'package:swapngive/services/categorie_service.dart';

class CategorieFormScreen extends StatefulWidget {
  final Categorie? categorie;

  CategorieFormScreen({this.categorie});

  @override
  _CategorieFormScreenState createState() => _CategorieFormScreenState();
}

class _CategorieFormScreenState extends State<CategorieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomController = TextEditingController();
  final CategorieService _categorieService = CategorieService();

  @override
  void initState() {
    super.initState();
    if (widget.categorie != null) {
      _nomController.text = widget.categorie!.nom;
    }
  }

  Future<void> _saveCategorie() async {
    if (_formKey.currentState!.validate()) {
      final nom = _nomController.text;

      try {
        if (widget.categorie == null) {
          // Ajouter une nouvelle catégorie
          final id = FirebaseFirestore.instance.collection('categories').doc().id;
          final categorie = Categorie(id: id, nom: nom);
          await _categorieService.creerCategorie(categorie);
        } else {
          // Modifier une catégorie existante
          final categorie = Categorie(id: widget.categorie!.id, nom: nom);
          await _categorieService.modifierCategorie(categorie);
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Catégorie enregistrée avec succès'),
        ));
        Navigator.pop(context); // Retourner à la page précédente
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur lors de l\'enregistrement : $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categorie == null ? 'Ajouter une catégorie' : 'Modifier la catégorie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom de la catégorie'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCategorie,
                child: Text(widget.categorie == null ? 'Ajouter' : 'Modifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
