import 'package:flutter/material.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/services/annonceservice.dart';
import 'annonce_details_screen.dart'; // Importer l'écran de détails de l'annonce

class AnnonceListScreen extends StatefulWidget {
  @override
  _AnnonceListScreenState createState() => _AnnonceListScreenState();
}

class _AnnonceListScreenState extends State<AnnonceListScreen> {
  final AnnonceService _annonceService = AnnonceService();
  late Future<List<Annonce>> _annoncesFuture;

  // Liste pour suivre l'état des likes
  List<bool> _likedStatus = [];

  @override
  void initState() {
    super.initState();
    _annoncesFuture = _annonceService.recupererAnnoncesParStatut(StatutAnnonce.disponible);
  }

  // Méthode pour mettre à jour les likes
  Future<void> _updateLikes(String annonceId, int nouveauNombreLikes, int index) async {
    try {
      await _annonceService.mettreAJourLikes(annonceId, nouveauNombreLikes);
      setState(() {
        _likedStatus[index] = !_likedStatus[index]; // Changer l'état du like
      });
      print("Likes mis à jour avec succès !");
    } catch (e) {
      print("Erreur lors de la mise à jour des likes : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Construction du widget AnnonceListScreen...");

    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Annonces'),
      ),
      body: FutureBuilder<List<Annonce>>(
        future: _annoncesFuture,
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
          _likedStatus = List.generate(annonces.length, (index) => false); // Initialiser l'état des likes

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
                      child: Stack(
                        children: [
                          Container(
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
                          // Bouton cœur pour liker l'annonce
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    _likedStatus[index] ? Icons.favorite : Icons.favorite_border,
                                    color: _likedStatus[index] ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () {
                                    int nouveauNombreLikes = annonce.likes + (_likedStatus[index] ? -1 : 1); // Met à jour le nombre de likes
                                    _updateLikes(annonce.id, nouveauNombreLikes, index);
                                  },
                                ),
                                // Afficher le nombre total de likes à côté du cœur
                                Text(
                                  '${annonce.likes}', // Assurez-vous que l'objet annonce a un champ likes
                                  style: TextStyle(fontSize: 16), // Style pour le nombre de likes
                                ),
                              ],
                            ),
                          ),
                        ],
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
