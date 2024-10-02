import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapngive/models/utilisateur.dart';

class UtilisateurService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('utilisateurs');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Créer un utilisateur dans Firebase Authentication et Firestore
  Future<void> createUtilisateur(Utilisateur utilisateur, String email, String password) async {
    try {
      // Créer l'utilisateur dans Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Si l'utilisateur est créé avec succès dans Auth, on l'ajoute dans Firestore
      utilisateur.id = userCredential.user!.uid;  // Associer l'ID de l'utilisateur à partir de Firebase Auth
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

   // Ajout de la méthode getUtilisateurById
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

}
