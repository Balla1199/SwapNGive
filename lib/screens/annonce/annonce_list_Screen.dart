import 'package:flutter/material.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/Avis.dart';
import 'package:swapngive/services/annonceservice.dart';
import 'package:swapngive/services/utilisateur_service.dart';
import 'package:swapngive/services/avis_service.dart';
import 'annonce_details_screen.dart';

class AnnonceListScreen extends StatefulWidget {
  @override
  _AnnonceListScreenState createState() => _AnnonceListScreenState();
}

class _AnnonceListScreenState extends State<AnnonceListScreen> {
  final AnnonceService _annonceService = AnnonceService();
  final UtilisateurService _utilisateurService = UtilisateurService();
  final AvisService _avisService = AvisService();
  late Future<List<Annonce>> _annoncesFuture;
  List<bool> _likedStatus = [];
  List<String?> _profilePhotos = [];
  List<double> _moyennesNotes = [];
  List<Annonce> _annonces = [];
  String _searchQuery = ''; // Nouveau champ pour la recherche

  @override
  void initState() {
    super.initState();
    _annoncesFuture = _annonceService.recupererAnnoncesParStatut(StatutAnnonce.disponible);
  }

  Future<void> _loadMoyennesNotes(List<Annonce> annonces) async {
    List<double> moyennesNotes = [];
    for (var annonce in annonces) {
      double moyenne = await _avisService.getMoyenneNotes(annonce.utilisateur.id);
      moyennesNotes.add(moyenne);
    }
    setState(() {
      _moyennesNotes = moyennesNotes;
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

  Future<void> _searchAnnonces() async {
    if (_searchQuery.isNotEmpty) {
      setState(() {
        _annoncesFuture = _annonceService.recupererAnnoncesParTypeEtStatut(_searchQuery, StatutAnnonce.disponible);
      });
    }
  }

  Future<void> _updateLikes(String annonceId, int index) async {
    try {
      bool aDejaLike = _likedStatus[index];
      int nombreActuelLikes = _annonces[index].likes;

      if (aDejaLike) {
        nombreActuelLikes -= 1;
      } else {
        nombreActuelLikes += 1;
      }

      await _annonceService.mettreAJourLikes(annonceId, !aDejaLike, nombreActuelLikes);
      
      setState(() {
        _likedStatus[index] = !aDejaLike;
        _annonces[index].likes = nombreActuelLikes;
      });
    } catch (e) {
      print("Erreur lors de la mise à jour des likes : $e");
    }
  }

  Widget _buildStarRating(double moyenne) {
    int fullStars = moyenne.floor();
    int halfStars = (moyenne % 1 >= 0.5) ? 1 : 0;
    int emptyStars = 5 - fullStars - halfStars;

    return Row(
      children: [
        ...List.generate(fullStars, (index) => Icon(Icons.star, color: Colors.amber, size: 14)),
        ...List.generate(halfStars, (index) => Icon(Icons.star_half, color: Colors.amber, size: 14)),
        ...List.generate(emptyStars, (index) => Icon(Icons.star_border, color: Colors.amber, size: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Image.asset(
                'assets/images/logosansnom.jpg',
                height: 40,
                width: 40,
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Liste des Annonces',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Recherche par type d\'annonce'),
                    content: TextField(
                      onChanged: (value) {
                        _searchQuery = value;
                      },
                      decoration: InputDecoration(hintText: "Entrez le type d'annonce"),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          _searchAnnonces();
                          Navigator.pop(context);
                        },
                        child: Text('Rechercher'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
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
          _annonces = annonces;

          if (_likedStatus.isEmpty) {
            _likedStatus = List.generate(annonces.length, (index) => false);
          }

          if (_profilePhotos.isEmpty) {
            _loadProfilePhotos(annonces);
            _loadMoyennesNotes(annonces);
          }

          return Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 5,
                mainAxisSpacing: 10,
              ),
              padding: EdgeInsets.all(10),
              itemCount: annonces.length,
              itemBuilder: (context, index) {
                final annonce = annonces[index];
                final profilePhoto = _profilePhotos.length > index ? _profilePhotos[index] : null;
                final moyenneNote = _moyennesNotes.length > index ? _moyennesNotes[index] : null;

                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage: (profilePhoto != null && profilePhoto.isNotEmpty)
                              ? NetworkImage(profilePhoto)
                              : AssetImage('assets/images/user.png') as ImageProvider,
                        ),
                        SizedBox(width: 4),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              annonce.utilisateur.nom,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            moyenneNote != null ? _buildStarRating(moyenneNote) : Container(),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                                  height: 125,
                                  width: double.infinity,
                                  child: (annonce.objet.imageUrl != null && annonce.objet.imageUrl.isNotEmpty)
                                      ? Image.network(
                                          annonce.objet.imageUrl,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        )
                                      : Image.asset(
                                          'assets/images/placeholder.png',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      _updateLikes(annonce.id, index);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _likedStatus[index] ? Icons.favorite : Icons.favorite_border,
                                            color: _likedStatus[index] ? Colors.red : Colors.black,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '${annonce.likes}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: _likedStatus[index] ? Colors.red : Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  annonce.objet.nom,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  annonce.description,
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
