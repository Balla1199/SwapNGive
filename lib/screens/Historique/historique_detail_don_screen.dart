import 'package:flutter/material.dart';
import 'package:swapngive/models/Don.dart';

class HistoriqueDetailDonScreen extends StatelessWidget {
  final Don don;

  HistoriqueDetailDonScreen({required this.don});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du Don'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Si l'image est une seule URL
            Image.network(don.annonce.objet.imageUrl), // Utilisez directement l'URL de l'image
            SizedBox(height: 16.0),
            Text(
              don.annonce.objet.nom,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              don.annonce.objet.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8.0),
            Text(
              'État : ${don.annonce.objet.etat}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
