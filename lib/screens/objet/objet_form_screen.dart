import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:uuid/uuid.dart'; // Importation de la bibliothèque UUID
//import 'dart:io' if (dart.library.html) 'dart:html'; // Importation conditionnelle pour mobile et web
import 'package:flutter/foundation.dart'; // Pour kIsWeb (vérification de la plateforme)
import 'package:swapngive/models/Categorie.dart'; // Modèle Categorie
import 'package:swapngive/models/etat.dart'; // Modèle Etat
import 'package:swapngive/models/objet.dart'; // Modèle Objet
import 'package:swapngive/services/auth_service.dart'; // Service d'authentification
import 'package:swapngive/services/categorie_service.dart'; // Service de gestion des catégories
import 'package:swapngive/services/etat_service.dart'; // Service de gestion des états
import 'package:swapngive/services/objet_service.dart'; // Service de gestion des objets
import 'dart:io'; // Utilisation pour mobile et desktop


class ObjetFormScreen extends StatefulWidget {
  final Objet? objet;

  ObjetFormScreen({this.objet});

  @override
  _ObjetFormScreenState createState() => _ObjetFormScreenState();
}

class _ObjetFormScreenState extends State<ObjetFormScreen> {
  final ObjetService _objetService = ObjetService();
  final EtatService _etatService = EtatService();
  final CategorieService _categorieService = CategorieService();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  List<File> _imageFiles = []; // Liste pour stocker plusieurs images locales sur mobile
  List<String> _imageUrls = []; // Liste pour stocker les images du web

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
      if (kIsWeb) {
        setState(() {
          _imageUrls = pickedFiles.map((file) => file.path).toList(); // Gestion Web (URL des images)
        });
      } else {
        setState(() {
          _imageFiles = pickedFiles.map((file) => File(file.path)).toList(); // Gestion mobile (fichiers locaux)
        });
      }
    }
  }

  Future<void> _addOrUpdateObjet() async {
    if (_selectedEtat != null && _selectedCategorie != null && _currentUser != null) {
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

      try {
        List<File> filesToUpload = kIsWeb ? [] : _imageFiles.whereType<File>().toList();

        if (widget.objet == null) {
          await _objetService.addObjetWithImageFiles(objet, filesToUpload);
        } else {
          await _objetService.updateObjetWithImageFiles(objet, filesToUpload);
        }

        Navigator.pop(context); // Fermer l'écran après l'ajout ou la mise à jour
      } catch (e) {
        print('Erreur lors de l\'ajout ou de la mise à jour de l\'objet : $e');
      }
    } else {
      print('Veuillez compléter tous les champs requis.');
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.objet == null ? 'Ajouter un Objet' : 'Modifier l\'Objet'),
      backgroundColor: Color(0xFFD9A9A9), // Couleur du fond de l'AppBar
      foregroundColor: Colors.white, // Couleur du texte de l'AppBar
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView( // Ajout pour permettre le scroll si le contenu dépasse
        child: Column(
          children: [
            // Champ de saisie pour le nom avec bordure arrondie
            TextField(
              controller: _nomController,
              decoration: InputDecoration(
                labelText: 'Nom',
                labelStyle: TextStyle(
                  color: Color(0xFFD9A9A9), // Couleur de l'étiquette
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9A9A9), width: 2.0), // Couleur de la bordure focale
                  borderRadius: BorderRadius.circular(8.0), // Bordure arrondie
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey), // Bordure par défaut
                  borderRadius: BorderRadius.circular(8.0), // Bordure arrondie
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Champ de saisie pour la description avec bordure arrondie
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Color(0xFFD9A9A9)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9A9A9), width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Dropdown pour l'état avec bordure arrondie
            DropdownButtonFormField<Etat>(
              value: _selectedEtat,
              hint: Text('Sélectionnez un état'),
              items: _etats.map<DropdownMenuItem<Etat>>((etat) {
                return DropdownMenuItem<Etat>(
                  value: etat,
                  child: Text(etat.nom),
                );
              }).toList(),
              onChanged: (Etat? newValue) {
                setState(() {
                  _selectedEtat = newValue;
                });
              },
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9A9A9), width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Dropdown pour la catégorie avec bordure arrondie
            DropdownButtonFormField<Categorie>(
              value: _selectedCategorie,
              hint: Text('Sélectionnez une catégorie'),
              items: _categories.map<DropdownMenuItem<Categorie>>((categorie) {
                return DropdownMenuItem<Categorie>(
                  value: categorie,
                  child: Text(categorie.nom),
                );
              }).toList(),
              onChanged: (Categorie? newValue) {
                setState(() {
                  _selectedCategorie = newValue;
                });
              },
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9A9A9), width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            
            // Bouton pour choisir des images avec bordure en pointillés
           GestureDetector(
  onTap: _pickImages,
  child: Container(
    width: double.infinity,
    height: 150,
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.grey,
        width: 2.0,
        // style: BorderStyle.solid, // Tu peux retirer cette ligne car c'est le style par défaut
      ),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Center(
      child: Text(
        'Choisir plusieurs images',
        style: TextStyle(color: Color(0xFFD9A9A9)),
      ),
    ),
  ),
),

            
            // Affichage des images sélectionnées
            SizedBox(height: 20),
            if (kIsWeb)
              _imageUrls.isNotEmpty
                  ? Wrap(
                      spacing: 10,
                      children: _imageUrls.map((imageUrl) {
                        return Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                        );
                      }).toList(),
                    )
                  : Text('Aucune image sélectionnée')
            else
              _imageFiles.isNotEmpty
                  ? Wrap(
                      spacing: 10,
                      children: _imageFiles.map((imageFile) {
                        return Image.file(
                          imageFile,
                          width: 100,
                          height: 100,
                        );
                      }).toList(),
                    )
                  : Text('Aucune image sélectionnée'),
            
            SizedBox(height: 20),
            
            // Bouton pour ajouter ou mettre à jour l'objet
            ElevatedButton(
              onPressed: _addOrUpdateObjet,
              child: Text(widget.objet == null ? 'Ajouter Objet' : 'Mettre à jour Objet'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Color(0xFFD9A9A9),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
