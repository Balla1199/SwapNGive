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
      appBar: AppBar(
        title: Text('Liste des États'),
      ),
      body: StreamBuilder<List<Etat>>(
        stream: etatService.getEtats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final etats = snapshot.data!;
          return ListView.builder(
            itemCount: etats.length,
            itemBuilder: (context, index) {
              final etat = etats[index];
              return ListTile(
                title: Text(etat.nom),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Ouvrir le formulaire pour modifier
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EtatFormScreen(etat: etat)),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        etatService.supprimerEtat(etat.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Ouvrir le formulaire pour ajouter un état
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EtatFormScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
