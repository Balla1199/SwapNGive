import 'package:flutter/material.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/screens/annonce/annonce_form_screen.dart';
import 'package:swapngive/services/objet_service.dart';
import 'package:swapngive/services/auth_service.dart';
import 'objet_form_screen.dart'; // Importer le formulaire d'objet
import 'objet_details_screen.dart'; // Importer l'écran de détails d'objet

class ObjetListScreen extends StatefulWidget {
  @override
  _ObjetListScreenState createState() => _ObjetListScreenState();
}

class _ObjetListScreenState extends State<ObjetListScreen> {
  final ObjetService _objetService = ObjetService();
  final AuthService _authService = AuthService();

  String? _userId; // Stocker l'ID de l'utilisateur connecté

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // Obtenir l'utilisateur connecté lors de l'initialisation
  }

  // Méthode pour récupérer l'utilisateur connecté
  void _getCurrentUser() async {
    final user = _authService.getCurrentUser(); // Récupérer l'utilisateur connecté
    setState(() {
      _userId = user?.uid; // Stocker l'ID de l'utilisateur
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Objets'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ObjetFormScreen()),
              );
            },
          ),
        ],
      ),
      body: _userId == null
          ? Center(child: CircularProgressIndicator()) // Afficher un indicateur de chargement si l'utilisateur n'est pas encore chargé
          : StreamBuilder<List<Objet>>(
              stream: _objetService.getUserObjetsStream(_userId!),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final objets = snapshot.data ?? [];
                if (objets.isEmpty) {
                  return Center(child: Text('Aucun objet trouvé.'));
                }

                return ListView.builder(
                  itemCount: objets.length,
                  itemBuilder: (context, index) {
                    final objet = objets[index];

                    return Card(
                      child: ListTile(
                        leading: (objet.imageUrl != null && objet.imageUrl.isNotEmpty)
                            ? Image.network(
                                objet.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.image_not_supported),
                        title: Text(objet.nom ?? 'Nom indisponible'),
                        subtitle: Text(objet.description ?? 'Description indisponible'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ObjetFormScreen(objet: objet),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await _objetService.deleteObjet(objet.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Objet supprimé.')),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.post_add),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AnnonceFormScreen(objet: objet),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ObjetDetailsScreen(objet: objet),
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
