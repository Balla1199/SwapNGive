import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Echange.dart';

class EchangeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Enregistrer un nouvel échange
  Future<void> enregistrerEchange(Echange echange) async {
    await _firestore.collection('echanges').add(echange.toMap()); // Utiliser toMap() pour l'enregistrement
  }

  // Méthode pour mettre à jour le statut d'un échange
  Future<void> mettreAJourStatut(String idEchange, String nouveauStatut) async {
    try {
      await _firestore.collection('echanges').doc(idEchange).update({
        'statut': nouveauStatut, // Mettre à jour le statut
      });
      print("Statut mis à jour avec succès.");
    } catch (e) {
      print("Erreur lors de la mise à jour du statut: $e");
    }
  }

  // Méthode pour récupérer un échange par ID
  Future<Echange?> recupererEchangeParId(String idEchange) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('echanges').doc(idEchange).get();
      if (snapshot.exists) {
        return Echange.fromMap(snapshot.data() as Map<String, dynamic>); // Utiliser fromMap() pour la désérialisation
      } else {
        print("Aucun échange trouvé pour cet ID.");
        return null;
      }
    } catch (e) {
      print("Erreur lors de la récupération de l'échange: $e");
      return null;
    }
  }

  // Méthode pour récupérer tous les échanges
  Future<List<Echange>> recupererTousLesEchanges() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('echanges').get();
      return querySnapshot.docs
          .map((doc) => Echange.fromMap(doc.data() as Map<String, dynamic>)) // Utiliser fromMap() pour la désérialisation
          .toList();
    } catch (e) {
      print("Erreur lors de la récupération des échanges: $e");
      return [];
    }
  }

  // Méthode pour récupérer les échanges filtrés par statut
  Future<List<Echange>> recupererEchangesParStatut(String statut) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('echanges')
          .where('statut', isEqualTo: statut)
          .get();
      return querySnapshot.docs
          .map((doc) => Echange.fromMap(doc.data() as Map<String, dynamic>)) // Utiliser fromMap() pour la désérialisation
          .toList();
    } catch (e) {
      print("Erreur lors de la récupération des échanges par statut: $e");
      return [];
    }
  }
}
