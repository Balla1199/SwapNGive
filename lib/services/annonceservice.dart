import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Annonce.dart';

class AnnonceService {
  final FirebaseFirestore _firestore;
  final CollectionReference _annoncesCollection;

  AnnonceService() 
      : _firestore = FirebaseFirestore.instance,
        _annoncesCollection = FirebaseFirestore.instance.collection('annonces');

  // Ajouter une annonce
  Future<void> ajouterAnnonce(Annonce annonce) async {
    try {
      await _annoncesCollection.doc(annonce.id).set(annonce.toJson());
      print("Annonce ajoutée avec succès !");
    } catch (e) {
      print("Erreur lors de l'ajout de l'annonce : $e");
    }
  }

  // Modifier une annonce
  Future<void> modifierAnnonce(Annonce annonce) async {
    try {
      await _annoncesCollection.doc(annonce.id).update(annonce.toJson());
      print("Annonce modifiée avec succès !");
    } catch (e) {
      print("Erreur lors de la modification de l'annonce : $e");
    }
  }

  // Récupérer toutes les annonces
  Future<List<Annonce>> recupererAnnonces() async {
    try {
      QuerySnapshot snapshot = await _annoncesCollection.get();
      List<Annonce> annonces = snapshot.docs.map((doc) {
        return Annonce.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
      return annonces;
    } catch (e) {
      print("Erreur lors de la récupération des annonces : $e");
      return [];
    }
  }

  // Récupérer une annonce par ID
  Future<Annonce?> recupererAnnonceParId(String id) async {
    try {
      DocumentSnapshot doc = await _annoncesCollection.doc(id).get();
      if (doc.exists) {
        return Annonce.fromJson(doc.data() as Map<String, dynamic>);
      }
      print("Annonce non trouvée");
      return null;
    } catch (e) {
      print("Erreur lors de la récupération de l'annonce : $e");
      return null;
    }
  }

  // Supprimer une annonce
  Future<void> supprimerAnnonce(String id) async {
    try {
      await _annoncesCollection.doc(id).delete();
      print("Annonce supprimée avec succès !");
    } catch (e) {
      print("Erreur lors de la suppression de l'annonce : $e");
    }
  }

  // Récupérer toutes les annonces en temps réel
  Stream<List<Annonce>> getAllAnnoncesStream() {
    return _annoncesCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Annonce.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }
}
