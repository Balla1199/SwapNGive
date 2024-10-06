import 'package:flutter/material.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/services/utilisateur_service.dart';

import 'utilisateur_form_screen.dart';

class UtilisateurListScreen extends StatelessWidget {
  final UtilisateurService _utilisateurService = UtilisateurService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF), // Fond d'écran en blanc
      appBar: AppBar(
        automaticallyImplyLeading: false, // Retire le bouton "Retour"
        backgroundColor: Color(0xFFD9A9A9), // Couleur de l'AppBar en rose clair
        title: Text(
          'Liste des utilisateurs',
          style: TextStyle(
            color: Color(0xFFFFFFFF), // Texte blanc pour le contraste
            fontWeight: FontWeight.bold, // Style gras pour le titre
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Color(0xFFFFFFFF)), // Icône blanche
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UtilisateurFormScreen()),
              );
            },
            tooltip: 'Ajouter un utilisateur',
          ),
        ],
      ),
      body: StreamBuilder<List<Utilisateur>>(
        stream: _utilisateurService.getUtilisateurs(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                color: Color(0xFFD9A9A9), // Loader avec la couleur rose clair
              ),
            );
          }

          final utilisateurs = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10.0), // Espacement vertical
            itemCount: utilisateurs.length,
            itemBuilder: (context, index) {
              final utilisateur = utilisateurs[index];

              return Card(
                color: Color(0xFFFFFFFF), // Fond de carte en blanc
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5), // Marges autour des éléments
                elevation: 5, // Effet d'ombre léger
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Coins arrondis
                ),
                child: ListTile(
                  leading: FutureBuilder<String?>(
                    future: _utilisateurService.getProfilePhotoUrl(utilisateur.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircleAvatar(
                          backgroundImage: AssetImage('assets/images/user.png'),
                        );
                      } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                        return CircleAvatar(
                          backgroundImage: AssetImage('assets/images/user.png'),
                        );
                      } else {
                        return CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data!),
                        );
                      }
                    },
                  ),
                  title: Text(
                    utilisateur.nom,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600, // Texte légèrement gras
                      color: Color(0xFFD9A9A9), // Couleur rose clair pour le texte
                    ),
                  ),
                  subtitle: Text(
                    utilisateur.email,
                    style: TextStyle(
                      color: Colors.grey[600], // Gris pour le sous-titre
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        color: Color(0xFFD9A9A9), // Couleur rose pour l'icône d'édition
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UtilisateurFormScreen(utilisateur: utilisateur),
                            ),
                          );
                        },
                        tooltip: 'Modifier utilisateur',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        color: Colors.redAccent, // Couleur rouge pour la suppression
                        onPressed: () {
                          _utilisateurService.deleteUtilisateur(utilisateur.id);
                        },
                        tooltip: 'Supprimer utilisateur',
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UtilisateurFormScreen(utilisateur: utilisateur),
                      ),
                    );
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
