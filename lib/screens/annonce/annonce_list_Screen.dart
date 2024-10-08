import 'package:flutter/material.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/Avis.dart';
import 'package:swapngive/services/annonceservice.dart';
import 'package:swapngive/services/utilisateur_service.dart';
import 'package:swapngive/services/avis_service.dart'; // Importer le service d'avis
import 'annonce_details_screen.dart'; // Importer l'écran de détails de l'annonce

class AnnonceListScreen extends StatefulWidget {
  @override
  _AnnonceListScreenState createState() => _AnnonceListScreenState();
}

class _AnnonceListScreenState extends State<AnnonceListScreen> {
  final AnnonceService _annonceService = AnnonceService();
  final UtilisateurService _utilisateurService = UtilisateurService();
  final AvisService _avisService = AvisService(); // Créer une instance de AvisService
  late Future<List<Annonce>> _annoncesFuture;

  List<bool> _likedStatus = [];
  List<String?> _profilePhotos = [];
  List<double> _moyennesNotes = []; // Liste pour stocker les moyennes des notes

  @override
  void initState() {
    super.initState();
    _annoncesFuture = _annonceService.recupererAnnoncesParStatut(StatutAnnonce.disponible);
  }

  // Méthode pour récupérer les moyennes des notes
  Future<void> _loadMoyennesNotes(List<Annonce> annonces) async {
    List<double> moyennesNotes = [];
    for (var annonce in annonces) {
      double moyenne = await _avisService.getMoyenneNotes(annonce.utilisateur.id); // Récupérer la moyenne des notes
      moyennesNotes.add(moyenne);
    }
    setState(() {
      _moyennesNotes = moyennesNotes; // Mettre à jour la liste des moyennes des notes
    });
  }

  Future<void> _loadProfilePhotos(List<Annonce> annonces) async {
    List<String?> profilePhotos = [];
    for (var annonce in annonces) {
      String? photoUrl = await _utilisateurService.getProfilePhotoUrl(annonce.utilisateur.id);
      profilePhotos.add(photoUrl);
    }
    setState(() {
      _profilePhotos = profilePhotos;
    });
  }

  Future<void> _updateLikes(String annonceId, int nouveauNombreLikes, int index) async {
    try {
      await _annonceService.mettreAJourLikes(annonceId, nouveauNombreLikes);
      setState(() {
        _likedStatus[index] = !_likedStatus[index];
      });
      print("Likes mis à jour avec succès !");
    } catch (e) {
      print("Erreur lors de la mise à jour des likes : $e");
    }
  }

  // Méthode pour afficher les étoiles
  Widget _buildStarRating(double moyenne) {
    int fullStars = moyenne.floor(); // Nombre d'étoiles pleines
    int halfStars = (moyenne % 1 >= 0.5) ? 1 : 0; // Nombre d'étoiles à moitié pleines
    int emptyStars = 5 - fullStars - halfStars; // Nombre d'étoiles vides

    return Row(
      children: [
        ...List.generate(fullStars, (index) => Icon(Icons.star, color: Colors.amber)),
        ...List.generate(halfStars, (index) => Icon(Icons.star_half, color: Colors.amber)),
        ...List.generate(emptyStars, (index) => Icon(Icons.star_border, color: Colors.amber)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Liste des Annonces'),
      ),
      body: FutureBuilder<List<Annonce>>(
        future: _annoncesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final annonces = snapshot.data ?? [];
          _likedStatus = List.generate(annonces.length, (index) => false);

          // Charger les photos de profil et les moyennes des notes des utilisateurs
          if (_profilePhotos.isEmpty) {
            _loadProfilePhotos(annonces);
            _loadMoyennesNotes(annonces); // Charger les moyennes des notes
          }

          return ListView.builder(
            itemCount: annonces.length,
            itemBuilder: (context, index) {
              final annonce = annonces[index];

              // Récupérer la photo de profil et la moyenne des notes
              final profilePhoto = _profilePhotos.length > index ? _profilePhotos[index] : null;
              final moyenneNote = _moyennesNotes.length > index ? _moyennesNotes[index] : null;

              return Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Afficher la photo de profil, le nom de l'utilisateur et la moyenne des notes
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: (profilePhoto != null && profilePhoto.isNotEmpty)
                              ? NetworkImage(profilePhoto)
                              : AssetImage('assets/images/user.png') as ImageProvider,
                        ),
                        SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              annonce.utilisateur.nom,
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            // Afficher la moyenne des notes sous forme d'étoiles
                            moyenneNote != null
                                ? _buildStarRating(moyenneNote) // Appel à la méthode pour afficher les étoiles
                                : Container(), // Si pas encore chargée, afficher rien
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

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
                            height: 150,
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
                                    int nouveauNombreLikes = annonce.likes + (_likedStatus[index] ? -1 : 1);
                                    _updateLikes(annonce.id, nouveauNombreLikes, index);
                                  },
                                ),
                                // Afficher le nombre total de likes à côté du cœur
                                Text(
                                  '${annonce.likes}', 
                                  style: TextStyle(fontSize: 16),
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
