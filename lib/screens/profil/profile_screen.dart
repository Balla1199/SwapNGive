import 'dart:convert';
import 'dart:io'; // Pour le mobile
import 'package:swapngive/models/utilisateur.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:swapngive/services/auth_service.dart';
import 'package:swapngive/services/utilisateur_service.dart'; 
import 'package:swapngive/services/avis_service.dart'; 
import 'package:swapngive/models/Avis.dart'; 

class ProfileScreen extends StatefulWidget {
  final Utilisateur? utilisateur;

  const ProfileScreen({this.utilisateur});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final UtilisateurService _utilisateurService = UtilisateurService();
  final AvisService _avisService = AvisService();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String? _profilePhotoUrl;
  List<Avis> _avis = [];
  Map<String, Utilisateur> _utilisateursMap = {}; 
  late TabController _tabController;
  double _sommeTotalNotes = 0.0; // Pour stocker la somme totale des notes

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfilePhoto();
    _fetchAvis();
    _fetchSommeTotalNotes(); // Appel pour récupérer la somme des notes
  }

  Future<void> _loadProfilePhoto() async {
    String? photoUrl = await _utilisateurService.getProfilePhotoUrl(widget.utilisateur!.id);
    setState(() {
      _profilePhotoUrl = photoUrl;
    });
  }

  Future<void> _fetchAvis() async {
    if (widget.utilisateur != null) {
      try {
        List<Avis> avis = await _avisService.getAvisUtilisateur(widget.utilisateur!.id);
        setState(() {
          _avis = avis;
        });

        for (var avisItem in avis) {
          if (!_utilisateursMap.containsKey(avisItem.utilisateurId)) {
            Utilisateur? utilisateur = await _utilisateurService.getUtilisateurById(avisItem.utilisateurId);
            setState(() {
              _utilisateursMap[avisItem.utilisateurId] = utilisateur!;
            });
          }
        }
      } catch (e) {
        print('Erreur lors du chargement des avis : $e');
      }
    }
  }

  Future<void> _fetchSommeTotalNotes() async {
  if (widget.utilisateur != null) {
    try {
      // Attendez la valeur de getSommeTotalNotes sans appel à toDouble()
      _sommeTotalNotes = await _avisService.getSommeTotalNotes(widget.utilisateur!.id);
      setState(() {}); // Mettre à jour l'interface
    } catch (e) {
      print('Erreur lors de la récupération de la somme totale des notes : $e');
    }
  }
}


  Future<void> _deconnecter() async {
    await _authService.logout();
    Navigator.of(context).pushReplacementNamed('/login'); 
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Profil de ${widget.utilisateur?.nom ?? ''}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _deconnecter, 
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(150), 
          child: Column(
            children: [
              CircleAvatar(
                backgroundImage: _profilePhotoUrl != null
                    ? NetworkImage(_profilePhotoUrl!)
                    : AssetImage('images/user.png') as ImageProvider,
                radius: 50.0,
              ),
              SizedBox(height: 10),
              // Affichage des étoiles
              _buildStarRating(_sommeTotalNotes),
              SizedBox(height: 10),
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: 'À propos'),
                  Tab(text: 'Évaluation'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAboutSection(),
          _buildEvaluationSection(),
        ],
      ),
    );
  }

  Widget _buildStarRating(double totalNotes) {
    int noteCount = _avis.length; // Compte le nombre d'avis
    double average = noteCount > 0 ? totalNotes / noteCount : 0.0; // Calcul de la note moyenne

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return Icon(
          index < average.ceil() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 24.0,
        );
      }),
    );
  }

  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.person, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'Nom:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Text('${widget.utilisateur?.nom ?? 'Non renseigné'}'),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'Adresse:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text('${widget.utilisateur?.adresse ?? 'Non renseigné'}'),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.email, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'Email:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text('${widget.utilisateur?.email ?? 'Non renseigné'}'),
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.phone, color: Colors.blue),
              SizedBox(width: 10),
              Text(
                'Téléphone:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Text('${widget.utilisateur?.telephone ?? 'Non renseigné'}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvaluationSection() {
    return _avis.isEmpty
        ? Center(child: Text('Aucun avis disponible.'))
        : ListView.builder(
            itemCount: _avis.length,
            itemBuilder: (context, index) {
              Avis avis = _avis[index];
              Utilisateur? utilisateur = _utilisateursMap[avis.utilisateurId];

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: utilisateur != null && utilisateur.photoProfil != null
                      ? NetworkImage(utilisateur.photoProfil!)
                      : AssetImage('images/user.png') as ImageProvider,
                ),
                title: Text(utilisateur?.nom ?? 'Utilisateur inconnu'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Note: ${avis.note}/5'),
                    Text('Commentaire: ${avis.contenu}'),
                  ],
                ),
              );
            },
          );
  }
}
