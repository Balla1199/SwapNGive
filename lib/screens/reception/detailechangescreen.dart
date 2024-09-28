import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swapngive/models/Echange.dart'; // Importez votre modèle Echange

class DetailEchangeScreen extends StatelessWidget {
  final Echange echange; // Accepte un objet de type Echange

  const DetailEchangeScreen({Key? key, required this.echange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Récupération des informations de l'objet
    var objet2 = echange.annonce.objet; // Utilisez l'objet directement à partir de l'échange
    var images = objet2.imageUrl.split(','); // Assurez-vous que imageUrl est une chaîne
    var nomObjet2 = objet2.nom;
    var descriptionObjet2 = objet2.description;
    var etatObjet2 = objet2.etat.nom; // Utilisation de l'état
    var categorieObjet2 = objet2.categorie.nom; // Utilisation de la catégorie

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'Échange'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carrousel d'images
            CarouselSlider(
              options: CarouselOptions(autoPlay: true),
              items: images.map((image) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: Image.network(image, fit: BoxFit.cover),
                );
              }).toList(),
            ),
            SizedBox(height: 16),

            // Nom de l'objet
            Text(
              nomObjet2,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),

            // Description de l'objet
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                descriptionObjet2,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 16),

            // État de l'objet
            Text(
              'État : $etatObjet2',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),

            // Catégorie de l'objet
            Text(
              'Catégorie : $categorieObjet2',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
