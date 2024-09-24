

import 'package:swapngive/models/Annonce.dart';

class Echange {
  String idUtilisateur1;
  String idObjet1;
  String idUtilisateur2;
  String idObjet2;
  DateTime dateEchange;
  Annonce annonce; // Association to an Annonce

  Echange({
    required this.idUtilisateur1,
    required this.idObjet1,
    required this.idUtilisateur2,
    required this.idObjet2,
    required this.dateEchange,
    required this.annonce, // Annonce relation
  });

  // Convertir l'objet Echange en JSON
  Map<String, dynamic> toJson() {
    return {
      'idUtilisateur1': idUtilisateur1,
      'idObjet1': idObjet1,
      'idUtilisateur2': idUtilisateur2,
      'idObjet2': idObjet2,
      'dateEchange': dateEchange.toIso8601String(),
      'annonce': annonce.toJson(), // Serialize the Annonce object
    };
  }

  // Créer un objet Echange à partir de JSON
  factory Echange.fromJson(Map<String, dynamic> json) {
    return Echange(
      idUtilisateur1: json['idUtilisateur1'],
      idObjet1: json['idObjet1'],
      idUtilisateur2: json['idUtilisateur2'],
      idObjet2: json['idObjet2'],
      dateEchange: DateTime.parse(json['dateEchange']),
      annonce: Annonce.fromJson(json['annonce']), // Deserialize the Annonce
    );
  }
}
