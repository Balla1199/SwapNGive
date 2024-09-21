import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Ajouter des logs pour afficher l'email et le mot de passe saisis
    print('Tentative de connexion avec :');
    print('Email: $email');
    print('Mot de passe: $password');

    try {
      User? user = await _authService.loginUser(email, password);

      if (user != null) {
        print('Connexion réussie pour l\'utilisateur: ${user.email}');

        // Récupération des détails utilisateur depuis Firestore
        Utilisateur? utilisateur = await _authService.getUserDetails(user.uid);

        print('Utilisateur récupéré : ${utilisateur?.email}');

        if (utilisateur != null) {
          // Redirigez vers HomeScreen après la connexion
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(utilisateur: utilisateur),
            ),
          );
        } else {
          print('Échec de la connexion : Utilisateur non trouvé dans Firestore');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Utilisateur non trouvé dans Firestore')),
          );
        }
      } else {
        print('Échec de la connexion : Utilisateur non trouvé');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la connexion. Veuillez vérifier vos informations.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Gestion spécifique des erreurs Firebase Auth
      String errorMessage;
      if (e.code == 'user-not-found') {
        errorMessage = 'Aucun utilisateur trouvé pour cet e-mail.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Mot de passe incorrect.';
      } else {
        errorMessage = 'Erreur lors de la connexion : ${e.message}';
      }
      print('Erreur lors de la connexion : $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Gestion des autres erreurs générales
      print('Erreur générale lors de la connexion : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Une erreur s\'est produite. Veuillez réessayer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Se connecter'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/inscription');
              },
              child: Text('Créer un compte'),
            ),
          ],
        ),
      ),
    );
  }
}
