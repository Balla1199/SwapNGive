import 'package:flutter/material.dart';
import 'package:swapngive/services/utilisateur_service.dart';
import 'package:swapngive/models/utilisateur.dart';

class InscriptionScreen extends StatefulWidget {
  @override
  _InscriptionScreenState createState() => _InscriptionScreenState();
}

class _InscriptionScreenState extends State<InscriptionScreen> {
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final UtilisateurService _utilisateurService = UtilisateurService();
  
  Future<void> _register() async {
    final nom = _nomController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final adresse = _adresseController.text.trim();
    final telephone = _telephoneController.text.trim();

    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adresse e-mail invalide.')),
      );
      return;
    }

    Utilisateur utilisateur = Utilisateur(
      id: '',
      nom: nom,
      email: email,
      motDePasse: password,
      adresse: adresse,
      telephone: telephone,
      dateInscription: DateTime.now(),
      role: Role.client,
    );

    try {
      await _utilisateurService.createUtilisateur(utilisateur, email, password);
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de l\'inscription. Veuillez réessayer.')),
      );
      print('Erreur lors de l\'inscription : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Permet à la vue de se réajuster avec le clavier
      body: SingleChildScrollView( // Permet le défilement lorsque le clavier apparaît
        child: Column(
          children: [
            // Premier div avec couleur de fond
            Container(
              color: Color(0xFFD9A9A9), // Couleur de fond du premier div
              height: MediaQuery.of(context).size.height, // Prend toute la hauteur de l'écran
              child: Column(
                children: [
                  // Conteneur principal pour le contenu
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0), // Padding à gauche et à droite + espacement intérieur vertical
                      decoration: BoxDecoration(
                        color: Colors.white, // Couleur de fond blanc
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(60), // Bords arrondis en bas
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Logo en haut
                          Image.asset(
                            'assets/images/logo.jpg', // Chemin vers le logo
                            height: 100, // Hauteur du logo
                            width: 100,  // Largeur du logo
                          ),
                          SizedBox(height: 10), // Espacement entre le logo et les champs de saisie
                          
                          // Champ pour le nom
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding à gauche et à droite
                            child: TextFormField(
                              controller: _nomController,
                              decoration: InputDecoration(
                                labelText: 'Nom',
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),

                          // Champ pour l'email
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding à gauche et à droite
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          SizedBox(height: 10),

                          // Champ pour le mot de passe
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding à gauche et à droite
                            child: TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Mot de passe',
                                prefixIcon: Icon(Icons.lock),
                              ),
                              obscureText: true,
                            ),
                          ),
                          SizedBox(height: 10),

                          // Champ pour l'adresse
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding à gauche et à droite
                            child: TextFormField(
                              controller: _adresseController,
                              decoration: InputDecoration(
                                labelText: 'Adresse',
                                prefixIcon: Icon(Icons.location_on),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),

                          // Champ pour le téléphone
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0), // Padding à gauche et à droite
                            child: TextFormField(
                              controller: _telephoneController,
                              decoration: InputDecoration(
                                labelText: 'Téléphone',
                                prefixIcon: Icon(Icons.phone),
                              ),
                            ),
                          ),

                          SizedBox(height: 30),

                          // Bouton d'inscription
                          Container(
                            width: 300, // Largeur du bouton
                            height: 50, // Hauteur du bouton
                            child: ElevatedButton(
                              onPressed: _register,
                              child: Text('S\'inscrire'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Color(0xFFD9A9A9),
                              ),
                            ),
                          ),
                          SizedBox(height: 15), // Espacement avant le bouton de retour

                          // Bouton de retour
                          Container(
                            width: 300, // Largeur du bouton
                            height: 50, // Hauteur du bouton
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context); // Retour à l'écran précédent
                              },
                              child: Text('Retour'),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white, // Texte en blanc
                                backgroundColor: Colors.black, // Fond noir
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 140), // Espace en bas du deuxième container
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
