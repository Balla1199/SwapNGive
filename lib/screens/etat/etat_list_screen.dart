import 'package:flutter/material.dart';
import 'package:swapngive/models/etat.dart';
import 'package:swapngive/screens/etat/etat_form_screen.dart';
import 'package:swapngive/services/etat_service.dart';

class EtatListScreen extends StatefulWidget {
  @override
  _EtatPageState createState() => _EtatPageState();
}

class _EtatPageState extends State<EtatListScreen> {
  final EtatService etatService = EtatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // Couleur de fond blanche
      appBar: AppBar(
        automaticallyImplyLeading: false, // Retire le bouton retour
        backgroundColor: Color(0xFFD9A9A9), // Couleur de l'AppBar en rose clair
        title: Text(
          'Liste des États',
          style: TextStyle(
            color: Color(0xFFFFFFFF), // Texte en blanc pour l'AppBar
            fontWeight: FontWeight.bold, // Texte en gras
          ),
        ),
      ),
      body: StreamBuilder<List<Etat>>(
        stream: etatService.getEtats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD9A9A9), // Rose clair pour le loader
              ),
            );
          }
          final etats = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(10.0), // Ajout de marges autour de la liste
            itemCount: etats.length,
            itemBuilder: (context, index) {
              final etat = etats[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0), // Marges pour chaque carte
                elevation: 4.0, // Élément d'ombre pour donner de la profondeur
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Bords arrondis pour les cartes
                ),
                child: ListTile(
                  title: Text(
                    etat.nom,
                    style: TextStyle(
                      color: Color(0xFFD9A9A9), // Texte en rose clair
                      fontWeight: FontWeight.w600, // Texte semi-gras
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        color: Color(0xFFD9A9A9), // Rose clair pour l'icône d'édition
                        onPressed: () {
                          // Ouvrir le formulaire pour modifier
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => EtatFormScreen(etat: etat)),
                          );
                        },
                        tooltip: 'Modifier l\'État',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.redAccent, // Rouge pour l'icône de suppression
                        onPressed: () {
                          etatService.supprimerEtat(etat.id);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('État supprimé avec succès'),
                          ));
                        },
                        tooltip: 'Supprimer l\'État',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFD9A9A9), // Bouton flottant en rose clair
        onPressed: () {
          // Ouvrir le formulaire pour ajouter un état
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EtatFormScreen()),
          );
        },
        child: Icon(Icons.add, color: Color(0xFFFFFFFF)), // Icône blanche
        tooltip: 'Ajouter un État',
      ),
    );
  }
}
