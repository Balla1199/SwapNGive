import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/screens/utilisateur/add_user_screen.dart'; // Modifier pour update si nécessaire

class UserListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des utilisateurs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('utilisateurs').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement des utilisateurs'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Vérification que les données sont bien présentes
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Aucun utilisateur trouvé'));
          }

          // Récupération des utilisateurs depuis Firestore avec gestion des dates
          final utilisateurs = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // Vérification si le champ dateInscription est un Timestamp ou une String
            DateTime dateInscription;
            if (data['dateInscription'] is Timestamp) {
              dateInscription = (data['dateInscription'] as Timestamp).toDate();
            } else if (data['dateInscription'] is String) {
              // Tente de parser la date depuis une chaîne
              dateInscription = DateTime.parse(data['dateInscription']);
            } else {
              // Si le champ est absent ou dans un autre format, utilisez une date par défaut
              dateInscription = DateTime.now();
            }

            return Utilisateur(
              id: doc.id,  // Récupère l'id du document
              nom: data['nom'] ?? 'Nom inconnu',
              email: data['email'] ?? 'Email inconnu',
              motDePasse: data['motDePasse'] ?? 'Mot de passe inconnu',
              adresse: data['adresse'] ?? 'Adresse non fournie',
              telephone: data['telephone'] ?? 'Téléphone non fourni',
              dateInscription: dateInscription, // Gestion de la date
              role: data['role'] ?? 'Rôle inconnu',  // Récupère le rôle
            );
          }).toList();

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
                    // Bouton modifier
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddUserScreen(
                              utilisateur: utilisateur, // Passe l'utilisateur à modifier
                            ),
                          ),
                        );
                      },
                    ),
                    // Bouton supprimer
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        // Confirmer la suppression
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Supprimer l'utilisateur"),
                              content: Text("Voulez-vous vraiment supprimer cet utilisateur ?"),
                              actions: [
                                TextButton(
                                  child: Text("Annuler"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text("Supprimer"),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('utilisateurs')
                                        .doc(utilisateur.id)
                                        .delete()
                                        .then((_) {
                                      Navigator.of(context).pop(); // Ferme le dialogue
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Utilisateur supprimé avec succès'),
                                      ));
                                    }).catchError((error) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('Erreur lors de la suppression'),
                                      ));
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Action lors du clic sur un utilisateur (par ex., voir le profil)
                },
              );
            },
          );
        },
      ),
    );
  }
}
