import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swapngive/models/Don.dart';
import 'package:swapngive/models/utilisateur.dart'; // Assure-toi d'importer le modèle Utilisateur
import 'package:swapngive/services/utilisateur_service.dart'; // Assure-toi d'importer le bon service
import 'package:swapngive/services/avis_service.dart'; // Assure-toi d'importer le bon service

class HistoriqueDetailDonScreen extends StatelessWidget {
  final Don don;
  final UtilisateurService utilisateurService = UtilisateurService(); // Instance du service
  final AvisService avisService = AvisService(); // Instance du service d'avis

  HistoriqueDetailDonScreen({required this.don});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD9A9A9),
        leading: IconButton(
          icon: Icon(Icons.chevron_left),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Détails du Don',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrousel d'images
            CarouselSlider(
              options: CarouselOptions(
                autoPlay: true, // Défilement automatique
                enlargeCenterPage: true, // Agrandir l'image au centre
                aspectRatio: 16 / 9, // Ratio d'aspect
                onPageChanged: (index, reason) {},
              ),
              items: [don.annonce.objet.imageUrl].map((imageUrl) {
                return Container(
                  width: 300, // Largeur spécifique
                  height: 200, // Hauteur spécifique
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15), // Bord arrondi
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover, // Adapter l'image à la taille du container
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            Text(
              don.annonce.objet.nom,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFD9A9A9)),
            ),
            SizedBox(height: 8.0),
            Text(
              don.annonce.objet.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'État : \n${don.annonce.etat.nom}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0), // Espace avant la section du donneur
            // Affichage de la photo de profil et des détails du donneur
            FutureBuilder<Utilisateur?>(
              future: utilisateurService.getUtilisateurById(don.idDonneur), // Récupérer l'utilisateur par ID
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Affiche un indicateur de chargement
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return Text('Aucune information sur le donneur disponible.'); // Message si aucune information n'est disponible
                } else {
                  Utilisateur utilisateur = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Photo de profil du donneur
                          Container(
                            width: 60, // Largeur de l'image de profil
                            height: 60, // Hauteur de l'image de profil
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, // Forme ronde
                              image: DecorationImage(
                                image: NetworkImage(utilisateur.photoProfil ?? 'assets/images/user.png'),
                                fit: BoxFit.cover, // Adapter l'image à la taille du container
                              ),
                            ),
                          ),
                          SizedBox(width: 16.0), // Espace entre l'image et le texte
                          // Détails du donneur
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                utilisateur.nom ?? 'Nom inconnu',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD9A9A9)),
                              ),
                              // Affichage de la note moyenne sous forme d'étoiles
                              FutureBuilder<double>(
                                future: avisService.getMoyenneNotes(utilisateur.id), // Récupérer la moyenne des notes
                                builder: (context, ratingSnapshot) {
                                  if (ratingSnapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator(); // Affiche un indicateur de chargement
                                  } else if (ratingSnapshot.hasError) {
                                    return Text('Erreur de récupération de la note.'); // Message d'erreur
                                  } else {
                                    double moyenneNotes = ratingSnapshot.data ?? 0.0;
                                    return Row(
                                      children: List.generate(
                                        5,
                                        (index) => Icon(
                                          index < moyenneNotes ? Icons.star : Icons.star_border,
                                          color: Colors.yellow,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              Text(
                                utilisateur.email ?? 'Email inconnu',
                              ),
                              Text(
                                utilisateur.telephone ?? 'Téléphone inconnu',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
