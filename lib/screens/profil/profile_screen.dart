import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/screens/login/login_screen.dart';
import 'package:swapngive/services/auth_service.dart';



class ProfileScreen extends StatefulWidget {
  final Utilisateur? utilisateur;

  const ProfileScreen({this.utilisateur});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    print('Page de profil initialisée');
    if (widget.utilisateur != null) {
      print('Utilisateur trouvé : ${widget.utilisateur!.nom}');
      print('Adresse de l\'utilisateur : ${widget.utilisateur!.adresse}');
    } else {
      print('Aucun utilisateur fourni');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Construction du widget de profil...');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              print('Déconnexion...');
              await _authService.logout();
              print('Utilisateur déconnecté');
              // Rediriger vers la page de connexion
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: widget.utilisateur == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nom:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.utilisateur!.nom),
                        const SizedBox(height: 16),
                        const Text(
                          'Email:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.utilisateur!.email),
                        const SizedBox(height: 16),
                        const Text(
                          'Téléphone:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.utilisateur!.telephone),
                        const SizedBox(height: 16),
                        const Text(
                          'Adresse:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(widget.utilisateur!.adresse),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
