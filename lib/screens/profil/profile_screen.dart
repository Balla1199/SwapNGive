import 'dart:convert';
import 'dart:io'; // For mobile
import 'package:swapngive/models/utilisateur.dart';
import 'package:universal_html/html.dart' as html; // For web
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
  double _sommeTotalNotes = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfilePhoto();
    _fetchAvis();
    _fetchSommeTotalNotes();
  }

  // Load profile photo
  Future<void> _loadProfilePhoto() async {
    String? photoUrl = await _utilisateurService.getProfilePhotoUrl(widget.utilisateur!.id);
    setState(() {
      _profilePhotoUrl = photoUrl;
    });
  }

  // Fetch reviews for the user
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

  // Fetch the total sum of the ratings
  Future<void> _fetchSommeTotalNotes() async {
    if (widget.utilisateur != null) {
      try {
        _sommeTotalNotes = await _avisService.getSommeTotalNotes(widget.utilisateur!.id);
        setState(() {});
      } catch (e) {
        print('Erreur lors de la récupération de la somme totale des notes : $e');
      }
    }
  }

  // Pick a new profile image (mobile and web)
  Future<void> _pickImage() async {
    try {
      if (kIsWeb) {
        html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
        uploadInput.accept = 'image/*';
        uploadInput.click();

        uploadInput.onChange.listen((e) {
          final files = uploadInput.files;
          if (files!.isEmpty) return;
          final reader = html.FileReader();
          reader.readAsDataUrl(files[0]);
          reader.onLoadEnd.listen((e) async {
            await _updateProfilePhoto(webPhotoFile: files[0]);
          });
        });
      } else {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          File imageFile = File(pickedFile.path);
          await _updateProfilePhoto(newPhotoFile: imageFile);
        }
      }
    } catch (e) {
      print('Erreur lors de la sélection de l\'image: $e');
    }
  }

  // Update the profile photo (mobile or web)
  Future<void> _updateProfilePhoto({File? newPhotoFile, html.File? webPhotoFile}) async {
    try {
      await _utilisateurService.updateProfileWithPhoto(
        widget.utilisateur!.id,
        widget.utilisateur!,
        newPhotoFile: newPhotoFile,
        webPhotoFile: webPhotoFile,
      );
      await _loadProfilePhoto(); // Reload profile photo after update
    } catch (e) {
      print('Erreur lors de la mise à jour de la photo de profil : $e');
    }
  }

  // Disconnect the user
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
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    backgroundImage: _profilePhotoUrl != null
                        ? NetworkImage(_profilePhotoUrl!)
                        : AssetImage('images/user.png') as ImageProvider,
                    radius: 50.0,
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.blue),
                    onPressed: _pickImage,
                  ),
                ],
              ),
              SizedBox(height: 10),
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
    int noteCount = _avis.length;
    double average = noteCount > 0 ? totalNotes / noteCount : 0.0;

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
                title: Text(utilisateur?.nom ?? 'Utilisateur inconnu'),
                subtitle: Text(avis.contenu),
                trailing: Text('Note: ${avis.note.toStringAsFixed(1)}'),
              );
            },
          );
  }
}
