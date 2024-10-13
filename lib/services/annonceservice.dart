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

  // Mettre à jour les likes d'une annonce
Future<void> mettreAJourLikes(String annonceId, int nouveauNombreLikes) async {
  try {
    await _annoncesCollection.doc(annonceId).update({'likes': nouveauNombreLikes});
    print("Likes mis à jour avec succès !");
  } catch (e) {
    print("Erreur lors de la mise à jour des likes : $e");
  }
}

     // Mettre à jour le statut d'une annonce
Future<void> mettreAJourStatut(String annonceId, StatutAnnonce nouveauStatut) async {
  try {
    await _annoncesCollection.doc(annonceId).update({'statut': nouveauStatut.toString().split('.').last});
    print("Statut mis à jour avec succès !");
  } catch (e) {
    print("Erreur lors de la mise à jour du statut : $e");
  }
}

      // Récupérer les annonces par statut
Future<List<Annonce>> recupererAnnoncesParStatut(StatutAnnonce statut) async {
  try {
    // Exécuter la requête Firestore en filtrant par le statut
    QuerySnapshot snapshot = await _annoncesCollection
        .where('statut', isEqualTo: statut.toString().split('.').last)
        .get();

    // Mapper les résultats dans une liste d'objets Annonce
    List<Annonce> annonces = snapshot.docs.map((doc) {
      return Annonce.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();

    return annonces;
  } catch (e) {
    print("Erreur lors de la récupération des annonces par statut : $e");
    return [];
  }
}
 
    // Récupérer les annonces par catégorie
  Future<List<Annonce>> recupererAnnoncesParCategorie(String categorie) async {
    try {
      // Exécuter la requête Firestore en filtrant par la catégorie
      QuerySnapshot snapshot = await _annoncesCollection
          .where('categorie', isEqualTo: categorie)
          .get();

      // Mapper les résultats dans une liste d'objets Annonce
      List<Annonce> annonces = snapshot.docs.map((doc) {
        return Annonce.fromJson(doc.data() as Map<String, dynamic>);
      }).toList();

      return annonces;
    } catch (e) {
      print("Erreur lors de la récupération des annonces par catégorie : $e");
      return [];
    }
  }

}
