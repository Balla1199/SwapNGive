import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:swapngive/services/echange_service.dart';
import 'package:swapngive/services/auth_service.dart'; // Importez le service d'authentification
import 'package:swapngive/models/utilisateur.dart'; // Assurez-vous d'importer le modèle Utilisateur

class DetailsEchangeScreen extends StatefulWidget {
  final String echangeId;

  DetailsEchangeScreen({required this.echangeId});

  @override
  _DetailsEchangeScreenState createState() => _DetailsEchangeScreenState();
}

class _DetailsEchangeScreenState extends State<DetailsEchangeScreen> {
  late Future<Map<String, dynamic>?> _echangeFuture;
  Utilisateur? _currentUser; // Variable pour stocker l'utilisateur courant

  @override
  void initState() {
    super.initState();
    print("Initialisation de _DetailsEchangeScreen avec l'ID: ${widget.echangeId}");
    _echangeFuture = _loadEchange();
    _loadCurrentUser(); // Charger l'utilisateur courant
  }

  Future<Map<String, dynamic>?> _loadEchange() async {
    try {
      var echange = await EchangeService().getEchangeById(widget.echangeId);
      if (echange != null) {
        return echange.toJson(); // Assurez-vous que Echange possède la méthode toJson()
      }
      return null; // Retourne null si l'échange n'existe pas
    } catch (e) {
      print("Erreur lors de la récupération de l'échange: $e");
      return null; // Retourner null en cas d'erreur
    }
  }

  // Fonction pour charger l'utilisateur courant
  Future<void> _loadCurrentUser() async {
    _currentUser = await AuthService().getCurrentUserDetails();
    setState(() {}); // Mettre à jour l'état pour refléter les détails de l'utilisateur courant
  }

  @override
  Widget build(BuildContext context) {
    print("Construction du widget DetailsEchangeScreen...");

    return Scaffold(
      appBar: AppBar(
        title: Text("Détails de l'échange"),
      ),
      body: FutureBuilder<Map<String, dynamic>?>( 
        future: _echangeFuture,
        builder: (context, snapshot) {
          // Affichage de l'état actuel du chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Chargement des détails de l'échange...");
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print("Erreur lors du chargement: ${snapshot.error}");
            return Center(child: Text("Erreur lors du chargement des détails: ${snapshot.error}"));
          }

          final echange = snapshot.data;

          if (echange == null) {
            print("Aucun échange trouvé pour l'ID: ${widget.echangeId}");
            return Center(child: Text("Échange non trouvé pour cet ID."));
          }

          // Vérification des données avant affichage
          print("Détails de l'échange chargés: $echange");

          final objet2 = echange['objet2']?['nom'] ?? 'Nom de l\'objet non spécifié';
          final description = echange['objet2']?['description'] ?? 'Description non spécifiée';
          final etat = echange['objet2']?['etat']?['nom'] ?? 'État inconnu';
          final photos = (echange['objet2']?['imageUrl'] ?? '') as String;

          // Vérification des URLs de photos
          final photoList = photos.isNotEmpty ? photos.split(',') : [];
          print("Photos de l'objet2: $photoList");

          // Récupérer l'ID de l'utilisateur qui a proposé l'échange
          final String? proposerId = echange['proposerId']; // Assurez-vous que cette clé est correcte

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photoList.isNotEmpty)
                  CarouselSlider(
                    options: CarouselOptions(height: 200.0),
                    items: photoList.map((photoUrl) {
                      print("Chargement de la photo: $photoUrl");
                      return Builder(
                        builder: (BuildContext context) {
                          return Image.network(photoUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
                            return Center(child: Text("Erreur de chargement de l'image."));
                          });
                        },
                      );
                    }).toList(),
                  ),
                SizedBox(height: 16.0),

             // Ajouter les boutons ici uniquement si l'utilisateur courant n'est pas l'utilisateur2 (idUtilisateur2)
if (_currentUser != null && _currentUser!.id != echange['idUtilisateur2']) 
  Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            print("Echange refusé");
            // Ajouter la logique de refus
          },
          child: Text("Refuser"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
        ElevatedButton(
          onPressed: () {
            print("Echange accepté");
            // Ajouter la logique d'acceptation
          },
          child: Text("Accepter"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        ),
        ElevatedButton(
          onPressed: () {
            print("Négociation de l'échange");
            // Ajouter la logique de négociation
          },
          child: Text("Négocier"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
        ),
      ],
    ),
  ),

                SizedBox(height: 16.0),

                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nom de l'objet: $objet2",
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text("Description: $description"),
                      SizedBox(height: 8.0),
                      Text("État: $etat"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
