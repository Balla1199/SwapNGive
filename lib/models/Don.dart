import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/utilisateur.dart';

class Don {
  String id;
  DateTime dateDon;
  String idDonneur;
  Utilisateur receveur; // Remplace l'ID du receveur par une instance de Utilisateur
  String idObjet;
  String? message; // Champ optionnel
  Annonce annonce; // Association à une annonce
  String statut; // "attente" par défaut, peut être mis à jour en "accepté" ou "refusé"

  Don({
    required this.id,
    required this.dateDon,
    required this.idDonneur,
    required this.receveur, // Remplace idReceveur par une instance de Utilisateur
    required this.idObjet,
    this.message, // Champ optionnel
    required this.annonce, // Association obligatoire avec une annonce
    this.statut = 'attente', // Statut par défaut "attente"
  });

  // Convertir un objet Don en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateDon': dateDon.toIso8601String(),
      'idDonneur': idDonneur,
      'receveur': receveur.toMap(), // Sérialiser l'objet Utilisateur en Map
      'idObjet': idObjet,
      'message': message, // Peut être null
      'annonce': annonce.toJson(), // Sérialiser l'objet Annonce
      'statut': statut, // Statut sous forme de chaîne de caractères
    };
  }

  // Convertir un objet Don en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateDon': dateDon.toIso8601String(),
      'idDonneur': idDonneur,
      'receveur': receveur.toMap(), // Sérialiser l'objet Utilisateur en Map
      'idObjet': idObjet,
      'message': message, // Peut être null
      'annonce': annonce.toMap(), // Utilisez la méthode toMap() sur l'objet Annonce
      'statut': statut, // Statut sous forme de chaîne de caractères
    };
  }

  // Créer un objet Don à partir de JSON
  factory Don.fromJson(Map<String, dynamic> json) {
    return Don(
      id: json['id'],
      dateDon: DateTime.parse(json['dateDon']),
      idDonneur: json['idDonneur'],
      receveur: Utilisateur.fromMap(json['receveur']), // Désérialiser l'objet Utilisateur à partir d'un Map
      idObjet: json['idObjet'],
      message: json['message'], // Peut être null
      annonce: Annonce.fromJson(json['annonce']), // Désérialiser l'annonce
      statut: json['statut'], // Statut (attente, accepté, refusé)
    );
  }
}
