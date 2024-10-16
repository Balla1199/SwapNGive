import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Don.dart';

class DonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// Méthode pour enregistrer un nouveau don avec récupération de l'ID généré
Future<String?> enregistrerDon(Don don) async {
  try {
    // Ajoute le don et récupère une référence vers le document créé
    DocumentReference docRef = await _firestore.collection('dons').add(don.toJson());

    // Récupère l'ID du document généré
    String idDon = docRef.id;
    print("Don enregistré avec succès avec l'ID: $idDon");

    // Met à jour le champ 'id' du don dans Firestore (pour que l'ID soit aussi enregistré)
    await docRef.update({'id': idDon});

    return idDon; // Retourne l'ID du don enregistré
  } catch (e) {
    print("Erreur lors de l'enregistrement du don: $e");
    return null; // En cas d'erreur, retourne null
  }
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
  
  // Méthode pour récupérer les dons par utilisateur
Future<List<Don>> recupererDonsParUtilisateur(String userId) async {
  try {
    // Récupérer les dons où l'utilisateur est impliqué en tant que donneur
    QuerySnapshot querySnapshotDonneur = await _firestore
        .collection('dons')
        .where('idDonneur', isEqualTo: userId)
        .get();

    // Récupérer les dons où l'utilisateur est impliqué en tant que receveur
    QuerySnapshot querySnapshotReceveur = await _firestore
        .collection('dons')
        .where('idReceveur', isEqualTo: userId)
        .get();

    // Fusionner les deux listes de résultats
    List<QueryDocumentSnapshot> allDocuments = []
      ..addAll(querySnapshotDonneur.docs)
      ..addAll(querySnapshotReceveur.docs);

    // Supprimer les doublons si nécessaire
    Map<String, QueryDocumentSnapshot> uniqueDocuments = {};
    for (var doc in allDocuments) {
      uniqueDocuments[doc.id] = doc;
    }

    // Convertir chaque document unique en instance de Don
    return uniqueDocuments.values
        .map((doc) => Don.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print("Erreur lors de la récupération des dons par utilisateur: $e");
    return [];
  }
}


}
