import 'dart:convert';
import 'dart:io'; // Pour le mobile
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Ajouter ce package pour sélectionner des images
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/services/auth_service.dart';
import 'package:swapngive/services/utilisateur_service.dart'; // Importer le service utilisateur

class ProfileScreen extends StatefulWidget {
  final Utilisateur? utilisateur;

  const ProfileScreen({this.utilisateur});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final UtilisateurService _utilisateurService = UtilisateurService(); // Instance du service utilisateur
  final ImagePicker _picker = ImagePicker(); // Instance pour le sélecteur d'image
  File? _imageFile; // Pour stocker l'image sélectionnée
  String? _profilePhotoUrl; // Pour stocker l'URL de la photo de profil

  @override
  void initState() {
    super.initState();
    print('Page de profil initialisée');
    if (widget.utilisateur != null) {
      print('Utilisateur trouvé : ${widget.utilisateur!.nom}');
      print('Adresse de l\'utilisateur : ${widget.utilisateur!.adresse}');
      _loadProfilePhoto(); // Charger l'URL de la photo de profil
    } else {
      print('Aucun utilisateur fourni');
    }
  }

  // Méthode pour charger l'URL de la photo de profil
  Future<void> _loadProfilePhoto() async {
    String? photoUrl = await _utilisateurService.getProfilePhotoUrl(widget.utilisateur!.id);
    setState(() {
      _profilePhotoUrl = photoUrl; // Mettre à jour l'URL de la photo de profil
    });
  }

  // Méthode pour sélectionner une nouvelle photo
  Future<void> _selectImage() async {
    // Vérifier si l'application tourne sur le web ou non
    if (kIsWeb) {
      // Pour le web
      html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*'; // Accepter uniquement les images
      uploadInput.click(); // Ouvrir la boîte de dialogue pour sélectionner le fichier

      uploadInput.onChange.listen((e) async {
        final reader = html.FileReader();
        reader.readAsDataUrl(uploadInput.files![0]); // Lire le fichier sélectionné en base64

        reader.onLoadEnd.listen((e) async {
          // Récupérer l'image en base64
          String base64Image = reader.result as String;
          await _updateProfile(base64Photo: base64Image); // Mettre à jour le profil avec l'image base64
        });
      });
    } else {
      // Pour mobile
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Utilise pickImage pour sélectionner l'image
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path); // Stocker le fichier localement pour mobile
        });
        await _updateProfile(newPhotoFile: _imageFile); // Mettre à jour le profil avec l'image fichier
      }
    }
  }

  // Méthode pour mettre à jour le profil
  Future<void> _updateProfile({File? newPhotoFile, String? base64Photo}) async {
  try {
    if (newPhotoFile != null) {
      // Pour mobile
      await _utilisateurService.updateProfileWithPhoto(widget.utilisateur!.id, widget.utilisateur!, newPhotoFile: newPhotoFile);
    } else if (base64Photo != null) {
      // Pour le web
      // Convertir base64 en Uint8List
      List<int> imageBytes = base64Decode(base64Photo.split(',')[1]);
      // Créer un Blob à partir des octets
      final blob = html.Blob([Uint8List.fromList(imageBytes)], 'image/png');
      // Créer un html.File à partir du Blob
      final webPhotoFile = html.File([blob], 'profilePhoto.png', {'type': 'image/png'});

      // Appel à la méthode de mise à jour
      await _utilisateurService.updateProfileWithPhoto(widget.utilisateur!.id, widget.utilisateur!, webPhotoFile: webPhotoFile);
    } else {
      print('Aucune image à mettre à jour.');
    }

    // Mettre à jour l'interface utilisateur avec la nouvelle photo
    setState(() {
      if (newPhotoFile != null) {
        widget.utilisateur!.photoProfil = newPhotoFile.path; // Mettez à jour le chemin ou l'URL de la photo
      } else if (base64Photo != null) {
        widget.utilisateur!.photoProfil = base64Photo; // Mettez à jour la photo en base64
      }
    });

    // Vérifier l'URL de la photo mise à jour
    String? updatedPhotoUrl = await _utilisateurService.getProfilePhotoUrl(widget.utilisateur!.id);
    print('URL de la photo de profil mise à jour : $updatedPhotoUrl'); // Log de l'URL mise à jour

  } catch (e) {
    print('Erreur lors de la mise à jour du profil : $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil de ${widget.utilisateur?.nom ?? ''}'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              backgroundImage: _profilePhotoUrl != null
                  ? NetworkImage(_profilePhotoUrl!) // Charger l'image si elle est disponible
                  : AssetImage('images/user.png') as ImageProvider, // Image par défaut si null
              radius: 50.0,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectImage, // Appeler la méthode pour sélectionner une image
              child: Text('Modifier la photo de profil'),
            ),
            SizedBox(height: 20),
            Text('Nom: ${widget.utilisateur?.nom ?? ''}'),
            Text('Adresse: ${widget.utilisateur?.adresse ?? ''}'),
            Text('Email: ${widget.utilisateur?.email ?? ''}'),
            Text('Téléphone: ${widget.utilisateur?.telephone ?? ''}'),
          ],
        ),
      ),
    );
  }
}
