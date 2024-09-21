import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swapngive/models/objet.dart'; // Importez votre modèle Objet

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
            // Affichez le nom et la description de l'objet
            Text(
              objet.nom,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(objet.description),
            SizedBox(height: 16),
            
            // Affichage des images dans un carousel
            CarouselSlider(
              options: CarouselOptions(
                height: 200,
                autoPlay: true,
                enlargeCenterPage: true,
                aspectRatio: 16/9,
                viewportFraction: 0.8,
              ),
              items: objet.imageUrl.split(',').map((imageUrl) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      width: 1000, // Largeur de l'image
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 16),
            
            // Affichez l'état, la catégorie et le nom de l'utilisateur
            Text('État: ${objet.etat.nom}', style: TextStyle(fontSize: 18)),
            Text('Catégorie: ${objet.categorie.nom}', style: TextStyle(fontSize: 18)),
            Text('Utilisateur: ${objet.utilisateur.nom}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
