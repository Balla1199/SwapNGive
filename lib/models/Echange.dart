import 'package:swapngive/models/Annonce.dart';

class Echange {
  String idUtilisateur1;
  String idObjet1;
  String idUtilisateur2;
  String idObjet2;
  DateTime dateEchange;
  Annonce annonce; // Association avec une annonce
  String? message; // Message optionnel
  String statut; // Statut de l'échange ("attente", "accepté", "refusé")

  Echange({
    required this.idUtilisateur1,
    required this.idObjet1,
    required this.idUtilisateur2,
    required this.idObjet2,
    required this.dateEchange,
    required this.annonce, // Association avec l'annonce
    this.message, // Optionnel
    this.statut = 'attente', // Par défaut à "attente"
  });

  // Convertir l'objet Echange en JSON
  Map<String, dynamic> toJson() {
    return {
      'idUtilisateur1': idUtilisateur1,
      'idObjet1': idObjet1,
      'idUtilisateur2': idUtilisateur2,
      'idObjet2': idObjet2,
      'dateEchange': dateEchange.toIso8601String(),
      'annonce': annonce.toJson(), // Sérialiser l'objet Annonce
      'message': message, // Champ message
      'statut': statut, // Champ statut en tant que chaîne de caractères
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
      annonce: Annonce.fromJson(json['annonce']), // Désérialiser l'annonce
      message: json['message'], // Message optionnel
      statut: json['statut'] ?? 'attente', // Valeur par défaut "attente" si non définie
    );
  }
}
