import 'package:flutter/material.dart';
import 'package:swapngive/models/objet.dart'; // Import your Objet model

class ObjetDetailsScreen extends StatelessWidget {
  final Objet objet;

  const ObjetDetailsScreen({Key? key, required this.objet}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(objet.nom),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the object name and description
            Text(
              objet.nom,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(objet.description),
            SizedBox(height: 16),
            
            // Display images in a carousel (use your preferred carousel widget)
            // For example, a simple Row of images or a carousel widget from a package

            // Display the state, category, and user names
            Text('État: ${objet.etat.nom}', style: TextStyle(fontSize: 18)),
            Text('Catégorie: ${objet.categorie.nom}', style: TextStyle(fontSize: 18)),
            Text('Utilisateur: ${objet.utilisateur.nom}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
