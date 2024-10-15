import 'package:flutter/material.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/Avis.dart';
import 'package:swapngive/models/Categorie.dart';
import 'package:swapngive/services/annonceservice.dart';
import 'package:swapngive/services/utilisateur_service.dart';
import 'package:swapngive/services/avis_service.dart';
import 'package:swapngive/services/categorie_service.dart'; 
import 'annonce_details_screen.dart';

class AnnonceListScreen extends StatefulWidget {
  @override
  _AnnonceListScreenState createState() => _AnnonceListScreenState();
}

class _AnnonceListScreenState extends State<AnnonceListScreen> {
  final AnnonceService _annonceService = AnnonceService();
  final UtilisateurService _utilisateurService = UtilisateurService();
  final AvisService _avisService = AvisService();
  final CategorieService _categorieService = CategorieService(); 

  late Future<List<Annonce>> _annoncesFuture;
  late Future<List<Categorie>> _categoriesFuture; 
  List<bool> _likedStatus = [];
  List<String?> _profilePhotos = [];
  List<double> _moyennesNotes = [];
  List<Annonce> _annonces = [];
  String _searchQuery = ''; 
  String _selectedCategorieId = ''; 

  @override
  void initState() {
    super.initState();
    print("Initialisation de l'écran AnnonceListScreen");
    _annoncesFuture = _annonceService.recupererAnnoncesParStatut(StatutAnnonce.disponible);
    _categoriesFuture = _categorieService.getToutesCategories();
  }

  Future<void> _loadMoyennesNotes(List<Annonce> annonces) async {
    List<double> moyennesNotes = [];
    for (var annonce in annonces) {
      double moyenne = await _avisService.getMoyenneNotes(annonce.utilisateur.id);
      moyennesNotes.add(moyenne);
      print("Moyenne pour l'annonce ${annonce.titre}: $moyenne");
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
      print("Photo de profil pour l'utilisateur ${annonce.utilisateur.nom}: $photoUrl");
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
      print("Recherche d'annonces avec le type: $_searchQuery");
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

      print("Mise à jour des likes pour l'annonce $annonceId: $nombreActuelLikes");
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
 Widget _buildCategoryFilters(List<Categorie> categories) {
  print("Catégories disponibles: ${categories.map((c) => c.nom).toList()}");
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: categories.map((categorie) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedCategorieId = categorie.id; 
                print("Filtrage par catégorie: ${categorie.nom} (ID: ${categorie.id})");
                
                // Récupérer les annonces disponibles pour la catégorie sélectionnée
                _annoncesFuture = _annonceService.recupererAnnoncesParCategorieEtStatut(categorie.id, StatutAnnonce.disponible); // Passer l'ID ici

                // Afficher les résultats dans la console après la récupération
                _annoncesFuture.then((annonces) {
                  if (annonces.isNotEmpty) {
                    print("Annonces disponibles pour la catégorie '${categorie.nom}':");
                    for (var annonce in annonces) {
                      print("Titre: ${annonce.titre}, Statut: ${annonce.statut.toString().split('.').last}");
                    }
                  } else {
                    print("Aucune annonce disponible pour la catégorie '${categorie.nom}'.");
                  }
                }).catchError((error) {
                  print("Erreur lors de la récupération des annonces: $error");
                });
              });
            },
            child: Text(categorie.nom),
            style: ElevatedButton.styleFrom(
        backgroundColor: _selectedCategorieId == categorie.id 
        ? Color(0xFFD9A9A9) // Couleur de fond lorsque la catégorie est sélectionnée
        : Color(0xFFD9A9A9), // Couleur de fond pour la catégorie non sélectionnée
    foregroundColor: Colors.white, // Couleur du texte en blanc
            ),
          ),
        );
      }).toList(),
    ),
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
      body: FutureBuilder<List<Categorie>>(
        future: _categoriesFuture, 
        builder: (context, categorySnapshot) {
          if (categorySnapshot.hasError) {
            return Center(child: Text('Erreur : ${categorySnapshot.error}'));
          }

          if (categorySnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final categories = categorySnapshot.data ?? [];

          return Column(
            children: [
              _buildCategoryFilters(categories),
              
              Expanded(
                child: FutureBuilder<List<Annonce>>(
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

                    print("Nombre d'annonces chargées: ${annonces.length}");
return GridView.builder(
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
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(annonce.objet.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
  bottom: 8,
  right: 8,
  child: Row(
    children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 4), // Ajustez le padding pour réduire la taille du fond
        decoration: 
        BoxDecoration(
                        color: Colors.grey[200], // Couleur de fond du bouton
                        borderRadius: BorderRadius.circular(20), // Bord arrondi
                      ),
        child: Row(
          children: [
            // Icône avec fond rectangulaire
            IconButton(
              icon: Icon(
                _likedStatus[index] ? Icons.favorite : Icons.favorite_border,
                color: _likedStatus[index] ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                _updateLikes(annonce.id, index);
              },
              padding: EdgeInsets.zero, // Supprimer le padding par défaut
            ),
            SizedBox(width: 0), // Espace entre l'icône et le texte
            Text(
              '${annonce.likes}',
              style: TextStyle(fontSize: 14), // Ajustez la taille de la police si nécessaire
            ),
          ],
        ),
      ),
    ],
  ),
),

            ],
          ),
        ),
        SizedBox(height: 5),
        Align(
  alignment: Alignment.centerLeft, // Aligne à gauche
  child: Text(
    annonce.titre,
    style: TextStyle(fontWeight: FontWeight.bold),
  ),
),
        SizedBox(height: 5),
        // Ajout de la description de l'annonce sur deux lignes
        Align(
          alignment: Alignment.centerLeft,
        child: Text(
          annonce.description, // Assurez-vous que ce champ existe dans votre modèle Annonce
          maxLines: 2,
          overflow: TextOverflow.ellipsis, // Pour couper le texte si trop long
          textAlign: TextAlign.left,
          style: TextStyle(color: Colors.grey[600]), // Style de la description
        ),
        ),
      ],
    );
  },
);


                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
