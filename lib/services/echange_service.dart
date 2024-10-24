import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Echange.dart';

class EchangeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Enregistrer un nouvel échange avec récupération de l'ID généré automatiquement
Future<String?> enregistrerEchange(Echange echange) async {
  try {
    // Ajoute l'échange et récupère une référence vers le document créé
    DocumentReference docRef = await _firestore.collection('echanges').add(echange.toMap());

    // Récupère l'ID du document généré
    String idEchange = docRef.id;
    print("Échange enregistré avec succès avec l'ID: $idEchange");

    // Met à jour le champ 'id' de l'échange dans Firestore (pour que l'ID soit aussi enregistré)
    await docRef.update({'id': idEchange});

    return idEchange; // Retourne l'ID de l'échange enregistré
  } catch (e) {
    print("Erreur lors de l'enregistrement de l'échange: $e");
    return null; // En cas d'erreur, retourne null
  }
}

Future<void> mettreAJourStatut(String idEchange, String nouveauStatut) async {
  print("Tentative de mise à jour pour l'ID: $idEchange avec le statut: $nouveauStatut");
  try {
    DocumentSnapshot doc = await _firestore.collection('echanges').doc(idEchange).get();
    print("Document trouvé : ${doc.exists}, données : ${doc.data()}");
    if (!doc.exists) {
      print("Document non trouvé pour l'ID: $idEchange");
      return;
    }
    await _firestore.collection('echanges').doc(idEchange).update({
      'statut': nouveauStatut,
    });
    print("Statut mis à jour avec succès.");
  } catch (e) {
    print("Erreur lors de la mise à jour du statut: $e");
  }
}

  // Méthode pour récupérer un échange par ID
  Future<Echange?> recupererEchangeParId(String idEchange) async {
    try {
      // Récupérer le document de l'échange
      DocumentSnapshot snapshot = await _firestore.collection('echanges').doc(idEchange).get();

      // Vérification de l'existence du document
      if (snapshot.exists) {
        // Désérialisation de l'échange à partir de la Map
        return Echange.fromMap(snapshot.data() as Map<String, dynamic>);
      } else {
        print("Aucun échange trouvé pour cet ID: $idEchange");
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
      // Récupérer tous les documents de la collection 'echanges'
      QuerySnapshot querySnapshot = await _firestore.collection('echanges').get();

      // Convertir chaque document en instance de Echange
      return querySnapshot.docs
          .map((doc) => Echange.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Erreur lors de la récupération des échanges: $e");
      return [];
    }
  }

  // Méthode pour récupérer les échanges filtrés par statut
  Future<List<Echange>> recupererEchangesParStatut(String statut) async {
    try {
      // Récupérer les échanges où le statut correspond
      QuerySnapshot querySnapshot = await _firestore
          .collection('echanges')
          .where('statut', isEqualTo: statut)
          .get();

      // Convertir chaque document en instance de Echange
      return querySnapshot.docs
          .map((doc) => Echange.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Erreur lors de la récupération des échanges par statut: $e");
      return [];
    }
  }

  Future<List<Echange>> recupererEchangesParUtilisateur(String userId) async {
  try {
    // Récupérer les échanges où l'utilisateur est impliqué (soit comme utilisateur 1, soit comme utilisateur 2)
    QuerySnapshot querySnapshot = await _firestore
        .collection('echanges')
        .where('idUtilisateur1', isEqualTo: userId)
        .get();

    QuerySnapshot querySnapshot2 = await _firestore
        .collection('echanges')
        .where('idUtilisateur2', isEqualTo: userId)
        .get();

    // Fusionner les deux listes de résultats
    List<QueryDocumentSnapshot> allDocuments = []
      ..addAll(querySnapshot.docs)
      ..addAll(querySnapshot2.docs);

    // Supprimer les doublons si nécessaire (par exemple, si un utilisateur est à la fois idUtilisateur1 et idUtilisateur2)
    Map<String, QueryDocumentSnapshot> uniqueDocuments = {};
    for (var doc in allDocuments) {
      uniqueDocuments[doc.id] = doc;
    }

    // Convertir chaque document unique en instance de Echange
    return uniqueDocuments.values
        .map((doc) => Echange.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print("Erreur lors de la récupération des échanges par utilisateur: $e");
    return [];
  }
}

Future<List<Echange>> recupererEchangesParUtilisateurEtStatut(String userId, String statut) async {
  try {
    // Récupérer les échanges où l'utilisateur est impliqué (soit comme utilisateur 1, soit comme utilisateur 2) et avec le statut correspondant
    QuerySnapshot querySnapshot1 = await _firestore
        .collection('echanges')
        .where('idUtilisateur1', isEqualTo: userId)
        .where('statut', isEqualTo: statut)
        .get();

    QuerySnapshot querySnapshot2 = await _firestore
        .collection('echanges')
        .where('idUtilisateur2', isEqualTo: userId)
        .where('statut', isEqualTo: statut)
        .get();

    // Fusionner les deux listes de résultats
    List<QueryDocumentSnapshot> allDocuments = []
      ..addAll(querySnapshot1.docs)
      ..addAll(querySnapshot2.docs);

    // Supprimer les doublons si nécessaire
    Map<String, QueryDocumentSnapshot> uniqueDocuments = {};
    for (var doc in allDocuments) {
      uniqueDocuments[doc.id] = doc;
    }

    // Convertir chaque document unique en instance de Echange
    return uniqueDocuments.values
        .map((doc) => Echange.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print("Erreur lors de la récupération des échanges par utilisateur et statut: $e");
    return [];
  }
}

   
}
