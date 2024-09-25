import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Echange.dart';

class EchangeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Méthode pour enregistrer un échange
  Future<void> enregistrerEchange(Echange echange) async {
  await _firestore.collection('echanges').doc(echange.id).set(echange.toJson());
}


  // Méthode pour récupérer tous les échanges
  Future<List<Map<String, dynamic>>> getEchangesAsMap() async {
    QuerySnapshot snapshot = await _firestore.collection('echanges').get();
    return snapshot.docs.map((doc) {
      return doc.data() as Map<String, dynamic>;
    }).toList();
  }
 // Méthode pour récupérer un échange par son ID
 Future<Echange?> getEchangeById(String id) async {
  try {
    print("Récupération de l'échange avec l'ID: $id");
    DocumentSnapshot doc = await _firestore.collection('echanges').doc(id).get();
    
    if (doc.exists) {
      print("Document trouvé: ${doc.data()}"); // Affichez les données récupérées
      return Echange.fromJson(doc.data() as Map<String, dynamic>);
    } else {
      print("Aucun échange trouvé avec l'ID: $id");
      return null; // Renvoie null si l'échange n'existe pas
    }
  } catch (e) {
    print("Erreur lors de la récupération de l'échange: $e");
    return null; // Renvoie null en cas d'erreur
  }
}


  // Méthode pour mettre à jour un échange par son ID
  Future<void> updateEchange(String id, Echange echange) async {
    await _firestore.collection('echanges').doc(id).update(echange.toJson());
  }

  // Méthode pour supprimer un échange par son ID
  Future<void> deleteEchange(String id) async {
    await _firestore.collection('echanges').doc(id).delete();
  }

  // Méthode pour récupérer les échanges d'un utilisateur spécifique par ID d'utilisateur
  Future<List<Echange>> getEchangesByUserId(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('echanges')
        .where('idUtilisateur1', isEqualTo: userId)
        .get();
    
    return snapshot.docs.map((doc) {
      return Echange.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
  }

  // Méthode pour changer le statut d'un échange
  Future<void> changerStatutEchange(String id, String nouveauStatut) async {
    await _firestore.collection('echanges').doc(id).update({
      'statut': nouveauStatut,
    });
  }
}
