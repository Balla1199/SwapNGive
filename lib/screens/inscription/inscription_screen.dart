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
      Navigator.pushReplacementNamed(context, '/home');
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
      appBar: AppBar(
        title: Text('Inscription'),
      ),
      body: Stack(
        children: [
          // Premier div avec couleur de fond
          Container(
            color: Color(0xFFD9A9A9), // Couleur de fond du premier div
            height: MediaQuery.of(context).size.height, // Prend toute la hauteur de l'écran
          ),

          // Deuxième div placé au-dessus du premier
          Positioned(
            left: 0,
            right: 0,
            bottom: 100, // Laisse un espace en bas
            child: Container(
              height: MediaQuery.of(context).size.height * 0.85, // Couvre 85% de la hauteur
              padding: EdgeInsets.all(16), // Espacement intérieur
              decoration: BoxDecoration(
                color: Colors.white, // Couleur de fond blanc
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(60) // Bords arrondis en haut 
                ),
              ),
              child: Column(
                 mainAxisAlignment:MainAxisAlignment.end,
                children: [
                  // Champ pour le nom
                  TextFormField(
                    controller: _nomController,
                    decoration: InputDecoration(
                      labelText: 'Nom',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Champ pour l'email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 10),
                  // Champ pour le mot de passe
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 10),
                  // Champ pour l'adresse
                  TextFormField(
                    controller: _adresseController,
                    decoration: InputDecoration(
                      labelText: 'Adresse',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  SizedBox(height: 10),
                  // Champ pour le téléphone
                  TextFormField(
                    controller: _telephoneController,
                    decoration: InputDecoration(
                      labelText: 'Téléphone',
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Bouton d'inscription
                  ElevatedButton(
                    onPressed: _register,
                    child: Text('S\'inscrire'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, 
                      backgroundColor: Color(0xFFD9A9A9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
