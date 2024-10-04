import 'package:flutter/material.dart';
import 'package:swapngive/models/Avis.dart';
import 'package:swapngive/services/avis_service.dart';
import 'package:swapngive/services/utilisateur_service.dart'; // Import UtilisateurService
import 'package:uuid/uuid.dart';

class AvisFormScreen extends StatefulWidget {
  final String utilisateurEvalueId; // ID de l'utilisateur à évaluer
  final Avis? avis;
  final String typeAnnonce;
  final String annonceId;

  AvisFormScreen({
    Key? key,
    required this.utilisateurEvalueId,
    this.avis,
    required this.typeAnnonce,
    required this.annonceId,
  }) : super(key: key);

  @override
  _AvisFormScreenState createState() => _AvisFormScreenState();
}

class _AvisFormScreenState extends State<AvisFormScreen> {
  final AvisService _avisService = AvisService();
  final UtilisateurService _utilisateurService = UtilisateurService(); // Instantiate UtilisateurService
  final TextEditingController _commentaireController = TextEditingController();
  List<Avis> _avisList = []; // Liste pour stocker les avis
  double _note = 5.0; // Note par défaut (sur 5)

  @override
  void initState() {
    super.initState();
    _fetchAvis(); // Récupérer les avis à l'initialisation
  }

  // Méthode pour récupérer les avis
  Future<void> _fetchAvis() async {
    try {
      List<Avis> avis = await _avisService.getAvisUtilisateur(widget.utilisateurEvalueId);
      setState(() {
        _avisList = avis; // Mettre à jour la liste d'avis
      });
      print('Avis récupérés : $_avisList'); // Log pour vérifier la récupération des avis
    } catch (e) {
      print('Erreur lors de la récupération des avis : $e');
    }
  }

  Future<void> _addAvis() async {
    if (_commentaireController.text.isNotEmpty) {
      // Récupérer l'utilisateur actuel
      final currentUser = _utilisateurService.getCurrentUser();
      final utilisateurId = currentUser?.uid; // Assurez-vous que vous récupérez l'ID correctement

      Avis nouvelAvis = Avis(
        id: Uuid().v4(),
        utilisateurId: utilisateurId ?? 'ID_UTILISATEUR', // Utilisez l'ID de l'utilisateur courant
        utilisateurEvalueId: widget.utilisateurEvalueId,
        annonceId: widget.annonceId,
        typeAnnonce: widget.typeAnnonce, // Assurez-vous que cela est défini
        contenu: _commentaireController.text,
        note: _note, // Utiliser la note sélectionnée
        dateCreation: DateTime.now(),
      );

      try {
        await _avisService.ajouterAvis(nouvelAvis);
        _commentaireController.clear(); // Effacer le champ après l'ajout
        _note = 5.0; // Réinitialiser la note par défaut
        await _fetchAvis(); // Récupérer à nouveau les avis pour mettre à jour la liste
        print('Avis ajouté avec succès : $nouvelAvis'); // Log pour confirmer l'ajout
      } catch (e) {
        print('Erreur lors de l\'ajout de l\'avis : $e');
      }
    }
  }

  // Méthode pour créer les étoiles de notation
  Widget _buildStarRating() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _note ? Icons.star : Icons.star_border,
            color: Colors.yellow,
          ),
          onPressed: () {
            setState(() {
              _note = index + 1.0; // Mettre à jour la note
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un avis'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStarRating(), // Ajouter le composant d'étoiles ici
            SizedBox(height: 16),
            TextField(
              controller: _commentaireController,
              decoration: InputDecoration(labelText: 'Votre avis'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addAvis,
              child: Text('Soumettre'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _avisList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_avisList[index].contenu), // Affichez le contenu de l'avis ici
                    // Affichez d'autres informations de l'avis ici si nécessaire
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
