import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Don.dart';

class DonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour enregistrer un nouveau don
  Future<void> enregistrerDon(Don don) async {
    await _firestore.collection('dons').add(don.toJson());
  }

  // Méthode pour récupérer un don par ID
  Future<Don?> recupererDonParId(String id) async {
    DocumentSnapshot doc = await _firestore.collection('dons').doc(id).get();
    if (doc.exists) {
      return Don.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null; // Retourne null si le don n'existe pas
  }

  // Méthode pour mettre à jour le statut d'un don
  Future<void> mettreAJourStatut(String id, String nouveauStatut) async {
    await _firestore.collection('dons').doc(id).update({'statut': nouveauStatut});
  }

  // Méthode pour récupérer tous les dons par statut
  Future<List<Don>> recupererDonsParStatut(String statut) async {
    QuerySnapshot querySnapshot = await _firestore.collection('dons').where('statut', isEqualTo: statut).get();
    return querySnapshot.docs.map((doc) => Don.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }

  // Méthode pour récupérer tous les dons (si nécessaire)
  Future<List<Don>> recupererTousLesDons() async {
    QuerySnapshot querySnapshot = await _firestore.collection('dons').get();
    return querySnapshot.docs.map((doc) => Don.fromJson(doc.data() as Map<String, dynamic>)).toList();
  }
}
