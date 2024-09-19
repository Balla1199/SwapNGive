import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Categorie.dart';


class CategorieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection de la base de données Firestore
  final CollectionReference categorieCollection = FirebaseFirestore.instance.collection('categories');

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
}
