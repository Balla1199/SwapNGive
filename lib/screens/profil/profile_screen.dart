import 'dart:convert';
import 'dart:io'; // Pour mobile
import 'package:swapngive/models/utilisateur.dart';
import 'package:universal_html/html.dart' as html; // Pour web
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swapngive/services/auth_service.dart';
import 'package:swapngive/services/utilisateur_service.dart';
import 'package:swapngive/services/avis_service.dart';
import 'package:swapngive/models/Avis.dart';

class ProfileScreen extends StatefulWidget {
  final String utilisateurId;
  final bool isDifferentUser; // Ajout de isDifferentUser pour la gestion de l'utilisateur
  final Utilisateur? utilisateur;

  const ProfileScreen({
    Key? key,
    required this.utilisateurId,
    required this.isDifferentUser, // Passez cette variable ici
    this.utilisateur,
  }) : super(key: key);

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
  double _moyenneNotes = 0.0; // Variable pour la moyenne des notes

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProfilePhoto();
    _fetchAvis();
    _fetchMoyenneNotes();
  }

  Future<void> _loadProfilePhoto() async {
    if (widget.utilisateur != null) {
      try {
        String? photoUrl = await _utilisateurService.getProfilePhotoUrl(widget.utilisateur!.id);
        setState(() {
          _profilePhotoUrl = photoUrl;
        });
      } catch (e) {
        print('Erreur lors du chargement de la photo de profil : $e');
      }
    } else {
      print("Utilisateur is null");
    }
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

  Future<void> _fetchMoyenneNotes() async {
    if (widget.utilisateur != null) {
      try {
        _moyenneNotes = await _avisService.getMoyenneNotes(widget.utilisateur!.id);
        setState(() {});
      } catch (e) {
        print('Erreur lors de la récupération de la moyenne des notes : $e');
      }
    }
  }

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
          if (!widget.isDifferentUser) // Afficher le bouton déconnexion uniquement pour l'utilisateur connecté
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
                  if (!widget.isDifferentUser) // Afficher l'icône de modification uniquement pour l'utilisateur connecté
                    IconButton(
                      icon: Icon(Icons.camera_alt, color: Colors.blue),
                      onPressed: _pickImage,
                    ),
                ],
              ),
              SizedBox(height: 10),
              _buildStarRating(_moyenneNotes),
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

  Widget _buildStarRating(double moyenneNotes) {
    int noteCount = _avis.length;
    double average = noteCount > 0 ? moyenneNotes : 0.0;

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
          _buildProfileInfoRow(Icons.person, 'Nom:', widget.utilisateur?.nom ?? 'Non renseigné'),
          SizedBox(height: 20),
          _buildProfileInfoRow(Icons.location_on, 'Adresse:', widget.utilisateur?.adresse ?? 'Non renseigné'),
          SizedBox(height: 20),
          _buildProfileInfoRow(Icons.email, 'Email:', widget.utilisateur?.email ?? 'Non renseigné'),
          SizedBox(height: 20),
          _buildProfileInfoRow(Icons.phone, 'Téléphone:', widget.utilisateur?.telephone ?? 'Non renseigné'),
        ],
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue),
        SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(width: 10),
        Flexible(child: Text(value)),
      ],
    );
  }
  
  Widget _buildEvaluationSection() {
  // Vérifie si la liste des avis est vide
  if (_avis.isEmpty) {
    return Center(child: Text('Aucun avis trouvé.'));
  }

  // Utilise ListView.builder pour générer dynamiquement les avis
  return ListView.builder(
    itemCount: _avis.length, // Nombre total d'éléments dans la liste
    itemBuilder: (context, index) {
      final avisItem = _avis[index]; // Récupère l'élément d'avis à l'index donné
      final utilisateurNom = _utilisateursMap.containsKey(avisItem.utilisateurId)
          ? _utilisateursMap[avisItem.utilisateurId]?.nom ?? 'Utilisateur inconnu' // Vérifie si l'utilisateur existe et récupère son nom
          : 'Utilisateur inconnu'; // Valeur par défaut si l'utilisateur est introuvable

      // Récupérer l'URL de la photo de profil de l'utilisateur si elle est disponible
      final utilisateurPhotoUrl = _utilisateursMap.containsKey(avisItem.utilisateurId)
          ? _utilisateursMap[avisItem.utilisateurId]?.photoProfil // Récupère l'URL de la photo de profil
          : null; // Valeur par défaut si la photo de profil est introuvable

      // Renvoie un widget ListTile pour afficher les informations de l'avis
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0), // Ajoute un espacement vertical
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Espace entre les éléments dans la Row
          children: [
            // Afficher la photo de profil si elle existe, sinon une image par défaut
            CircleAvatar(
              backgroundImage: utilisateurPhotoUrl != null
                  ? NetworkImage(utilisateurPhotoUrl)
                  : AssetImage('images/user.png') as ImageProvider, // Image par défaut si l'URL est null
              radius: 20.0,
            ),
            SizedBox(width: 10), // Espacement entre la photo et le texte

            Expanded( // Utilise Expanded pour permettre à ListTile de prendre l'espace disponible
              child: ListTile(
                title: Text(utilisateurNom), // Titre avec le nom de l'utilisateur
                subtitle: Text(avisItem.contenu), // Sous-titre avec le contenu de l'avis
              ),
            ),
          ],
        ),
      );
    },
  );
}




}
