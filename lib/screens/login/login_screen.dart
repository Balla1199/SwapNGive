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
      automaticallyImplyLeading: false,
    ),
    body: Stack(
      children: [
        // Premier div : Fond coloré en D9A9A9
        Container(
          color: Color(0xFFD9A9A9),
          height: double.infinity,
          width: double.infinity,
        ),
        // Deuxième div : Div supérieur en blanc avec des champs et un bouton
        Positioned(
          left: 0,
          right: 0,
          bottom: 80,
          child: Container(
            height: MediaQuery.of(context).size.height * 1.0,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(60),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Image.asset(
                  'assets/images/logo.jpg',
                  height: 250,
                  width: 250,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgotPassword');
                    },
                    child: Text(
                      'Mot de passe oublié?',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                SizedBox(height: 40),
                Container(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _login,
                    child: Text('Se connecter'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color(0xFFD9A9A9),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/inscription');
                  },
                  child: Text('Créer un compte'),
                ),
                SizedBox(height: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('ou'),
                    SizedBox(height: 8),
                    Image.asset(
                      'assets/images/google.png',
                      height: 30,
                      width: 30,
                      fit: BoxFit.contain,
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
