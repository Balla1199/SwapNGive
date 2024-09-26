import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/proposition.dart';

class PropositionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour enregistrer une proposition
  Future<void> enregistrerProposition(Proposition proposition) async {
    await _firestore.collection('propositions').doc(proposition.id).set(proposition.toJson());
  }

  // Méthode pour récupérer tous les propositions
  Future<List<Map<String, dynamic>>> getpropositionsAsMap() async {
    QuerySnapshot snapshot = await _firestore.collection('propositions').get();
    return snapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  }

  // Méthode pour récupérer une proposition par son ID
  Future<Proposition?> getPropositionById(String id) async {
    try {
      print("Récupération de la proposition avec l'ID: $id");
      DocumentSnapshot doc = await _firestore.collection('propositions').doc(id).get();

      if (doc.exists) {
        print("Document trouvé: ${doc.data()}");
        return Proposition.fromJson(doc.data() as Map<String, dynamic>);
      } else {
        print("Aucune proposition trouvée avec l'ID: $id");
        return null; 
      }
    } catch (e) {
      print("Erreur lors de la récupération de la proposition: $e");
      return null; 
    }
  }

  // Méthode pour mettre à jour une proposition par son ID
  Future<void> updatePrposition(String id, Proposition proposition) async {
    await _firestore.collection('propositions').doc(id).update(proposition.toJson());
  }

  // Méthode pour supprimer une proposition par son ID
  Future<void> deleteProposition(String id) async {
    await _firestore.collection('propositions').doc(id).delete();
  }

  // Méthode pour récupérer les propositions d'un utilisateur spécifique par ID d'utilisateur
  Future<List<Proposition>> getProposotionsByUserId(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('propositions')
        .where('idUtilisateur1', isEqualTo: userId)
        .get();
    
    return snapshot.docs.map((doc) {
      return Proposition.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Méthode pour changer le statut d'une proposition
  Future<void> changerStatutProposition(String id, String nouveauStatut) async {
    await _firestore.collection('propositions').doc(id).update({
      'statut': nouveauStatut,
    });
  }

  // Méthode pour récupérer les propositions par statut
  Future<List<Proposition>> getPropositionsByStatut(String statut) async {
    QuerySnapshot snapshot = await _firestore
        .collection('propositions')
        .where('statut', isEqualTo: statut)
        .get();

    return snapshot.docs.map((doc) {
      return Proposition.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

// Méthode pour récupérer les propositions par type
Future<List<Proposition>> getPropositionsByType(String type) async {
  try {
    // Requête vers Firestore pour récupérer les propositions par type
    QuerySnapshot snapshot = await _firestore
        .collection('propositions')
        .where('type', isEqualTo: type)
        .get();

    // Vérifiez si le snapshot contient des documents
    if (snapshot.docs.isEmpty) {
      print("Aucune proposition trouvée pour le type: $type");
      return [];
    }

    // Mapping des documents récupérés vers des objets Proposition
    return snapshot.docs.map((doc) {
      return Proposition.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
    
  } catch (e) {
    // En cas d'erreur, affichez-la dans la console et renvoyez une liste vide
    print('Erreur lors de la récupération des propositions par type: $e');
    return [];
  }
}




}
