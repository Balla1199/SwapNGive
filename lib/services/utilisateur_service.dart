import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Ajouté pour gérer Firebase Storage
import 'package:flutter/foundation.dart';
import 'dart:io'; // Pour gérer le fichier image localement
import 'package:swapngive/models/utilisateur.dart';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;

class UtilisateurService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('utilisateurs');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Instance de Firebase Storage

  // Créer un utilisateur dans Firebase Authentication et Firestore
  Future<void> createUtilisateur(Utilisateur utilisateur, String email, String password) async {
    try {
      // Créer l'utilisateur dans Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si l'utilisateur est créé avec succès dans Auth, on l'ajoute dans Firestore
      utilisateur.id = userCredential.user!.uid; // Associer l'ID de l'utilisateur à partir de Firebase Auth
      await _collection.doc(utilisateur.id).set(utilisateur.toMap());

      print('Utilisateur créé avec succès dans Auth et Firestore');
    } catch (e) {
      print('Erreur lors de la création de l\'utilisateur : $e');
      throw e; // Pour renvoyer l'erreur à l'appelant
    }
  }

  // Connexion d'un utilisateur via Firebase Authentication
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Erreur lors de la connexion de l\'utilisateur : $e');
      return null;
    }
  }

  // Déconnexion de l'utilisateur
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('Déconnexion réussie');
    } catch (e) {
      print('Erreur lors de la déconnexion : $e');
    }
  }

  // Récupérer tous les utilisateurs depuis Firestore
  Stream<List<Utilisateur>> getUtilisateurs() {
    return _collection.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Utilisateur.fromFirestore(doc))
        .toList());
  }

  // Mettre à jour un utilisateur dans Firestore
  Future<void> updateUtilisateur(String id, Utilisateur utilisateur) async {
    await _collection.doc(id).update(utilisateur.toMap());
  }

  // Supprimer un utilisateur dans Firestore
  Future<void> deleteUtilisateur(String id) async {
    // Supprimer l'utilisateur dans Firebase Auth et Firestore
    try {
      // Supprimer de Firestore
      await _collection.doc(id).delete();
      print('Utilisateur supprimé de Firestore');

      // Supprimer de Firebase Authentication
      User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
        print('Utilisateur supprimé de Firebase Authentication');
      }
    } catch (e) {
      print('Erreur lors de la suppression de l\'utilisateur : $e');
      throw e;
    }
  }

  // Récupérer l'utilisateur actuel
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Récupérer un utilisateur par ID
  Future<Utilisateur?> getUtilisateurById(String id) async {
    try {
      DocumentSnapshot doc = await _collection.doc(id).get();
      if (doc.exists) {
        return Utilisateur.fromFirestore(doc);
      }
      return null; // Si l'utilisateur n'existe pas
    } catch (e) {
      print("Erreur lors de la récupération de l'utilisateur par ID : $e");
      return null;
    }
  }

  // Méthode pour récupérer la photo de profil depuis Firestore
  Future<String?> getProfilePhotoUrl(String userId) async {
    try {
      DocumentSnapshot doc = await _collection.doc(userId).get();
      if (doc.exists) {
        final utilisateur = Utilisateur.fromFirestore(doc);
        print('URL de la photo de profil récupérée : ${utilisateur.photoProfil}'); // Log de l'URL de la photo
        return utilisateur.photoProfil; // Retourne l'URL de la photo de profil
      }
      print('Utilisateur non trouvé pour l\'ID : $userId');
      return null; // Si l'utilisateur n'existe pas
    } catch (e) {
      print("Erreur lors de la récupération de la photo de profil : $e");
      return null;
    }
  }

  Future<void> updateProfileWithPhoto(String userId, Utilisateur utilisateur, {File? newPhotoFile, html.File? webPhotoFile}) async {
    try {
      String downloadUrl;

      if (kIsWeb) {
        // Cas pour le web
        if (webPhotoFile != null) {
          // Lire le fichier web et convertir en base64
          final reader = html.FileReader();
          reader.readAsDataUrl(webPhotoFile);
          
          // Attendre que la lecture soit terminée
          await reader.onLoad.first;

          // Récupérer l'image en base64
          final String base64Image = reader.result as String;
          print('Image en base64 lue : $base64Image'); // Log de l'image en base64

          // Supprimer le préfixe de base64 (e.g., "data:image/png;base64,")
          List<int> imageBytes = base64Decode(base64Image.split(',')[1]);
          print('Image convertie en bytes, longueur : ${imageBytes.length}'); // Log de la longueur des bytes

          String filePath = 'profilePhotos/$userId/${DateTime.now().millisecondsSinceEpoch}.png';
          final metadata = SettableMetadata(contentType: 'image/png');

          // Upload l'image dans Firebase Storage
          UploadTask uploadTask = _storage.ref().child(filePath).putData(Uint8List.fromList(imageBytes), metadata);
          print('Upload en cours vers $filePath'); // Log de l'upload

          // Attendre que l'upload soit terminé et récupérer l'URL de téléchargement
          TaskSnapshot snapshot = await uploadTask;
          downloadUrl = await snapshot.ref.getDownloadURL();
          print('URL de téléchargement obtenue : $downloadUrl'); // Log de l'URL de téléchargement
        } else {
          throw Exception("Aucune image fournie pour la mise à jour du profil.");
        }
      } else {
        // Cas pour mobile
        if (newPhotoFile != null) {
          String filePath = 'profilePhotos/$userId/${DateTime.now().millisecondsSinceEpoch}.png';
          UploadTask uploadTask = _storage.ref().child(filePath).putFile(newPhotoFile);

          // Attendre que l'upload se termine
          TaskSnapshot snapshot = await uploadTask;

          // Récupérer l'URL de l'image uploadée
          downloadUrl = await snapshot.ref.getDownloadURL();
          print('URL de téléchargement obtenue : $downloadUrl'); // Log de l'URL de téléchargement
        } else {
          throw Exception("Aucune image fournie pour la mise à jour du profil.");
        }
      }

      // 4. Mettre à jour l'utilisateur avec la nouvelle URL de photo
      utilisateur.photoProfil = downloadUrl; // Mettre à jour l'URL de la photo de profil
      await _collection.doc(userId).update(utilisateur.toMap());

      print('Profil mis à jour avec succès avec la nouvelle photo de profil');
    } catch (e) {
      print('Erreur lors de la mise à jour du profil avec la photo : $e');
      throw e;
    }
  }
}
