import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/screens/chat/chatscreen.dart';
import 'package:swapngive/services/annonceservice.dart';
import 'package:swapngive/services/don_service.dart'; // Assurez-vous d'importer votre service
import 'package:swapngive/services/auth_service.dart'; // Importer le AuthService

class DetailDonScreen extends StatelessWidget {
  final Map<String, dynamic> don; // L'objet don contenant l'annonce et l'objet
  final String currentUserId; // Ajout de l'ID de l'utilisateur actuel

  const DetailDonScreen({Key? key, required this.don, required this.currentUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
  // Accéder à l'objet du don
  final objet = don['annonce']['objet'];
  final String donId = don['id']; // Assurez-vous d'avoir l'ID du don
  final String receveurId = don['receveur']['id']; // Accédez à l'ID du receveur

  // Récupération des URLs d'images
  String imageUrlString = objet['imageUrl'] ?? '';
  List<String> imageUrls = imageUrlString.isNotEmpty ? imageUrlString.split(',') : [];

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Color(0xFFD9A9A9), // Couleur de l'AppBar
      title: Text(
        objet['nom'] ?? 'Objet Don', // Utilisation de l'objet pour le titre
        style: TextStyle(
          color: Colors.white, // Titre en blanc
          fontWeight: FontWeight.bold, // Titre en gras
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.chevron_left, color: Colors.white), // Icône de retour
        onPressed: () {
          Navigator.pop(context); // Action de retour
        },
      ),
    ),
    body: SingleChildScrollView( // Assurez-vous que tout le contenu est défilable
      child: Column(
        children: [
          // Espace réduit au-dessus du carousel pour éviter qu'il soit masqué par l'AppBar
          SizedBox(height: 10.0), // Réduit l'espace à 10.0 pixels
          
          // Carrousel des images
          if (imageUrls.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                height: 250.0, // Hauteur du carousel
                autoPlay: true, // Activer le défilement automatique
                autoPlayInterval: Duration(seconds: 3), // Intervalle entre les défilements
                autoPlayAnimationDuration: Duration(milliseconds: 800), // Durée de l'animation de défilement
                viewportFraction: 0.8, // Pour afficher une partie de l'image suivante
              ),
              items: imageUrls.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return Container(
                      width: 400.0, // Largeur fixe du conteneur
                      margin: EdgeInsets.symmetric(horizontal: 5.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover, // Ajustement de l'image
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
          
          SizedBox(height: 10.0), // Espace entre le carousel et les boutons
          
          // Row pour les icônes sous le carrousel
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centrer les icônes
            children: [
              IconButton(
                icon: Icon(Icons.close, color: Colors.red),
                iconSize: 30,
                onPressed: () async {
                  // Si le don est refusé :
                  await DonService().mettreAJourStatut(donId, 'refusé'); // Mettre à jour le statut du don
                  await AnnonceService().mettreAJourStatut(don['annonce']['id'], StatutAnnonce.disponible); // Maintenir l'annonce à disponible
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Don refusé, annonce toujours disponible !")),
                  );
                },
              ),
              SizedBox(width: 70), // Espace entre les icônes
              IconButton(
                icon: Icon(Icons.handshake, color: Color(0xFFD9A9A9)),
                iconSize: 30,
                onPressed: () async {
                  // Si le don est accepté :
                  await DonService().mettreAJourStatut(donId, 'accepté'); // Mettre à jour le statut du don
                  await AnnonceService().mettreAJourStatut(don['annonce']['id'], StatutAnnonce.indisponible); // Mettre à jour l'annonce à indisponible
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Don accepté, annonce indisponible !")),
                  );
                },
              ),
              SizedBox(width: 70), // Espace entre les icônes
              IconButton(
                icon: Icon(Icons.chat, color: Colors.blue),
                iconSize: 30,
                onPressed: () {
                  // Logique pour discuter du don
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        annonceId: don['annonce']['id'], // ID de l'annonce
                        typeAnnonce: 'don', // Type de l'annonce, ici c'est un don
                        senderId: currentUserId, // ID de l'utilisateur actuel (expéditeur)
                        receiverId: receveurId, // ID du receveur (destinataire)
                        conversationId: '', // ID de la conversation, peut être vide ici
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          
          SizedBox(height: 20.0), // Espace entre les boutons et les détails de l'objet
          
          // Détails de l'objet
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
  // Nom de l'objet
  Text(
    objet['nom'] ?? 'Nom de l\'objet',
    style: TextStyle(
      fontSize: 18.0,
      fontWeight: FontWeight.bold, // Mettre le nom en gras
      color: Color(0xFFD9A9A9),
    ),
  ),
  SizedBox(height: 10.0), // Espace entre le nom et la description

  // Description de l'objet
  Text(
    '${objet['description'] ?? 'Aucune description'}',
    style: TextStyle(fontSize: 16.0),
  ),
  SizedBox(height: 10.0),

  // État
  RichText(
    text: TextSpan(
      style: TextStyle(fontSize: 16.0, color: Colors.black),
      children: [
        TextSpan(
          text: 'État : ',
          style: TextStyle(fontWeight: FontWeight.bold), // "État" en gras
        ),
        TextSpan(
          text: '\n${objet['etat']?['nom'] ?? 'État inconnu'}',
        ),
      ],
    ),
  ),
  SizedBox(height: 10.0),

  // Message
  RichText(
    text: TextSpan(
      style: TextStyle(fontSize: 16.0, color: Colors.black),
      children: [
        TextSpan(
          text: 'Message : ',
          style: TextStyle(fontWeight: FontWeight.bold), // "Message" en gras
        ),
        TextSpan(
          text: '\n${don['message'] ?? 'Aucun message'}',
        ),
      ],
    ),
  ),
],

            ),
          ),
          SizedBox(height: 20.0),
        ],
      ),
    ),
  );
}

}

// Fonction pour instancier le DetailDonScreen
Future<void> navigateToDetailDon(BuildContext context, Map<String, dynamic> don) async {
  AuthService authService = AuthService();
  Utilisateur? currentUser = await authService.getCurrentUserDetails();
  
  if (currentUser != null) {
    String currentUserId = currentUser.id; // Supposons que l'ID de l'utilisateur est dans currentUser.id
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailDonScreen(don: don, currentUserId: currentUserId),
      ),
    );
  } else {
    // Gérer le cas où l'utilisateur n'est pas connecté
  }
}
