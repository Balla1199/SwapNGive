import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/objet.dart'; // Assurez-vous d'importer la classe Objet

class Proposition {
  String id;
  String idUtilisateur1;       // Identifiant de l'utilisateur 1
  String idObjet1;             // Identifiant de l'objet 1
  String idUtilisateur2;       // Identifiant de l'utilisateur 2
  String idObjet2;             // Identifiant de l'objet 2
  DateTime dateProposition;
  Annonce annonce;             // Association à une Annonce
  String statut;               // Statut de proposition ("accepté", "refusé", ou "en attente")
  Objet objet2;                // Instance de l'objet 2
  String type;                 // Nouveau champ pour le type de proposition ("échange", "don", etc.)

  // Constructeur avec statut par défaut "en attente"
  Proposition({
    required this.id,                  // Ajout de l'ID dans le constructeur
    required this.idUtilisateur1,
    required this.idObjet1,
    required this.idUtilisateur2,
    required this.idObjet2,
    required this.dateProposition,
    required this.annonce,
    this.statut = 'en attente',        // Valeur par défaut pour le statut
    required this.objet2,              // Initialisation de l'objet 2
    required this.type,                // Initialisation du type de proposition
  });

  // Convertir l'objet proposition en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,                         // Inclure l'ID dans le JSON
      'idUtilisateur1': idUtilisateur1,
      'idObjet1': idObjet1,
      'idUtilisateur2': idUtilisateur2,
      'idObjet2': idObjet2,
      'dateProposition': dateProposition.toIso8601String(),
      'annonce': annonce.toJson(),      // Sérialiser l'objet Annonce
      'statut': statut,                 // Inclure le statut dans le JSON
      'objet2': objet2.toMap(),         // Inclure objet2 dans le JSON
      'type': type,                     // Inclure le type dans le JSON
    };
  }

  // Créer un objet Proposition à partir de JSON
  factory Proposition.fromJson(Map<String, dynamic> json) {
    return Proposition(
      id: json['id'],                   // Désérialiser l'ID
      idUtilisateur1: json['idUtilisateur1'],
      idObjet1: json['idObjet1'],
      idUtilisateur2: json['idUtilisateur2'],
      idObjet2: json['idObjet2'],
      dateProposition: DateTime.parse(json['dateProposition']),
      annonce: Annonce.fromJson(json['annonce']), // Désérialiser l'Annonce
      statut: json['statut'],           // Désérialiser le statut
      objet2: Objet.fromMap(json['objet2']), // Désérialiser l'objet 2
      type: json['type'],               // Désérialiser le type
    );
  }

  // Méthodes pour mettre à jour le statut
  void accepter() {
    statut = 'accepté';
  }

  void refuser() {
    statut = 'refusé';
  }
}
