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
      backgroundColor: Color(0xFFFFFFFF), // Couleur de fond de l'écran en blanc
      appBar: AppBar(
        automaticallyImplyLeading: false, // Retire le bouton retour
        backgroundColor: Color(0xFFD9A9A9), // Couleur rose clair pour l'AppBar
        title: Text(
          'Liste des catégories',
          style: TextStyle(
            color: Color(0xFFFFFFFF), // Couleur blanche pour le texte du titre
            fontWeight: FontWeight.bold, // Texte en gras
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFFFFFFFF)), // Icône blanche
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategorieFormScreen()),
              );
            },
            tooltip: 'Ajouter une catégorie',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur de chargement des catégories',
                style: TextStyle(
                  color: Colors.redAccent, // Rouge pour signaler l'erreur
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD9A9A9), // Couleur rose clair pour le loader
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Aucune catégorie trouvée',
                style: TextStyle(
                  color: Colors.grey, // Texte en gris pour indiquer l'absence
                  fontStyle: FontStyle.italic, // Texte en italique pour l'effet
                ),
              ),
            );
          }

          final categories = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Categorie.fromMap(data);
          }).toList();

          return ListView.builder(
            padding: EdgeInsets.all(10.0), // Espacement autour de la liste
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final categorie = categories[index];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0), // Marges des cartes
                elevation: 4.0, // Légère élévation pour l'effet d'ombre
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Bords arrondis des cartes
                ),
                child: ListTile(
                  title: Text(
                    categorie.nom,
                    style: TextStyle(
                      color: Color(0xFFD9A9A9), // Couleur rose pour le titre
                      fontWeight: FontWeight.w600, // Poids de texte semi-gras
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        color: Color(0xFFD9A9A9), // Couleur rose pour l'icône d'édition
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CategorieFormScreen(categorie: categorie),
                            ),
                          );
                        },
                        tooltip: 'Modifier la catégorie',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.redAccent, // Couleur rouge pour la suppression
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
                        tooltip: 'Supprimer la catégorie',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
