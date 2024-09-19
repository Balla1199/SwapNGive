import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html; // Importer dart:html pour le web
import 'dart:typed_data'; // Importer pour Uint8List

import 'package:swapngive/models/objet.dart';

class ObjetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Ajouter un nouvel objet
  Future<void> addObjet(Objet objet, html.File imageFile) async {
    try {
      if (imageFile == null) {
        throw Exception('Le fichier image est invalide.');
      }

      // Créer une référence pour l'image dans Firebase Storage
      final imageRef = _storage.ref().child('images/${objet.id}');

      // Créer un blob à partir du fichier image
      final reader = html.FileReader();
      reader.readAsArrayBuffer(imageFile);
      await reader.onLoadEnd.first;

      final bytes = reader.result as Uint8List;

      // Télécharger l'image dans Firebase Storage
      await imageRef.putData(bytes);
      final imageUrl = await imageRef.getDownloadURL();

      // Ajouter l'URL de l'image à l'objet
      final updatedObjet = Objet(
        id: objet.id,
        nom: objet.nom,
        description: objet.description,
        idEtat: objet.idEtat,
        idCategorie: objet.idCategorie,
        dateAjout: objet.dateAjout,
        idUtilisateur: objet.idUtilisateur,
        imageUrl: imageUrl,
      );

      // Ajouter l'objet à Firestore
      await _firestore.collection('objets').doc(objet.id).set(updatedObjet.toMap());
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'objet: $e');
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

        // Ajouter l'URL de la nouvelle image à l'objet
        objet = Objet(
          id: objet.id,
          nom: objet.nom,
          description: objet.description,
          idEtat: objet.idEtat,
          idCategorie: objet.idCategorie,
          dateAjout: objet.dateAjout,
          idUtilisateur: objet.idUtilisateur,
          imageUrl: imageUrl,
        );
      }

      // Mettre à jour l'objet dans Firestore
      await _firestore.collection('objets').doc(objet.id).update(objet.toMap());
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'objet: $e');
    }
  }

  // Récupérer un objet par ID
  Future<Objet?> getObjetById(String id) async {
    try {
      final doc = await _firestore.collection('objets').doc(id).get();
      if (doc.exists) {
        return Objet.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Erreur lors de la récupération de l\'objet: $e');
    }
    return null;
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
    } catch (e) {
      print('Erreur lors de la suppression de l\'objet: $e');
    }
  }
}
