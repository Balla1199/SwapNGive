import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:uuid/uuid.dart'; // Importation de la bibliothèque UUID
import 'package:universal_html/html.dart' as html;

import 'package:firebase_auth/firebase_auth.dart'; // Pour l'utilisateur connecté
import 'package:swapngive/models/Categorie.dart'; // Modèle Categorie
import 'package:swapngive/models/etat.dart'; // Modèle Etat
import 'package:swapngive/models/objet.dart'; // Modèle Objet
import 'package:swapngive/services/auth_service.dart'; // Service d'authentification
import 'package:swapngive/services/categorie_service.dart'; // Service de gestion des catégories
import 'package:swapngive/services/etat_service.dart'; // Service de gestion des états
import 'package:swapngive/services/objet_service.dart'; // Service de gestion des objets

class ObjetFormScreen extends StatefulWidget {
  final Objet? objet; // Changement ici pour rendre l'objet optionnel

  ObjetFormScreen({this.objet}); // Changement ici

  @override
  _ObjetFormScreenState createState() => _ObjetFormScreenState();
}

class _ObjetFormScreenState extends State<ObjetFormScreen> {
  final ObjetService _objetService = ObjetService();
  final EtatService _etatService = EtatService();
  final CategorieService _categorieService = CategorieService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  List<html.File> _imageFiles = []; // Liste pour stocker plusieurs images

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Etat? _selectedEtat;
  List<Etat> _etats = [];

  Categorie? _selectedCategorie;
  List<Categorie> _categories = [];

  Utilisateur? _currentUser;

  final Uuid uuid = Uuid();

  @override
  void initState() {
    super.initState();
    _loadEtats();
    _loadCategories();
    _getCurrentUser();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.objet != null) {
      _nomController.text = widget.objet!.nom;
      _descriptionController.text = widget.objet!.description;
      _selectedEtat = widget.objet!.etat;
      _selectedCategorie = widget.objet!.categorie;
    }
  }

  void _loadEtats() {
    _etatService.getEtats().listen((etats) {
      setState(() {
        _etats = etats;
      });
    });
  }

  void _loadCategories() async {
    List<Categorie> categories = await _categorieService.getToutesCategories();
    setState(() {
      _categories = categories;
    });
  }

  void _getCurrentUser() async {
    Utilisateur? user = await _authService.getCurrentUserDetails();
    setState(() {
      _currentUser = user;
    });
  }

  // Méthode pour choisir plusieurs images depuis la galerie
  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null) {
      List<html.File> imageFiles = [];

      for (var file in pickedFiles) {
        final bytes = await file.readAsBytes(); // Lire les bytes de manière asynchrone
        imageFiles.add(html.File([bytes], file.name));
      }

      setState(() {
        _imageFiles = imageFiles;
      });
    }
  }

  Future<void> _addOrUpdateObjet() async {
    if (_selectedEtat != null && _selectedCategorie != null && _imageFiles.isNotEmpty && _currentUser != null) {
      final objet = Objet(
        id: widget.objet?.id ?? uuid.v4(),
        nom: _nomController.text,
        description: _descriptionController.text,
        etat: _selectedEtat!,
        categorie: _selectedCategorie!,
        dateAjout: DateTime.now(),
        utilisateur: _currentUser!,
        imageUrl: widget.objet?.imageUrl ?? '',
      );

      if (widget.objet == null) {
        await _objetService.addObjetWithImages(objet, _imageFiles);
        print('Nouvel objet ajouté avec plusieurs images.');
      } else {
        await _objetService.updateObjetWithImages(objet, _imageFiles);
        print('Objet mis à jour avec plusieurs images.');
      }

      Navigator.pop(context);
    } else {
      print('Veuillez sélectionner un état, une catégorie, plusieurs images et être connecté.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.objet == null ? 'Ajouter un Objet' : 'Modifier l\'Objet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 20),
            DropdownButton<Etat>(
              value: _selectedEtat,
              hint: Text('Sélectionnez un état'),
              items: _etats.map((etat) {
                return DropdownMenuItem<Etat>(
                  value: etat,
                  child: Text(etat.nom),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEtat = value;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButton<Categorie>(
              value: _selectedCategorie,
              hint: Text('Sélectionnez une catégorie'),
              items: _categories.map((categorie) {
                return DropdownMenuItem<Categorie>(
                  value: categorie,
                  child: Text(categorie.nom),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategorie = value;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImages,
              child: Text('Choisir plusieurs images'),
            ),
            SizedBox(height: 20),
            _imageFiles.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    children: _imageFiles.map((imageFile) {
                      return Image.network(
                        html.Url.createObjectUrl(imageFile),
                        width: 100,
                        height: 100,
                      );
                    }).toList(),
                  )
                : Text('Aucune image sélectionnée'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addOrUpdateObjet,
              child: Text(widget.objet == null ? 'Ajouter Objet' : 'Mettre à jour Objet'),
            ),
          ],
        ),
      ),
    );
  }
}
