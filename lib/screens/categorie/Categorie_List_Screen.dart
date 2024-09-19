import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Categorie.dart';
import 'package:swapngive/services/categorie_service.dart';
import 'categorie_form_screen.dart'; // Assurez-vous d'importer la page de formulaire


class CategorieListScreen extends StatelessWidget {
  final CategorieService categorieService = CategorieService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des catégories'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategorieFormScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement des catégories'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucune catégorie trouvée'));
          }

          final categories = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Categorie.fromMap(data);
          }).toList();

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final categorie = categories[index];
              return ListTile(
                title: Text(categorie.nom),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CategorieFormScreen(categorie: categorie),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        try {
                          await categorieService.supprimerCategorie(categorie.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Catégorie supprimée avec succès'),
                          ));
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Erreur lors de la suppression : $e'),
                          ));
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
