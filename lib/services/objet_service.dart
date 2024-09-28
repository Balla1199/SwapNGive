import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:swapngive/models/objet.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/services/auth_service.dart'; // Importez AuthService

class ObjetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService(); // Instance de AuthService

  /// Ajouter un nouvel objet avec plusieurs images
  Future<void> addObjetWithImages(Objet objet, List<html.File> imageFiles) async {
    try {
      if (imageFiles.isEmpty) {
        throw Exception('Aucune image fournie.');
      }

      // Récupérer les informations de l'utilisateur actuel
      Utilisateur? currentUser = await _authService.getCurrentUserDetails();
      if (currentUser == null) {
        throw Exception('Aucun utilisateur connecté.');
      }

      // Créer un nouvel objet en utilisant les détails de l'utilisateur
      objet.utilisateur = currentUser; // Inclure l'utilisateur complet
      objet.dateAjout = DateTime.now(); // Assigner la date d'ajout si ce n'est pas déjà fait

      // Liste pour stocker les URLs des images
      List<String> imageUrls = [];

      // Télécharger chaque image et récupérer son URL
      for (var imageFile in imageFiles) {
        // Créer une référence pour l'image dans Firebase Storage
        final imageRef = _storage.ref().child('images/${objet.id}/${imageFile.name}');

        // Créer un blob à partir du fichier image
        final reader = html.FileReader();
        reader.readAsArrayBuffer(imageFile);
        await reader.onLoadEnd.first;

        final bytes = reader.result as Uint8List;

        // Télécharger l'image dans Firebase Storage
        await imageRef.putData(bytes);
        final imageUrl = await imageRef.getDownloadURL();

        // Ajouter l'URL à la liste
        imageUrls.add(imageUrl);
      }

      // Ajouter les URLs des images à l'objet
      objet.imageUrl = imageUrls.join(','); // Par exemple, stocker sous forme de chaîne séparée par des virgules

      // Ajouter l'objet à Firestore avec tous les détails
      await _firestore.collection('objets').doc(objet.id).set(objet.toMap());
      print('Objet ajouté avec succès avec plusieurs images.');
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'objet: $e');
      rethrow; // Relancer pour gérer ailleurs si nécessaire
    }
  }

  // Modifier un objet
  Future<void> updateObjet(Objet objet, [html.File? imageFile]) async {
    try {
      if (imageFile != null) {
        // Créer une référence pour l'image dans Firebase Storage
        final imageRef = _storage.ref().child('images/${objet.id}');

        // Créer un blob à partir du fichier image
        final reader = html.FileReader();
        reader.readAsArrayBuffer(imageFile);
        await reader.onLoadEnd.first;

        final bytes = reader.result as Uint8List;

        // Télécharger la nouvelle image dans Firebase Storage
        await imageRef.putData(bytes);
        final imageUrl = await imageRef.getDownloadURL();

        // Mettre à jour l'URL de l'image dans l'objet
        objet.imageUrl = imageUrl;
      }

      // Mettre à jour l'objet dans Firestore
      await _firestore.collection('objets').doc(objet.id).update(objet.toMap());
      print('Objet mis à jour avec succès.');
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'objet: $e');
      rethrow; // Relancer pour gérer ailleurs si nécessaire
    }
  }

  // Méthode pour mettre à jour un objet avec plusieurs images
  Future<void> updateObjetWithImages(Objet objet, List<html.File> imageFiles) async {
    try {
      // Liste pour stocker les URLs des nouvelles images
      List<String> imageUrls = [];

      // Télécharger chaque image et récupérer son URL
      for (var imageFile in imageFiles) {
        // Créer une référence pour l'image dans Firebase Storage
        final imageRef = _storage.ref().child('images/${objet.id}/${imageFile.name}');

        // Créer un blob à partir du fichier image
        final reader = html.FileReader();
        reader.readAsArrayBuffer(imageFile);
        await reader.onLoadEnd.first;

        final bytes = reader.result as Uint8List;

        // Télécharger l'image dans Firebase Storage
        await imageRef.putData(bytes);
        final imageUrl = await imageRef.getDownloadURL();

        // Ajouter l'URL à la liste
        imageUrls.add(imageUrl);
      }

      // Mettre à jour l'URL des images dans l'objet
      objet.imageUrl = imageUrls.join(','); // Par exemple, stocker sous forme de chaîne séparée par des virgules

      // Mettre à jour l'objet dans Firestore
      await _firestore.collection('objets').doc(objet.id).update(objet.toMap());
      print('Objet mis à jour avec succès avec plusieurs images.');
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'objet avec images: $e');
      rethrow; // Relancer pour gérer ailleurs si nécessaire
    }
  }

  // Récupérer un objet par ID
  Future<Objet?> getObjetById(String id) async {
    try {
      final doc = await _firestore.collection('objets').doc(id).get();
      if (doc.exists) {
        return Objet.fromMap(doc.data()!);
      } else {
        print('Objet non trouvé.');
        return null;
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'objet: $e');
      return null;
    }
  }

  // Récupérer tous les objets
  Future<List<Objet>> getAllObjets() async {
    try {
      final snapshot = await _firestore.collection('objets').get();
      return snapshot.docs.map((doc) => Objet.fromMap(doc.data())).toList();
    } catch (e) {
      print('Erreur lors de la récupération des objets: $e');
      return [];
    }
  }

  // Supprimer un objet et son image associée
  Future<void> deleteObjet(String id) async {
    try {
      // Supprimer l'objet de Firestore
      await _firestore.collection('objets').doc(id).delete();

      // Supprimer l'image de Firebase Storage
      final imageRef = _storage.ref().child('images/$id');
      await imageRef.delete();

      print('Objet et image supprimés avec succès.');
    } catch (e) {
      print('Erreur lors de la suppression de l\'objet: $e');
    }
  }

  // Télécharger une image et retourner l'URL
  Future<String> uploadImage(html.File imageFile) async {
    try {
      if (imageFile == null) {
        throw Exception('Le fichier image est invalide.');
      }

      // Créer une référence pour l'image dans Firebase Storage
      final imageRef = _storage.ref().child('images/${imageFile.name}');

      // Créer un blob à partir du fichier image
      final reader = html.FileReader();
      reader.readAsArrayBuffer(imageFile);
      await reader.onLoadEnd.first;

      final bytes = reader.result as Uint8List;

      // Télécharger l'image dans Firebase Storage
      await imageRef.putData(bytes);

      // Obtenir l'URL de l'image téléchargée
      final imageUrl = await imageRef.getDownloadURL();

      return imageUrl;
    } catch (e) {
      print('Erreur lors du téléchargement de l\'image: $e');
      rethrow;
    }
  }

  // Flux pour récupérer tous les objets
  Stream<List<Objet>> getAllObjetsStream() {
    return _firestore.collection('objets').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Objet.fromMap(doc.data())).toList();
    });
  }
}
