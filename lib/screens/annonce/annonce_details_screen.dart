import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/screens/echange/objetechange_screen.dart';
import 'package:swapngive/services/auth_service.dart'; // Importer AuthService


class AnnonceDetailsScreen extends StatefulWidget {
  final Annonce annonce; // Paramètre pour l'annonce

  const AnnonceDetailsScreen({Key? key, required this.annonce}) : super(key: key); // Constructeur

  @override
  _AnnonceDetailsScreenState createState() => _AnnonceDetailsScreenState();
}

class _AnnonceDetailsScreenState extends State<AnnonceDetailsScreen> {
  final AuthService _authService = AuthService(); // Instance de AuthService
  bool isDifferentUser = false; // Booléen pour vérifier si l'utilisateur est différent

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  // Fonction pour vérifier si l'utilisateur connecté est différent du créateur de l'annonce
  void _checkUser() async {
    var currentUser = await _authService.getCurrentUserDetails(); // Obtenir l'utilisateur connecté
    if (currentUser != null && currentUser.id != widget.annonce.utilisateur.id) {
      setState(() {
        isDifferentUser = true; // Si l'utilisateur connecté est différent, on affiche le bouton
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Affichage des détails de l'annonce : ${widget.annonce.titre}");

    // Séparer les URLs des images s'il y a plusieurs images
    List<String> imageUrls = widget.annonce.objet.imageUrl.split(',');

    // Déterminer le texte du bouton en fonction du type d'annonce
    String boutonTexte = widget.annonce.type == TypeAnnonce.don ? 'Demander' : 'Proposer';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.annonce.titre.isNotEmpty ? widget.annonce.titre : 'Détails de l\'Annonce'),
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

            // Bouton visible uniquement si l'utilisateur est différent du créateur
            if (isDifferentUser)
              ElevatedButton(
  onPressed: () {
    // Navigation vers ChoisirObjetEchangeScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChoisirObjetEchangeScreen(
          annonce: widget.annonce, // Passez l'objet Annonce
          idObjet: widget.annonce.objet.id, // Passez l'ID de l'objet
          message: 'Proposition d\'échange pour ${widget.annonce.titre}', // Message à transmettre
        ),
      ),
    );
  },
  child: Text(boutonTexte), // Affichage du texte dynamique
),


            SizedBox(height: 16.0),

            // Titre de l'annonce
            Text(
              widget.annonce.titre,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),

            // Description de l'annonce
            Text(
              widget.annonce.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),

            // Affichage de l'état de l'objet
            Text(
              "État : ${widget.annonce.objet.etat.nom}", // Afficher le nom de l'état
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),

            Spacer(), // Espacement flexible
          ],
        ),
      ),
    );
  }
}
