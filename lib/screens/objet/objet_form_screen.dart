import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

  String? _selectedEtat;
  List<Etat> _etats = [];

  String? _selectedCategorie;
  List<Categorie> _categories = [];

  User? _currentUser;

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
      _selectedEtat = widget.objet!.idEtat;
      _selectedCategorie = widget.objet!.idCategorie;
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
  void _getCurrentUser() {
    setState(() {
      _currentUser = _authService.getCurrentUser();
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
        idEtat: _selectedEtat!,
        idCategorie: _selectedCategorie!,
        dateAjout: DateTime.now(),
        idUtilisateur: _currentUser!.uid, // ID de l'utilisateur connecté
        imageUrl: widget.objet?.imageUrl ?? '', // URL de l'image
      );

      if (widget.objet == null) {
        await _objetService.addObjet(objet, _imageFile!); // Ajout d'un nouvel objet
      } else {
        await _objetService.updateObjet(objet, _imageFile!); // Mise à jour de l'objet existant
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
            DropdownButton<String>(
              value: _selectedEtat,
              hint: Text('Sélectionnez un état'),
              items: _etats.map((etat) {
                return DropdownMenuItem<String>(
                  value: etat.id,
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
            DropdownButton<String>(
              value: _selectedCategorie,
              hint: Text('Sélectionnez une catégorie'),
              items: _categories.map((categorie) {
                return DropdownMenuItem<String>(
                  value: categorie.id,
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
