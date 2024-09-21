import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:uuid/uuid.dart'; // Importation de la bibliothèque UUID
import 'dart:html' as html; // Importez dart:html pour le web

import 'package:firebase_auth/firebase_auth.dart'; // Pour l'utilisateur connecté
import 'package:swapngive/models/Categorie.dart'; // Modèle Categorie
import 'package:swapngive/models/etat.dart'; // Modèle Etat
import 'package:swapngive/models/objet.dart'; // Modèle Objet
import 'package:swapngive/services/auth_service.dart'; // Service d'authentification
import 'package:swapngive/services/categorie_service.dart'; // Service de gestion des catégories
import 'package:swapngive/services/etat_service.dart'; // Service de gestion des états
import 'package:swapngive/services/objet_service.dart'; // Service de gestion des objets

class ObjetFormScreen extends StatefulWidget {
  final Objet? objet; // Paramètre facultatif pour l'objet à modifier

  ObjetFormScreen({this.objet}); // Constructeur acceptant l'objet

  @override
  _ObjetFormScreenState createState() => _ObjetFormScreenState();
}

class _ObjetFormScreenState extends State<ObjetFormScreen> {
  final ObjetService _objetService = ObjetService();
  final EtatService _etatService = EtatService();
  final CategorieService _categorieService = CategorieService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  html.File? _imageFile; // Utilisez html.File pour le web

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Etat? _selectedEtat; // Utiliser l'objet Etat au lieu de l'ID
  List<Etat> _etats = [];

  Categorie? _selectedCategorie; // Utiliser l'objet Categorie au lieu de l'ID
  List<Categorie> _categories = [];

  Utilisateur? _currentUser; // Changez User en Utilisateur

  final Uuid uuid = Uuid(); // Initialisation de la classe UUID

  @override
  void initState() {
    super.initState();
    _loadEtats(); // Charger les états
    _loadCategories(); // Charger les catégories
    _getCurrentUser(); // Charger l'utilisateur connecté
    _initializeForm(); // Initialiser le formulaire avec les données existantes si disponibles
  }

  void _initializeForm() {
    if (widget.objet != null) {
      _nomController.text = widget.objet!.nom;
      _descriptionController.text = widget.objet!.description;
      _selectedEtat = widget.objet!.etat; // Utiliser l'objet Etat
      _selectedCategorie = widget.objet!.categorie; // Utiliser l'objet Categorie
      
      // Impression des valeurs de l'objet
      print('Objet existant chargé:');
      print('Nom: ${widget.objet!.nom}');
      print('Description: ${widget.objet!.description}');
      print('État: ${_selectedEtat?.nom}');
      print('Catégorie: ${_selectedCategorie?.nom}');
    }
  }

  // Charger les états depuis Firestore
  void _loadEtats() {
    _etatService.getEtats().listen((etats) {
      setState(() {
        _etats = etats;
      });
    });
  }

  // Charger les catégories depuis Firestore
  void _loadCategories() async {
    List<Categorie> categories = await _categorieService.getToutesCategories();
    setState(() {
      _categories = categories;
    });
  }

  // Récupérer l'utilisateur actuellement connecté
  void _getCurrentUser() async {
    Utilisateur? user = await _authService.getCurrentUserDetails(); // Utiliser la méthode pour récupérer les détails
    setState(() {
      _currentUser = user;
    });
  }

  // Méthode pour choisir une image depuis la galerie
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final file = html.File([bytes], pickedFile.name);
      setState(() {
        _imageFile = file;
      });
    }
  }

  // Ajouter ou mettre à jour un objet
  Future<void> _addOrUpdateObjet() async {
    if (_selectedEtat != null && _selectedCategorie != null && _imageFile != null && _currentUser != null) {
      final objet = Objet(
        id: widget.objet?.id ?? uuid.v4(), // Utilisation de UUID pour générer un nouvel ID
        nom: _nomController.text,
        description: _descriptionController.text,
        etat: _selectedEtat!, // Utiliser l'objet Etat
        categorie: _selectedCategorie!, // Utiliser l'objet Categorie
        dateAjout: DateTime.now(),
        utilisateur: _currentUser!, // Utilisateur connecté
        imageUrl: widget.objet?.imageUrl ?? '', // URL de l'image
      );

      // Impression des valeurs de l'objet avant ajout ou mise à jour
      print('Objet à ajouter ou mettre à jour:');
      print('ID: ${objet.id}');
      print('Nom: ${objet.nom}');
      print('Description: ${objet.description}');
      print('État: ${objet.etat.nom}');
      print('Catégorie: ${objet.categorie.nom}');
      print('Utilisateur: ${objet.utilisateur.nom}'); // Assurez-vous que l'objet Utilisateur a une propriété 'nom'

      if (widget.objet == null) {
        await _objetService.addObjet(objet, _imageFile!); // Ajout d'un nouvel objet
        print('Nouvel objet ajouté.');
      } else {
        await _objetService.updateObjet(objet, _imageFile!); // Mise à jour de l'objet existant
        print('Objet mis à jour.');
      }

      Navigator.pop(context); // Retour à l'écran précédent après succès
    } else {
      print('Veuillez sélectionner un état, une catégorie, une image et être connecté.'); // Alerte si champs manquants
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
              onPressed: _pickImage,
              child: Text('Choisir une image'),
            ),
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
