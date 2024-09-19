import 'package:flutter/material.dart';
import 'package:swapngive/services/objet_service.dart'; // Service pour récupérer les objets
import 'package:swapngive/models/objet.dart'; // Modèle d'objet
import 'objet_form_screen.dart'; // Formulaire d'ajout d'objet

class ObjetListScreen extends StatefulWidget {
  @override
  _ObjetListScreenState createState() => _ObjetListScreenState();
}

class _ObjetListScreenState extends State<ObjetListScreen> {
  final ObjetService _objetService = ObjetService(); // Service des objets
  List<Objet> _objets = []; // Liste des objets récupérés

  @override
  void initState() {
    super.initState();
    _loadObjets(); // Charger la liste des objets dès que l'écran est affiché
  }

  // Charger la liste des objets depuis Firestore
 void _loadObjets() async {
  List<Objet> objets = await _objetService.getAllObjets(); // Remplacer ici
  setState(() {
    _objets = objets;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Objets'),
      ),
      body: _objets.isEmpty
          ? Center(child: CircularProgressIndicator()) // Indicateur de chargement
          : ListView.builder(
              itemCount: _objets.length,
              itemBuilder: (context, index) {
                final objet = _objets[index];
                return _buildObjetCard(objet); // Créer une carte pour chaque objet
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAjoutObjetForm(); // Navigation vers le formulaire d'ajout
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue, // Couleur du bouton
        tooltip: 'Ajouter un objet',
      ),
    );
  }

  // Construire une carte pour chaque objet
  Widget _buildObjetCard(Objet objet) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      child: ListTile(
        leading: _buildImage(objet.imageUrl), // Afficher l'image de l'objet
        title: Text(objet.nom, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(objet.description),
        onTap: () {
          // Gérer l'événement lorsque l'utilisateur clique sur l'objet
          print('Objet sélectionné : ${objet.nom}');
        },
      ),
    );
  }

  // Méthode pour afficher l'image d'un objet
  Widget _buildImage(String imageUrl) {
    if (imageUrl.isNotEmpty) {
      return Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
      );
    } else {
      return Icon(
        Icons.image_not_supported,
        size: 60,
        color: Colors.grey,
      );
    }
  }

  // Méthode pour naviguer vers le formulaire d'ajout d'objet
  void _navigateToAjoutObjetForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ObjetFormScreen()),
    ).then((value) {
      if (value == true) {
        _loadObjets(); // Recharger la liste des objets après l'ajout
      }
    });
  }
}
