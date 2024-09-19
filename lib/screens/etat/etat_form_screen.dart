import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Importer le package UUID
import 'package:swapngive/models/etat.dart';
import 'package:swapngive/services/etat_service.dart';

class EtatFormScreen extends StatefulWidget {
  final Etat? etat;

  EtatFormScreen({this.etat}); // Si un état est fourni, on est en mode modification

  @override
  _EtatFormulaireState createState() => _EtatFormulaireState();
}

class _EtatFormulaireState extends State<EtatFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final EtatService etatService = EtatService();
  var uuid = Uuid(); // Créez une instance de Uuid pour générer des identifiants

  late String _id;
  late String _nom;

  @override
  void initState() {
    super.initState();
    if (widget.etat != null) {
      _id = widget.etat!.id;
      _nom = widget.etat!.nom;
    } else {
      _id = uuid.v4(); // Générer un identifiant unique lors de la création d'un nouvel état
      _nom = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.etat != null ? 'Modifier État' : 'Ajouter État'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _nom,
                decoration: InputDecoration(labelText: 'Nom de l\'État'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
                onSaved: (value) {
                  _nom = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (widget.etat != null) {
                      // Modification
                      etatService.modifierEtat(Etat(id: _id, nom: _nom));
                    } else {
                      // Ajout avec un UUID généré
                      etatService.ajouterEtat(Etat(id: _id, nom: _nom));
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.etat != null ? 'Modifier' : 'Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
