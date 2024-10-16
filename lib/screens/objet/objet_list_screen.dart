import 'package:flutter/material.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/screens/annonce/annonce_form_screen.dart';
import 'package:swapngive/screens/objet/objet_form_screen.dart';
import 'package:swapngive/screens/objet/objet_details_screen.dart';
import 'package:swapngive/services/objet_service.dart';
import 'package:swapngive/services/auth_service.dart';

class ObjetListScreen extends StatefulWidget {
  @override
  _ObjetListScreenState createState() => _ObjetListScreenState();
}

class _ObjetListScreenState extends State<ObjetListScreen> {
  final ObjetService _objetService = ObjetService();
  final AuthService _authService = AuthService();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  void _getCurrentUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _userId = user?.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  automaticallyImplyLeading: false, // Désactive le bouton de retour automatique
  backgroundColor: Color.fromRGBO(244, 242, 242, 1), // Couleur de l'AppBar (blanc)
  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espace entre le logo et le titre
    children: [
      Row(
        children: [
          Image.asset(
            'assets/images/logosansnom.jpg',
            height: 40, // Hauteur du logo
          ),
        ],
      ),
      Expanded(
        child: Align(
          alignment: Alignment.center, // Centre le titre dans l'espace disponible
          child: Text(
            'Liste des Objets',
            style: TextStyle(
              color: Colors.black, // Couleur du texte (noir)
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      IconButton(
        icon: Icon(Icons.add),
        color: Colors.black, // Couleur de l'icône (noir)
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ObjetFormScreen()),
          );
        },
      ),
    ],
  ),
),


      body: _userId == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Objet>>(
              stream: _objetService.getObjetsByUserIdStream(_userId!),
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

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // Deux colonnes
                    crossAxisSpacing: 10, // Espace horizontal entre les colonnes
                    mainAxisSpacing: 10, // Espace vertical entre les lignes
                    childAspectRatio: 0.7, // Ratio pour l'aspect des cartes (hauteur/largeur)
                  ),
                  itemCount: objets.length,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index) {
                    final objet = objets[index];

                    return Card(
                      color: Colors.white, // Fond de chaque carte en blanc (#FFFFFF)
                      elevation: 3, // Légère ombre pour l'élévation des cartes
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Section pour l'image
                          (objet.imageUrl != null && objet.imageUrl.isNotEmpty)
                              ? Image.network(
                                  objet.imageUrl,
                                  height: 100,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  Icons.image_not_supported,
                                  size: 100,
                                  color: Colors.grey, // Couleur par défaut de l'icône d'image
                                ),
                          SizedBox(height: 8),
                          // Nom de l'objet
                          Text(
                            objet.nom ?? 'Nom indisponible',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFFD9A9A9), // Couleur du texte (#D9A9A9)
                            ),
                          ),
                          SizedBox(height: 8),
                          // Description
                          Text(
                            objet.description ?? 'Description indisponible',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black, // Texte de description en noir
                            ),
                          ),
                          Spacer(),
                          // Icons (modifier, supprimer, ajouter)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                color: Color(0xFFD9A9A9), // Couleur de l'icône modifier (#D9A9A9)
                                onPressed: () {
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
                                color: Color(0xFFD9A9A9), // Couleur de l'icône supprimer (#D9A9A9)
                                onPressed: () async {
                                  await _objetService.deleteObjet(objet.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Objet supprimé.')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.post_add),
                                color: Color(0xFFD9A9A9), // Couleur de l'icône ajouter (#D9A9A9)
                                onPressed: () {
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
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
