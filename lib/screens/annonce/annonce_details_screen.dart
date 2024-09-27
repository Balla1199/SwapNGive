import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/screens/don/MessageDon_screen.dart';
import 'package:swapngive/screens/echange/objetechange_screen.dart';
import 'package:swapngive/services/auth_service.dart'; 


class AnnonceDetailsScreen extends StatefulWidget {
  final Annonce annonce;

  const AnnonceDetailsScreen({Key? key, required this.annonce}) : super(key: key);

  @override
  _AnnonceDetailsScreenState createState() => _AnnonceDetailsScreenState();
}

class _AnnonceDetailsScreenState extends State<AnnonceDetailsScreen> {
  final AuthService _authService = AuthService(); 
  bool isDifferentUser = false; 

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  void _checkUser() async {
    var currentUser = await _authService.getCurrentUserDetails(); 
    if (currentUser != null && currentUser.id != widget.annonce.utilisateur.id) {
      setState(() {
        isDifferentUser = true;
      });
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
                onPressed: () {
                  // Si l'annonce est de type "don", on redirige vers la page DemandeMessageScreen
                  if (widget.annonce.type == TypeAnnonce.don) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessageDonScreen(
                          annonce: widget.annonce, // Passez l'annonce
                          idObjet: widget.annonce.objet.id, // Passez l'ID de l'objet
                        ),
                      ),
                    );
                  } else {
                    // Sinon, on conserve la logique pour les échanges
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
                  }
                },
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
          ],
        ),
      ),
    );
  }
}
