import 'package:flutter/material.dart';
import 'package:swapngive/models/Echange.dart';


class HistoriqueDetailEchangeScreen extends StatelessWidget {
  final Echange echange;

  HistoriqueDetailEchangeScreen({required this.echange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de l\'Échange'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Si l'image est une seule URL
            Image.network(echange.annonce.objet.imageUrl), // Supposons que c'est une String
            SizedBox(height: 16.0),
            Text(
              echange.annonce.objet.nom,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              echange.annonce.objet.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'État : ${echange.annonce.objet.etat}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
