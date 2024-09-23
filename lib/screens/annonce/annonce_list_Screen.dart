import 'package:flutter/material.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/services/annonceservice.dart';
import 'annonce_details_screen.dart'; // Importer l'écran de détails de l'annonce

class AnnonceListScreen extends StatelessWidget {
  final AnnonceService _annonceService = AnnonceService();

  @override
  Widget build(BuildContext context) {
    print("Construction du widget AnnonceListScreen...");

    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Annonces'),
      ),
      body: FutureBuilder<List<Annonce>>(
        future: _annonceService.recupererAnnonces(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Erreur lors de la récupération des annonces : ${snapshot.error}");
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Chargement des annonces en cours...");
            return Center(child: CircularProgressIndicator());
          }

          final annonces = snapshot.data ?? [];
          print("Nombre d'annonces récupérées : ${annonces.length}");

          return ListView.builder(
            itemCount: annonces.length,
            itemBuilder: (context, index) {
              final annonce = annonces[index];
              print("Affichage de l'annonce à l'index $index : ${annonce.titre}");

              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Afficher l'image en haut et rediriger vers les détails
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AnnonceDetailsScreen(annonce: annonce),
                          ),
                        );
                      },
                      child: Container(
                        height: 150, // Hauteur de l'image
                        child: (annonce.objet.imageUrl != null && annonce.objet.imageUrl.isNotEmpty)
                            ? Image.network(
                                annonce.objet.imageUrl,
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/images/placeholder.png',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        annonce.titre.isNotEmpty ? annonce.titre : 'Titre indisponible',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        annonce.description.isNotEmpty ? annonce.description : 'Description indisponible',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    SizedBox(height: 8.0),
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
