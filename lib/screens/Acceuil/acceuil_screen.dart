import 'package:flutter/material.dart';

class AccueilScreen extends StatelessWidget {
@override
Widget build(BuildContext context) {
  return Scaffold(
   appBar: AppBar(  // Ajout de l'AppBar en haut de la page.
     // title: Text('Accueil'),  // Titre de l'AppBar.
     automaticallyImplyLeading: false,
    ),
    body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),  // Ajoute un espace de 20px en haut des images.
            child: GridView.count(
              crossAxisCount: 3,  // Définit 3 colonnes pour l'affichage des images.
              padding: const EdgeInsets.all(8.0),  // Ajoute de l'espace autour des images.
              children: [
                _buildImageCard('assets/images/Image1.jpeg', 100, 100),
                _buildImageCard('assets/images/image2.jpg', 150, 120),
                _buildImageCard('assets/images/image3.jpeg', 100, 90),
                _buildImageCard('assets/images/image4.jpg', 130, 110),
                _buildImageCard('assets/images/image5.jpeg', 110, 95),
                _buildImageCard('assets/images/image6.jpeg', 140, 105),
                _buildImageCard('assets/images/image7.jpeg', 160, 130),
                _buildImageCard('assets/images/image8.jpg', 120, 100),
                _buildImageCard('assets/images/image9.jpg', 125, 110),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 10.0),  // Ajoute un espace de 20px entre les images et le texte.
        
        Padding(
          padding: const EdgeInsets.all(16.0),  // Espace autour du texte de description.
          child: Text(
            'Rejoignez et échangez vos objets ou faites des dons sans frais',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        
        SizedBox(height: 20.0),  // Espace entre le texte et les boutons.
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),  // Espace horizontal pour les boutons.
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/inscription');
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFFD9A9A9)),  // Couleur de fond (D9A9A9).
                  minimumSize: MaterialStateProperty.all<Size>(Size(350, 50)),  // Longueur de 300 et largeur de 50.
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,  // Pas de radius (angles droits).
                    ),
                  ),
                ),
                child: Text(
                  'Inscrivez-vous sur Falen',
                  style: TextStyle(color: Colors.white),  // Texte en blanc.
                ),
              ),
              
              SizedBox(height: 30.0),  // Espace entre les deux boutons.
              
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: TextButton.styleFrom(
                  side: BorderSide(color: Color(0xFFD9A9A9)),  // Bordure de couleur D9A9A9.
                  minimumSize: Size(350, 50),  // Longueur de 300 et largeur de 50.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,  // Pas de radius (angles droits).
                  ),
                ),
                child: Text('J’ai déjà un compte'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// Fonction pour créer chaque image avec une longueur et une largeur spécifique.
Widget _buildImageCard(String imagePath, double height, double width) {
  return Container(
    height: height,  // Longueur spécifique de l'image.
    width: width,    // Largeur spécifique de l'image.
    child: Image.asset(
      imagePath,
      fit: BoxFit.cover,  // L'image couvre tout l'espace du conteneur sans déformation.
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        return Text('Image non trouvée');  // Gestion d'erreur si l'image n'est pas trouvée.
      },
    ),
  );
}

}
