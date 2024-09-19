import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/etat.dart';


class EtatService {
  final CollectionReference etatCollection = FirebaseFirestore.instance.collection('etats');

  // Ajouter un état
  Future<void> ajouterEtat(Etat etat) async {
    return await etatCollection.doc(etat.id).set(etat.toMap());
  }

  // Récupérer tous les états
  Stream<List<Etat>> getEtats() {
    return etatCollection.snapshots().map((snapshot) =>
      snapshot.docs.map((doc) => Etat.fromMap(doc.data() as Map<String, dynamic>)).toList()
    );
  }

  // Modifier un état
  Future<void> modifierEtat(Etat etat) async {
    return await etatCollection.doc(etat.id).update(etat.toMap());
  }

  // Supprimer un état
  Future<void> supprimerEtat(String id) async {
    return await etatCollection.doc(id).delete();
    // Récupérer un état par son ID

  }
}
