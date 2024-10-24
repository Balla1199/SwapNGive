import 'package:flutter/material.dart';
import 'package:swapngive/models/Echange.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/services/utilisateur_service.dart';
import 'package:swapngive/services/avis_service.dart';

class HistoriqueDetailEchangeScreen extends StatelessWidget {
  final Echange echange;
  final UtilisateurService utilisateurService = UtilisateurService();
  final AvisService avisService = AvisService(); // Instance de votre service Avis

  HistoriqueDetailEchangeScreen({required this.echange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9A9A9), // Couleur de l'AppBar
        leading: IconButton(
          icon: Icon(Icons.chevron_left), // Icône de retour (chevronleft)
          color: Colors.white, // Couleur de l'icône
          onPressed: () {
            Navigator.pop(context); // Retour à l'écran précédent
          },
        ),
        title: Text(
          'Détails de l\'Échange', // Titre de l'écran
          style: TextStyle(
            fontWeight: FontWeight.bold, // Mettre le titre en gras
            color: Colors.white, // Couleur du titre en blanc
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrousel pour afficher les images avec défilement automatique
            CarouselSlider(
              options: CarouselOptions(
                height: 250.0, // Hauteur de l'image
                autoPlay: true, // Défilement automatique
                enlargeCenterPage: true, // Agrandir l'image au centre
              ),
              items: [
                Image.network(
                  echange.objet2.imageUrl, // URL de l'image
                  width: double.infinity, // Largeur de l'image
                  fit: BoxFit.cover, // Adapter l'image
                )
              ].map((image) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0), // Bordure arrondie
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6.0,
                            offset: Offset(0, 2), // Effet d'ombre
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0), // Bordure arrondie pour l'image
                        child: image,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            Text(
              echange.objet2.nom,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD9A9A9),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              echange.objet2.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'État',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold, // Mettre le texte "État" en gras
              ),
            ),
            Text(
              echange.objet2.etat.nom,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0), // Espace avant la photo de profil et les détails de l'utilisateur
            FutureBuilder<Utilisateur?>(
              future: utilisateurService.getUtilisateurById(echange.idUtilisateur2),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Affiche un indicateur de chargement
                } else if (snapshot.hasError) {
                  return Text('Erreur de chargement'); // Gérer les erreurs
                } else {
                  Utilisateur? utilisateur = snapshot.data;
  return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Row(
      children: [
        // Utilisation de Container pour définir une largeur et une hauteur spécifiques
        Container(
          width: 80, // Largeur agrandie
          height: 80, // Hauteur agrandie
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Forme ronde
            image: DecorationImage(
              image: utilisateur?.photoProfil?.isNotEmpty == true
                  ? NetworkImage(utilisateur!.photoProfil!)
                  : AssetImage('assets/images/user.png') as ImageProvider,
              fit: BoxFit.cover, // Adapter l'image à la taille du container
            ),
          ),
        ),
        SizedBox(width: 16.0), // Espace entre l'avatar et le texte
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              utilisateur?.nom ?? 'Nom inconnu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            // Affichage des étoiles de notation
            FutureBuilder<double>(
              future: avisService.getMoyenneNotes(utilisateur!.id),
              builder: (context, ratingSnapshot) {
                if (ratingSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (ratingSnapshot.hasError) {
                  return Text('Erreur de récupération de la note.');
                } else {
                  double moyenneNotes = ratingSnapshot.data ?? 0.0;
                  return Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < moyenneNotes
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.yellow,
                      ),
                    ),
                  );
                }
              },
            ),
            Text(
              utilisateur?.email ?? 'Email inconnu',
            ),
            Text(
              utilisateur?.telephone ?? 'Téléphone inconnu',
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
