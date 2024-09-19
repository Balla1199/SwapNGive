import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/utilisateur.dart';

class UtilisateurService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection de la base de données Firestore
  final CollectionReference utilisateurCollection = FirebaseFirestore.instance.collection('utilisateurs');

  // Créer un utilisateur dans Firestore
  Future<void> creerUtilisateur(Utilisateur utilisateur) async {
    try {
      await utilisateurCollection.doc(utilisateur.id).set(utilisateur.toMap());
    } catch (e) {
      throw Exception("Erreur lors de la création de l'utilisateur : $e");
    }
  }

  // Récupérer un utilisateur par ID
  Future<Utilisateur?> getUtilisateur(String id) async {
    try {
      DocumentSnapshot doc = await utilisateurCollection.doc(id).get();
      if (doc.exists) {
        return Utilisateur.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception("Erreur lors de la récupération de l'utilisateur : $e");
    }
  }

  // Récupérer tous les utilisateurs
  Future<List<Utilisateur>> getTousUtilisateurs() async {
    try {
      QuerySnapshot snapshot = await utilisateurCollection.get();
      return snapshot.docs
          .map((doc) => Utilisateur.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Erreur lors de la récupération des utilisateurs : $e");
    }
  }

  // Modifier un utilisateur
  Future<void> modifierUtilisateur(Utilisateur utilisateur) async {
    try {
      await utilisateurCollection.doc(utilisateur.id).update(utilisateur.toMap());
    } catch (e) {
      throw Exception("Erreur lors de la modification de l'utilisateur : $e");
    }
  }

  // Supprimer un utilisateur
  Future<void> supprimerUtilisateur(String id) async {
    try {
      await utilisateurCollection.doc(id).delete();
    } catch (e) {
      throw Exception("Erreur lors de la suppression de l'utilisateur : $e");
    }
  }

  
}
