import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Categorie.dart';
import 'package:swapngive/models/Annonce.dart';

class CategorieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection de la base de données Firestore
  final CollectionReference categorieCollection = FirebaseFirestore.instance.collection('categories');
  final CollectionReference annonceCollection = FirebaseFirestore.instance.collection('annonces');

  // Créer une catégorie dans Firestore
  Future<void> creerCategorie(Categorie categorie) async {
    try {
      await categorieCollection.doc(categorie.id).set(categorie.toMap());
    } catch (e) {
      throw Exception("Erreur lors de la création de la catégorie : $e");
    }
  }

  // Récupérer une catégorie par ID
  Future<Categorie?> getCategorie(String id) async {
    try {
      DocumentSnapshot doc = await categorieCollection.doc(id).get();
      if (doc.exists) {
        return Categorie.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception("Erreur lors de la récupération de la catégorie : $e");
    }
  }

  // Récupérer toutes les catégories
  Future<List<Categorie>> getToutesCategories() async {
    try {
      QuerySnapshot snapshot = await categorieCollection.get();
      return snapshot.docs
          .map((doc) => Categorie.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception("Erreur lors de la récupération des catégories : $e");
    }
  }

  // Modifier une catégorie
  Future<void> modifierCategorie(Categorie categorie) async {
    try {
      await categorieCollection.doc(categorie.id).update(categorie.toMap());
    } catch (e) {
      throw Exception("Erreur lors de la modification de la catégorie : $e");
    }
  }

  // Supprimer une catégorie
  Future<void> supprimerCategorie(String id) async {
    try {
      await categorieCollection.doc(id).delete();
    } catch (e) {
      throw Exception("Erreur lors de la suppression de la catégorie : $e");
    }
  }

  // Obtenir les catégories les plus populaires
  Future<List<Map<String, dynamic>>> getCategoriesPopulaires() async {
    try {
      // Récupérer toutes les annonces
      QuerySnapshot annoncesSnapshot = await annonceCollection.get();
      
      // Créer un Map pour compter le nombre d'annonces par catégorie
      Map<String, int> categorieCounts = {};

      // Parcourir toutes les annonces et compter les occurrences par catégorie
      for (var doc in annoncesSnapshot.docs) {
        Annonce annonce = Annonce.fromJson(doc.data() as Map<String, dynamic>);
        String categorieId = annonce.categorie.id; // Assurez-vous que la catégorie a un identifiant

        if (categorieCounts.containsKey(categorieId)) {
          categorieCounts[categorieId] = categorieCounts[categorieId]! + 1;
        } else {
          categorieCounts[categorieId] = 1;
        }
      }

      // Créer une liste pour stocker les catégories avec leur nombre d'annonces
      List<Map<String, dynamic>> categoriesPopulaires = [];

      // Récupérer les catégories à partir de la collection des catégories
      for (var entry in categorieCounts.entries) {
        DocumentSnapshot categorieDoc = await categorieCollection.doc(entry.key).get();
        Categorie categorie = Categorie.fromMap(categorieDoc.data() as Map<String, dynamic>);

        categoriesPopulaires.add({
          'categorie': categorie,
          'nombreAnnonces': entry.value,
        });
      }

      // Trier les catégories par nombre d'annonces décroissant
      categoriesPopulaires.sort((a, b) => b['nombreAnnonces'].compareTo(a['nombreAnnonces']));

      return categoriesPopulaires;

    } catch (e) {
      throw Exception("Erreur lors de la récupération des catégories populaires : $e");
    }
  }
}
