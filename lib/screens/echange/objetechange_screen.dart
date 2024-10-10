import 'package:flutter/material.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/routing.dart';
import 'package:swapngive/services/objet_service.dart';
import 'package:swapngive/services/auth_service.dart'; // Importer AuthService
import 'package:swapngive/models/utilisateur.dart'; // Importer le modèle Utilisateur

class ChoisirObjetEchangeScreen extends StatefulWidget {
  final Annonce annonce; 
  final String idObjet; // Paramètre pour l'ID de l'objet
  final String message; // Paramètre pour le message

  ChoisirObjetEchangeScreen({
    required this.annonce,
    required this.idObjet,
    required this.message,
  });

  @override
  _ChoisirObjetEchangeScreenState createState() => _ChoisirObjetEchangeScreenState();
}

class _ChoisirObjetEchangeScreenState extends State<ChoisirObjetEchangeScreen> {
  final ObjetService _objetService = ObjetService();
  final AuthService _authService = AuthService(); // Instance d'AuthService
  String? _idUtilisateur2; // Variable pour stocker l'ID de l'utilisateur

  @override
  void initState() {
    super.initState();
    _getCurrentUserDetails(); // Récupérer les détails de l'utilisateur actuel
  }

  Future<void> _getCurrentUserDetails() async {
    Utilisateur? utilisateur = await _authService.getCurrentUserDetails(); // Appeler la méthode pour obtenir les détails de l'utilisateur
    if (utilisateur != null) {
      setState(() {
        _idUtilisateur2 = utilisateur.id; // Récupérer l'ID de l'utilisateur
        print('ID Utilisateur 2: $_idUtilisateur2'); // Vérification
      });
    }
  }

  void _onObjetSelected(Objet objet) {
    // Vérifier si l'utilisateur est authentifié
    if (_idUtilisateur2 != null) {
      // Récupérer l'ID de l'utilisateur de l'annonce (utilisateur ayant ajouté l'objet)
      String idUtilisateur1 = widget.annonce.utilisateur.id; 
      // Naviguer vers ConfirmerEchangeScreen avec l'objet sélectionné
      Navigator.pushNamed(
        context,
        AppRoutes.confirmerEchange,
        arguments: {
          'idUtilisateur1': idUtilisateur1, // Utilisateur de l'annonce
          'idUtilisateur2': _idUtilisateur2, // Utilisateur authentifié
          'idObjet1': widget.idObjet, // ID de l'objet de l'annonce
          'objet2': objet, // Passer l'objet proposé au lieu de son ID
          'message': widget.message, // Message à transmettre
          'annonce': widget.annonce, // Vous pouvez également passer l'annonce si nécessaire
        },
      );
    } else {
      // Gérer le cas où l'utilisateur n'est pas connecté
      print('L\'utilisateur n\'est pas connecté.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choisir un objet à échanger'),
        backgroundColor: Colors.teal, // Couleur de fond de la barre d'applications
      ),
      body: _idUtilisateur2 == null
          ? Center(child: CircularProgressIndicator()) // Afficher un indicateur de chargement jusqu'à ce que l'ID utilisateur soit récupéré
          : StreamBuilder<List<Objet>>(
              stream: _objetService.getObjetsByUserIdStream(_idUtilisateur2!), // Utiliser le flux pour récupérer les objets
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Afficher un indicateur de chargement pendant que les données arrivent
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur lors du chargement des objets'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Aucun objet trouvé'));
                }
                List<Objet> objets = snapshot.data!; // Récupérer la liste des objets à partir du flux

                return Padding(
                  padding: const EdgeInsets.all(16.0), // Ajouter des marges pour aérer la mise en page
                  child: ListView.builder(
                    itemCount: objets.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 5, // Élévation pour donner un effet d'ombre
                        margin: const EdgeInsets.symmetric(vertical: 10), // Espacement entre les cartes
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15), // Bordure arrondie pour un style plus doux
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10), // Padding à l'intérieur de la carte
                          title: Text(
                            objets[index].nom,
                            style: TextStyle(
                              fontWeight: FontWeight.bold, // Texte en gras pour les titres
                              color: Colors.teal, // Couleur du texte
                            ),
                          ),
                          subtitle: Text(
                            'Description : ${objets[index].description}',
                            style: TextStyle(color: Colors.grey[600]), // Style de la description
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios, // Icône à droite de l'élément
                            color: Colors.teal, // Couleur de l'icône
                          ),
                          onTap: () => _onObjetSelected(objets[index]), // Action sur clic
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
