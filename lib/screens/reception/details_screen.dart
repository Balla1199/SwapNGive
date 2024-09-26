import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:swapngive/models/proposition.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/services/auth_service.dart';

class DetailPropositionScreen extends StatefulWidget {
  final Proposition proposition; // Recevoir l'objet Proposition directement en paramètre du constructeur
  DetailPropositionScreen({required this.proposition});

  @override
  _DetailPropositionScreenState createState() => _DetailPropositionScreenState();
}

class _DetailPropositionScreenState extends State<DetailPropositionScreen> {
  Utilisateur? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  // Charger l'utilisateur actuel
  Future<void> _loadCurrentUser() async {
    _currentUser = await AuthService().getCurrentUserDetails();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Récupérez la proposition à partir du widget
    final Proposition proposition = widget.proposition;

    // Si la proposition est null, affichez un écran de chargement ou un message d'erreur
    if (proposition == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Détails de la proposition"),
        ),
        body: Center(
          child: Text("Proposition non trouvée"),
        ),
      );
    }

    // Détails de l'objet2
    final objet2 = proposition.objet2;
    final nomObjet2 = objet2.nom ?? 'Nom de l\'objet non spécifié';
    final descriptionObjet2 = objet2.description ?? 'Description non spécifiée';
    final etatObjet2 = objet2.etat?.nom ?? 'État inconnu';
    final photosObjet2 = (objet2.imageUrl ?? '') as String;

    // Liste des photos pour objet2
    final photoListObjet2 = photosObjet2.isNotEmpty ? photosObjet2.split(',') : [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Détails de la proposition"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carousel pour objet2
            if (photoListObjet2.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(height: 200.0),
                items: photoListObjet2.map((photoUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(child: Text("Erreur de chargement de l'image."));
                        },
                      );
                    },
                  );
                }).toList(),
              ),
            SizedBox(height: 16.0),

            // Détails de l'objet2
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nom de l'objet 2: $nomObjet2",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 8.0),
                  Text("Description: $descriptionObjet2"),
                  SizedBox(height: 8.0),
                  Text("État: $etatObjet2"),
                ],
              ),
            ),

            // Boutons d'actions si l'utilisateur n'est pas l'utilisateur 2
            if (_currentUser != null && _currentUser!.id != proposition.idUtilisateur2) 
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        // Logique pour refuser la proposition
                        print("Proposition refusée");
                      },
                      child: Text("Refuser"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Logique pour accepter la proposition
                        print("Proposition acceptée");
                      },
                      child: Text("Accepter"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Logique pour négocier la proposition
                        print("Négociation de la proposition");
                      },
                      child: Text("Négocier"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
