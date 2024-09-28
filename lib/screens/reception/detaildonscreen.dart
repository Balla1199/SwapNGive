import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DetailDonScreen extends StatelessWidget {
  final Map<String, dynamic> don; // L'objet don contenant l'annonce et l'objet

  const DetailDonScreen({Key? key, required this.don}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Accéder à l'objet du don
    final objet = don['annonce']['objet'];

    // Récupération des URLs d'images
    String imageUrlString = objet['imageUrl'] ?? '';
    List<String> imageUrls = imageUrlString.isNotEmpty ? imageUrlString.split(',') : [];

    return Scaffold(
      appBar: AppBar(
        title: Text(objet['nom'] ?? 'Objet Don'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carrousel des images
            if (imageUrls.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(height: 400.0),
                items: imageUrls.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Center(
                                  child: Text(
                                    'Image non disponible',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              )
            else
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Aucune image disponible.'),
              ),
            SizedBox(height: 20.0),
            // Détails de l'objet
            Card(
              elevation: 4.0,
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description : ${objet['description'] ?? 'Aucune description'}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'État : ${objet['etat']?['nom'] ?? 'État inconnu'}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Catégorie : ${objet['categorie']?['nom'] ?? 'Catégorie inconnue'}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Date : ${objet['date'] ?? 'Date non précisée'}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
