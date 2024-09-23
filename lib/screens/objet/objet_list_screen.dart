import 'package:flutter/material.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/screens/annonce/annonce_form_screen.dart';
import 'package:swapngive/services/objet_service.dart';
import 'objet_form_screen.dart'; // Importer le formulaire d'objet
import 'objet_details_screen.dart'; // Importer l'écran de détails d'objet

class ObjetListScreen extends StatelessWidget {
  final ObjetService _objetService = ObjetService();

  @override
  Widget build(BuildContext context) {
    print("Construction du widget ObjetListScreen...");

    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Objets'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              print("Naviguer vers le formulaire d'ajout d'objet.");
              // Navigation vers le formulaire d'ajout d'objet
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ObjetFormScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Objet>>(
        stream: _objetService.getAllObjetsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Erreur lors de la récupération des objets : ${snapshot.error}");
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            print("Chargement des objets en cours...");
            return Center(child: CircularProgressIndicator());
          }

          final objets = snapshot.data ?? [];
          print("Nombre d'objets récupérés : ${objets.length}");

          return ListView.builder(
            itemCount: objets.length,
            itemBuilder: (context, index) {
              final objet = objets[index];
              print("Affichage de l'objet à l'index $index : ${objet.nom}");

              return Card(
                child: ListTile(
                  leading: (objet.imageUrl != null && objet.imageUrl.isNotEmpty)
                      ? Image.network(
                          objet.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image_not_supported), // Icône par défaut si pas d'image
                  title: Text(objet.nom ?? 'Nom indisponible'),
                  subtitle: Text(objet.description ?? 'Description indisponible'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          print("Modification de l'objet : ${objet.nom}");
                          // Navigation vers le formulaire de modification d'objet
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ObjetFormScreen(objet: objet),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          print("Suppression de l'objet : ${objet.nom}");
                          await _objetService.deleteObjet(objet.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Objet supprimé.')),
                          );
                          print("Objet supprimé : ${objet.nom}");
                        },
                      ),
                      // Bouton pour créer une annonce
                      IconButton(
                        icon: Icon(Icons.post_add),
                        onPressed: () {
                          print("Création d'annonce pour l'objet : ${objet.nom}");
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AnnonceFormScreen(objet: objet),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    if (objet != null) {
                      print("Navigation vers les détails de l'objet : ${objet.nom}");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ObjetDetailsScreen(objet: objet),
                        ),
                      );
                    } else {
                      print("Erreur : Objet non valide.");
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Objet non valide.')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
