import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:swapngive/models/utilisateur.dart';
import 'dart:convert';
import 'package:universal_html/html.dart' as html;

class UtilisateurService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('utilisateurs');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Créer un utilisateur dans Firebase Authentication et Firestore
  Future<void> createUtilisateur(Utilisateur utilisateur, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      utilisateur.id = userCredential.user!.uid;
      await _collection.doc(utilisateur.id).set(utilisateur.toMap());

      print('Utilisateur créé avec succès dans Auth et Firestore');
    } catch (e) {
      print('Erreur lors de la création de l\'utilisateur : $e');
      throw e;
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
    try {
      await _collection.doc(id).delete();
      print('Utilisateur supprimé de Firestore');

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
      return null;
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
        print('URL de la photo de profil récupérée : ${utilisateur.photoProfil}');
        return utilisateur.photoProfil;
      }
      print('Utilisateur non trouvé pour l\'ID : $userId');
      return null;
    } catch (e) {
      print("Erreur lors de la récupération de la photo de profil : $e");
      return null;
    }
  }

  Future<void> updateProfileWithPhoto(String userId, Utilisateur utilisateur, {File? newPhotoFile, html.File? webPhotoFile}) async {
    try {
      String downloadUrl;

      if (kIsWeb) {
        if (webPhotoFile != null) {
          final reader = html.FileReader();
          reader.readAsDataUrl(webPhotoFile);
          
          await reader.onLoad.first;

          final String base64Image = reader.result as String;
          List<int> imageBytes = base64Decode(base64Image.split(',')[1]);

          String filePath = 'profilePhotos/$userId/${DateTime.now().millisecondsSinceEpoch}.png';
          final metadata = SettableMetadata(contentType: 'image/png');

          UploadTask uploadTask = _storage.ref().child(filePath).putData(Uint8List.fromList(imageBytes), metadata);
          TaskSnapshot snapshot = await uploadTask;
          downloadUrl = await snapshot.ref.getDownloadURL();
        } else {
          throw Exception("Aucune image fournie pour la mise à jour du profil.");
        }
      } else {
        if (newPhotoFile != null) {
          String filePath = 'profilePhotos/$userId/${DateTime.now().millisecondsSinceEpoch}.png';
          UploadTask uploadTask = _storage.ref().child(filePath).putFile(newPhotoFile);
          TaskSnapshot snapshot = await uploadTask;
          downloadUrl = await snapshot.ref.getDownloadURL();
        } else {
          throw Exception("Aucune image fournie pour la mise à jour du profil.");
        }
      }

      utilisateur.photoProfil = downloadUrl;
      await _collection.doc(userId).update(utilisateur.toMap());

      print('Profil mis à jour avec succès avec la nouvelle photo de profil');
    } catch (e) {
      print('Erreur lors de la mise à jour du profil avec la photo : $e');
      throw e;
    }
  }

  // Méthode pour obtenir le nombre d'utilisateurs actifs pendant une année
  Future<int> getNombreUtilisateursActifs() async {
    // Calculer la date de début (un an en arrière)
    DateTime dateUnAn = DateTime.now().subtract(Duration(days: 365));
    
    // Requête pour récupérer les utilisateurs dont la date d'inscription est supérieure ou égale à la date d'un an
    QuerySnapshot snapshot = await _collection
        .where('dateInscription', isGreaterThanOrEqualTo: dateUnAn)
        .get();

    // Le nombre d'utilisateurs actifs est simplement le nombre de documents récupérés
    return snapshot.docs.length;
  }
  
   
  // Méthode pour obtenir le nombre d'utilisateurs actifs pour un mois spécifique
  Future<int> getNombreUtilisateursActifsSurMois(DateTime mois) async {
    DateTime finMois = mois.add(Duration(days: 30));
    
    QuerySnapshot snapshot = await _collection
        .where('dateInscription', isGreaterThanOrEqualTo: mois)
        .where('dateInscription', isLessThanOrEqualTo: finMois)
        .get();

    return snapshot.docs.length;
  }

  Future<int> getNombreNouveauxUtilisateurs() async {
  // Calculer la date de début (un mois en arrière)
  DateTime dateUnMois = DateTime.now().subtract(Duration(days: 30));
  
  // Requête pour récupérer les utilisateurs dont la date d'inscription est supérieure ou égale à la date d'un mois
  QuerySnapshot snapshot = await _collection
      .where('dateInscription', isGreaterThanOrEqualTo: dateUnMois.toIso8601String())
      .get();

  // Le nombre de nouveaux utilisateurs est simplement le nombre de documents récupérés
  return snapshot.docs.length;
}

}
