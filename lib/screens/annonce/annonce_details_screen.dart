import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swapngive/models/Annonce.dart';

class AnnonceDetailsScreen extends StatelessWidget {
  final Annonce annonce; // Paramètre pour l'annonce

  const AnnonceDetailsScreen({Key? key, required this.annonce}) : super(key: key); // Constructeur

  @override
  Widget build(BuildContext context) {
    print("Affichage des détails de l'annonce : ${annonce.titre}");

    // Séparer les URLs des images s'il y a plusieurs images
    List<String> imageUrls = annonce.objet.imageUrl.split(',');

    return Scaffold(
      appBar: AppBar(
        title: Text(annonce.titre.isNotEmpty ? annonce.titre : 'Détails de l\'Annonce'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrousel d'images (si les images sont disponibles)
            if (imageUrls.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 250.0, // Hauteur du carrousel
                  autoPlay: true, // Défilement automatique des images
                  enlargeCenterPage: true, // Agrandissement de l'image centrée
                ),
                items: imageUrls.map((url) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Image.network(
                          url, // Afficher chaque image de la liste
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                }).toList(),
              )
            else
              Image.asset(
                'assets/images/placeholder.png', // Image de remplacement si aucune image n'est disponible
                height: 250,
                fit: BoxFit.cover,
              ),

            SizedBox(height: 16.0),

            // Titre de l'annonce
            Text(
              annonce.titre,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),

            // Description de l'annonce
            Text(
              annonce.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),

            // Affichage de l'état de l'objet
            Text(
              "État : ${annonce.objet.etat.nom}", // Afficher le nom de l'état
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),

            Spacer(), // Espacement flexible

            // Bouton de retour
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Retour à l'écran précédent
              },
              child: Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}
