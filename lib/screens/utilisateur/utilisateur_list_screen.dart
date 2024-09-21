import 'package:flutter/material.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/services/utilisateur_service.dart';

import 'utilisateur_form_screen.dart';

class UtilisateurListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des utilisateurs'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UtilisateurFormScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Utilisateur>>(
        stream: UtilisateurService().getUtilisateurs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final utilisateurs = snapshot.data!;

          return ListView.builder(
            itemCount: utilisateurs.length,
            itemBuilder: (context, index) {
              final utilisateur = utilisateurs[index];

              return ListTile(
                title: Text(utilisateur.nom),
                subtitle: Text(utilisateur.email),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UtilisateurFormScreen(utilisateur: utilisateur),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        UtilisateurService().deleteUtilisateur(utilisateur.id);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Optional: You could also navigate to the edit screen on tap
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UtilisateurFormScreen(utilisateur: utilisateur),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
