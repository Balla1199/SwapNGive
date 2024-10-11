import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/Notification.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/screens/don/MessageDon_screen.dart';
import 'package:swapngive/screens/echange/objetechange_screen.dart';
import 'package:swapngive/screens/profil/profile_screen.dart';
import 'package:swapngive/services/auth_service.dart';
import 'package:swapngive/services/avis_service.dart';
import 'package:swapngive/services/utilisateur_service.dart';
import 'package:swapngive/services/notification_service.dart'; // Importation du service de notification


class AnnonceDetailsScreen extends StatefulWidget {
  final Annonce annonce;

  const AnnonceDetailsScreen({Key? key, required this.annonce}) : super(key: key);

  @override
  _AnnonceDetailsScreenState createState() => _AnnonceDetailsScreenState();
}

class _AnnonceDetailsScreenState extends State<AnnonceDetailsScreen> {
  final AuthService _authService = AuthService();
  final UtilisateurService _utilisateurService = UtilisateurService();
  final AvisService _avisService = AvisService();
  final NotificationService _notificationService = NotificationService(); // Ajout du service de notification

  bool isDifferentUser = false;
  String? profilePhotoUrl;
  String? utilisateurNom;
  double moyenneNotes = 0.0;

  @override
  void initState() {
    super.initState();
    _checkUser();
    _loadUtilisateurData();
    _loadMoyenneNotes();
  }

  void _checkUser() async {
    var currentUser = await _authService.getCurrentUserDetails();
    if (currentUser != null && currentUser.id != widget.annonce.utilisateur.id) {
      setState(() {
        isDifferentUser = true;
      });
    }
  }

  void _loadUtilisateurData() async {
    String userId = widget.annonce.utilisateur.id;
    String? photoUrl = await _utilisateurService.getProfilePhotoUrl(userId);
    setState(() {
      profilePhotoUrl = photoUrl;
      utilisateurNom = widget.annonce.utilisateur.nom;
    });
  }

  void _loadMoyenneNotes() async {
    String userId = widget.annonce.utilisateur.id;
    try {
      double moyenne = await _avisService.getMoyenneNotes(userId);
      setState(() {
        moyenneNotes = moyenne;
      });
    } catch (e) {
      print('Erreur lors du chargement des notes : $e');
    }
  }

  Widget _buildStarRating(double rating) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    return Row(
      children: List.generate(5, (index) {
        if (index < fullStars) {
          return Icon(Icons.star, color: Colors.amber);
        } else if (index == fullStars && hasHalfStar) {
          return Icon(Icons.star_half, color: Colors.amber);
        } else {
          return Icon(Icons.star_border, color: Colors.amber);
        }
      }),
    );
  }

  void _handleAction() async {
    var currentUser = await _authService.getCurrentUserDetails(); // Récupérer l'utilisateur actuel

    if (currentUser != null) {
      if (widget.annonce.type == TypeAnnonce.don) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MessageDonScreen(
              annonce: widget.annonce,
              idObjet: widget.annonce.objet.id,
            ),
          ),
        );
        // Enregistrer une notification pour la demande de don
        NotificationModel notification = NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Génération d'un ID unique
          fromUserId: currentUser.id, // L'utilisateur qui fait la demande
          toUserId: widget.annonce.utilisateur.id, // L'utilisateur qui reçoit la demande
          titre: "Demande de don",
          message: "Demande de don pour ${widget.annonce.titre}",
          date: DateTime.now(),
        );
        await _notificationService.enregistrerNotification(notification); // Enregistrer la notification
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChoisirObjetEchangeScreen(
              annonce: widget.annonce,
              idObjet: widget.annonce.objet.id,
              message: 'Proposition d\'échange pour ${widget.annonce.titre}',
            ),
          ),
        );
        // Enregistrer une notification pour la proposition d'échange
        NotificationModel notification = NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(), // Génération d'un ID unique
          fromUserId: currentUser.id, // L'utilisateur qui fait la proposition
          toUserId: widget.annonce.utilisateur.id, // L'utilisateur qui reçoit la proposition
          titre: "Proposition d'échange",
          message: "Proposition d'échange pour ${widget.annonce.titre}",
          date: DateTime.now(),
        );
        await _notificationService.enregistrerNotification(notification); // Enregistrer la notification
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Affichage des détails de l'annonce : ${widget.annonce.titre}");

    List<String> imageUrls = widget.annonce.objet.imageUrl.split(',');

    String boutonTexte = widget.annonce.type == TypeAnnonce.don ? 'Demander' : 'Proposer';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.annonce.titre.isNotEmpty ? widget.annonce.titre : 'Détails de l\'Annonce'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrls.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 250.0,
                  autoPlay: true,
                  enlargeCenterPage: true,
                ),
                items: imageUrls.map((url) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                }).toList(),
              )
            else
              Image.asset(
                'assets/images/placeholder.png',
                height: 250,
                fit: BoxFit.cover,
              ),

            SizedBox(height: 16.0),

            if (isDifferentUser)
              ElevatedButton(
                onPressed: _handleAction, // Appel à la méthode de gestion des actions
                child: Text(boutonTexte),
              ),

            SizedBox(height: 16.0),

            Text(
              widget.annonce.titre,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),

            Text(
              widget.annonce.description,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16.0),

            Text(
              "État : ${widget.annonce.objet.etat.nom}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),

            Spacer(),

            Row(
              children: [
                if (profilePhotoUrl != null)
                  GestureDetector(
                    onTap: () async {
                      Utilisateur? currentUserDetails = await _authService.getCurrentUserDetails();

                      if (currentUserDetails != null) {
                        bool isDifferentUser = widget.annonce.utilisateur.id != currentUserDetails.id;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              utilisateurId: widget.annonce.utilisateur.id,
                              isDifferentUser: isDifferentUser,
                              utilisateur: widget.annonce.utilisateur,
                            ),
                          ),
                        );
                      } else {
                        print('Impossible de récupérer les détails de l\'utilisateur.');
                      }
                    },
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(profilePhotoUrl!),
                      radius: 25,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: () async {
                      Utilisateur? currentUserDetails = await _authService.getCurrentUserDetails();

                      if (currentUserDetails != null) {
                        bool isDifferentUser = widget.annonce.utilisateur.id != currentUserDetails.id;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfileScreen(
                              utilisateurId: widget.annonce.utilisateur.id,
                              isDifferentUser: isDifferentUser,
                              utilisateur: widget.annonce.utilisateur,
                            ),
                          ),
                        );
                      } else {
                        print('Impossible de récupérer les détails de l\'utilisateur.');
                      }
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 25,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Utilisateur? currentUserDetails = await _authService.getCurrentUserDetails();

                        if (currentUserDetails != null) {
                          bool isDifferentUser = widget.annonce.utilisateur.id != currentUserDetails.id;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                utilisateurId: widget.annonce.utilisateur.id,
                                isDifferentUser: isDifferentUser,
                                utilisateur: widget.annonce.utilisateur,
                              ),
                            ),
                          );
                        } else {
                          print('Impossible de récupérer les détails de l\'utilisateur.');
                        }
                      },
                      child: Text(
                        utilisateurNom ?? '',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 5),
                    _buildStarRating(moyenneNotes),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
