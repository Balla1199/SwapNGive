import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:swapngive/screens/home/home_screen.dart';
import 'package:swapngive/services/auth_service.dart';
import 'package:swapngive/models/utilisateur.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  // Méthode pour gérer la connexion utilisateur
  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      User? user = await _authService.loginUser(email, password);

      if (user != null) {
        Utilisateur? utilisateur = await _authService.getUserDetails(user.uid);

        if (utilisateur != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(utilisateur: utilisateur),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Utilisateur non trouvé dans Firestore')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la connexion. Veuillez vérifier vos informations.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'Aucun utilisateur trouvé pour cet e-mail.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Mot de passe incorrect.';
      } else {
        errorMessage = 'Erreur lors de la connexion : ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur s\'est produite. Veuillez réessayer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //title: Text('Connexion'),
      ),
      body: Stack(
        children: [
          // Premier div : Fond coloré en D9A9A9
          Container(
            color: Color(0xFFD9A9A9), // Couleur de fond
            height: double.infinity, // Prend toute la hauteur de l'écran
            width: double.infinity,  // Prend toute la largeur de l'écran
          ),
          // Deuxième div : Div supérieur en blanc avec des champs et un bouton
          Positioned(
            left: 0,
            right: 0,
            bottom: 80, // Laisse un espace en bas
            child: Container(
               height: MediaQuery.of(context).size.height * 1.0, // 80% de la hauteur de l'écran
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
                  // Champ pour l'email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 10), // Espacement entre les champs
                  // Champ pour le mot de passe
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      prefixIcon: Icon(Icons.lock),              
                      ),
                    obscureText: true,
                  ),
                  SizedBox(height: 20), // Espacement avant le bouton
                  // Bouton de connexion
                  ElevatedButton(
                    onPressed: _login,
                    child: Text('Se connecter'),
                    style:ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Color(0xFFD9A9A9),
                    )
                  ),
                  SizedBox(height: 10), // Espacement entre le bouton et le texte
                  // Lien pour créer un compte
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/inscription');
                    },
                    child: Text('Créer un compte'),
                  ),
                  SizedBox(height: 10), // Espacement entre "Créer un compte" et "ou Google"
            // Lien pour Google
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ou'), // Texte "ou" au-dessus
                SizedBox(height: 8), // Espacement entre le texte et l'image
                // Remplace l'icône par une image
                Image.asset(
                  'images/google.png', // Chemin de l'image dans ton projet
                  height: 30, // Définit la hauteur de l'image
                  width: 30,  // Définit la largeur de l'image
                  fit: BoxFit.contain, // Ajuste l'image pour garder ses proportions
                ),
              ],
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
