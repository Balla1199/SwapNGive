import 'package:flutter/material.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/services/utilisateur_service.dart';

class UtilisateurFormScreen extends StatefulWidget {
  final Utilisateur? utilisateur;

  UtilisateurFormScreen({this.utilisateur});

  @override
  _UtilisateurFormScreenState createState() => _UtilisateurFormScreenState();
}

class _UtilisateurFormScreenState extends State<UtilisateurFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _nom, _email, _motDePasse, _adresse, _telephone;
  Role _role = Role.client;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    if (widget.utilisateur != null) {
      _nom = widget.utilisateur!.nom;
      _email = widget.utilisateur!.email;
      _motDePasse = ''; // Pour des raisons de sécurité
      _adresse = widget.utilisateur!.adresse;
      _telephone = widget.utilisateur!.telephone;
      _role = widget.utilisateur!.role;
    } else {
      _nom = '';
      _email = '';
      _motDePasse = '';
      _adresse = '';
      _telephone = '';
    }
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Utilisateur utilisateur = Utilisateur(
        id: widget.utilisateur?.id ?? DateTime.now().toString(),
        nom: _nom,
        email: _email,
        motDePasse: _motDePasse,
        adresse: _adresse,
        telephone: _telephone,
        dateInscription: widget.utilisateur?.dateInscription ?? DateTime.now(),
        role: _role,
      );

      if (widget.utilisateur == null) {
        try {
          await UtilisateurService().createUtilisateur(utilisateur, _email, _motDePasse);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Utilisateur créé avec succès')));
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur : $e')));
        }
      } else {
        await UtilisateurService().updateUtilisateur(widget.utilisateur!.id, utilisateur);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Utilisateur mis à jour avec succès')));
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFD9A9A9),
        title: Text(
          widget.utilisateur == null ? 'Créer un utilisateur' : 'Modifier un utilisateur',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Color.fromARGB(255, 246, 247, 248), // Changement de la couleur de fond ici
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                _buildTextField('Nom', Icons.person, _nom, (value) => _nom = value!, 'Veuillez entrer un nom'),
                SizedBox(height: 20),
                _buildTextField('Email', Icons.email, _email, (value) => _email = value!, 'Veuillez entrer un email'),
                SizedBox(height: 20),
                _buildTextField('Mot de passe', Icons.lock, '', (value) => _motDePasse = value!, 
                    'Veuillez entrer un mot de passe', true), // Le champ mot de passe
                SizedBox(height: 20),
                _buildTextField('Adresse', Icons.location_on, _adresse, (value) => _adresse = value!),
                SizedBox(height: 20),
                _buildTextField('Téléphone', Icons.phone, _telephone, (value) => _telephone = value!),
                SizedBox(height: 20),
                DropdownButtonFormField<Role>(
                  value: _role,
                  onChanged: (Role? newValue) {
                    setState(() {
                      _role = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Rôle',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  items: Role.values.map((Role role) {
                    return DropdownMenuItem<Role>(
                      value: role,
                      child: Text(role.toString().split('.').last),
                    );
                  }).toList(),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Color(0xFFD9A9A9), backgroundColor: Color(0xFFFFFFFF), 
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Enregistrer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, String initialValue, Function(String?) onSaved,
      [String? validatorMessage, bool isPassword = false]) {
    return TextFormField(
      initialValue: initialValue,
      obscureText: isPassword, 
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFFD9A9A9)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      onSaved: onSaved,
      validator: (value) {
        if (validatorMessage != null && (value == null || value.isEmpty)) {
          return validatorMessage;
        }
        return null;
      },
    );
  }
}
