import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swapngive/models/Echange.dart';
import 'package:swapngive/services/auth_service.dart';
import 'package:swapngive/services/echange_service.dart';
import 'package:swapngive/models/utilisateur.dart';

class DetailEchangeScreen extends StatelessWidget {
  final Echange echange;
  final EchangeService echangeService = EchangeService();

  DetailEchangeScreen({Key? key, required this.echange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var objet2 = echange.annonce.objet; 
    var images = objet2.imageUrl.split(',');
    var nomObjet2 = objet2.nom;
    var descriptionObjet2 = objet2.description;
    var etatObjet2 = objet2.etat.nom; 
    var categorieObjet2 = objet2.categorie.nom;

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'Échange'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSlider(
              options: CarouselOptions(autoPlay: true),
              items: images.map((image) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: Image.network(image, fit: BoxFit.cover),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(nomObjet2, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(descriptionObjet2, style: TextStyle(fontSize: 16), textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            Text('État : $etatObjet2', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Catégorie : $categorieObjet2', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),

            // Récupération de l'utilisateur actuel
            FutureBuilder<Utilisateur?>(
              future: AuthService().getCurrentUserDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  print("Chargement des détails de l'utilisateur...");
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  print("Erreur de récupération de l'utilisateur: ${snapshot.error}");
                  return Text('Erreur de récupération de l\'utilisateur');
                } else {
                  final utilisateur = snapshot.data;
                  print("Utilisateur récupéré: ${utilisateur?.id}");

                  final isCurrentUser = utilisateur != null && utilisateur.id != echange.idUtilisateur2;
                  print("Est-ce l'utilisateur courant? $isCurrentUser");

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: isCurrentUser ? [
                      ElevatedButton(
                        onPressed: () {
                          print("Accepter l'échange: ${echange.id}");
                          _mettreAJourStatut(echange.id, "accepté", context);
                        },
                        child: Text('Accepter'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          print("Refuser l'échange: ${echange.id}");
                          _mettreAJourStatut(echange.id, "refusé", context);
                        },
                        child: Text('Refuser'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          print("Discussion sur l'échange: ${echange.id}");
                          _discuter(context);
                        },
                        child: Text('Discuter'),
                      ),
                    ] : [],
                  );
                }
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _mettreAJourStatut(String idEchange, String nouveauStatut, BuildContext context) async {
    try {
      print("Mise à jour du statut pour l'échange ID: $idEchange avec le nouveau statut: $nouveauStatut");
      await echangeService.mettreAJourStatut(idEchange, nouveauStatut);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut mis à jour en: $nouveauStatut')),
      );
    } catch (e) {
      print("Erreur lors de la mise à jour du statut: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour du statut: $e')),
      );
    }
  }

  void _discuter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Discussion'),
          content: Text('Ici, vous pouvez discuter concernant l\'échange.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}
