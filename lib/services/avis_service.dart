import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Avis.dart';

class AvisService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('avis');

  Future<void> ajouterAvis(Avis avis) async {
    try {
      await _collection.add(avis.toMap());
      print('Avis ajouté avec succès');
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'avis : $e');
      throw e;
    }
  }

  // Méthode pour récupérer les avis d'un utilisateur
  Future<List<Avis>> getAvisUtilisateur(String utilisateurEvalueId) async {
    try {
      QuerySnapshot snapshot = await _collection.where('utilisateurEvaluéId', isEqualTo: utilisateurEvalueId).get();
      return snapshot.docs.map((doc) => Avis.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des avis : $e');
      throw e;
    }
  }
}
