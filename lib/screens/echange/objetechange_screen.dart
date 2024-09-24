import 'package:flutter/material.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/routing.dart';
import 'package:swapngive/screens/echange/Confirmer_Echange_Screen.dart';
import 'package:swapngive/services/objet_service.dart';
import 'package:swapngive/services/auth_service.dart'; // Importer AuthService
import 'package:swapngive/models/utilisateur.dart'; // Importer le modèle Utilisateur

class ChoisirObjetEchangeScreen extends StatefulWidget {
  final Annonce annonce; 
  final String idObjet; // Paramètre pour l'ID de l'objet
  final String message; // Paramètre pour le message
ChoisirObjetEchangeScreen({
    required this.annonce, // Ajouter annonce au constructeur
    required this.idObjet,
    required this.message,
  });
  @override
  _ChoisirObjetEchangeScreenState createState() => _ChoisirObjetEchangeScreenState();
}

class _ChoisirObjetEchangeScreenState extends State<ChoisirObjetEchangeScreen> {
  final ObjetService _objetService = ObjetService();
  final AuthService _authService = AuthService(); // Instance d'AuthService
  List<Objet> _objets = [];
  bool _isLoading = true;
  String? _idUtilisateur2; // Variable pour stocker l'ID de l'utilisateur

  @override
  void initState() {
    super.initState();
    _loadObjets();
    _getCurrentUserDetails(); // Récupérer les détails de l'utilisateur actuel
  }

  Future<void> _getCurrentUserDetails() async {
    Utilisateur? utilisateur = await _authService.getCurrentUserDetails(); // Appeler la méthode pour obtenir les détails de l'utilisateur
    if (utilisateur != null) {
      _idUtilisateur2 = utilisateur.id; // Récupérer l'ID de l'utilisateur
      print('ID Utilisateur 2: $_idUtilisateur2'); // Vérification
    }
  }

  Future<void> _loadObjets() async {
    _objets = await _objetService.getAllObjets();
    setState(() {
      _isLoading = false;
    });
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
        'idObjet2': objet.id, // ID de l'objet proposé
        'message': widget.message, // Message à transmettre
        // Vous pouvez également passer l'objet annonce si nécessaire
        'annonce': widget.annonce,
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
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _objets.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_objets[index].nom), // Afficher le nom de l'objet
                  onTap: () => _onObjetSelected(_objets[index]),
                );
              },
            ),
    );
  }
}
