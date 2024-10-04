import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/screens/chat/chatscreen.dart';
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
      appBar: AppBar(
        title: Text(objet['nom'] ?? 'Objet Don'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carrousel des images
            if (imageUrls.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(height: 400.0),
                items: imageUrls.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width,
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
            SizedBox(height: 20.0),
            // Détails de l'objet
            Card(
              elevation: 4.0,
              margin: EdgeInsets.all(16.0),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description : ${objet['description'] ?? 'Aucune description'}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'État : ${objet['etat']?['nom'] ?? 'État inconnu'}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Catégorie : ${objet['categorie']?['nom'] ?? 'Catégorie inconnue'}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Date : ${objet['date'] ?? 'Date non précisée'}',
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.0),
            // Affichage des boutons d'actions si l'utilisateur n'est pas le receveur
            if (currentUserId != receveurId) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Logique pour accepter le don
                      await DonService().mettreAJourStatut(donId, 'accepté');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Don accepté !")),
                      );
                    },
                    child: Text("Accepter"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Logique pour refuser le don
                      await DonService().mettreAJourStatut(donId, 'refusé');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Don refusé !")),
                      );
                    },
                    child: Text("Refuser"),
                  ),
                 ElevatedButton(
  onPressed: () {
    // Logique pour discuter du don
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          annonceId: don['annonce']['id'],      // ID de l'annonce
          typeAnnonce: 'don',                  // Type de l'annonce, ici c'est un don
          senderId: currentUserId,             // ID de l'utilisateur actuel (expéditeur)
          receiverId: receveurId,              // ID du receveur (destinataire)
          conversationId: '',                  // ID de la conversation, peut être vide ici
        ),
      ),
    );
  },
  child: Text("Discuter"),
),

                ],
              ),
            ],
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
