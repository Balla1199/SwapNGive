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
    
    // Vérification du format de l'email
    if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adresse e-mail invalide.')),
      );
      return;
    }

    // Créer un objet Utilisateur
    Utilisateur utilisateur = Utilisateur(
      id: '', // L'ID sera défini dans le service après création
      nom: nom,
      email: email,
      motDePasse: password, // Évitez de stocker le mot de passe en clair
      adresse: adresse,
      telephone: telephone,
      dateInscription: DateTime.now(),
      role: Role.client,
    );

    try {
      // Créer l'utilisateur dans Firebase Authentication et Firestore
      await _utilisateurService.createUtilisateur(utilisateur, email, password);
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de l\'inscription. Veuillez réessayer.')),
      );
      print('Erreur lors de l\'inscription : $e'); // Pour le débogage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
              ),
              TextFormField(
                controller: _adresseController,
                decoration: InputDecoration(labelText: 'Adresse'),
              ),
              TextFormField(
                controller: _telephoneController,
                decoration: InputDecoration(labelText: 'Téléphone'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('S\'inscrire'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
