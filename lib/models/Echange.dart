import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/objet.dart';

class Echange {
  String id; // Champ ID pour identifier l'échange
  String idUtilisateur1; // ID de l'utilisateur 1
  String idObjet1; // ID de l'objet 1
  String idUtilisateur2; // ID de l'utilisateur 2
  Objet objet2; // Objet échangé par l'utilisateur 2
  DateTime dateEchange; // Date de l'échange
  Annonce annonce; // L'annonce liée à l'échange
  String? message; // Message facultatif
  String statut; // Statut de l'échange ("attente", "accepté", "refusé")

  Echange({
    required this.id, // Champ requis pour l'ID de l'échange
    required this.idUtilisateur1,
    required this.idObjet1,
    required this.idUtilisateur2,
    required this.objet2, // L'objet 2 doit être une instance de Objet
    required this.dateEchange,
    required this.annonce, // L'annonce liée à l'échange
    this.message, // Message facultatif
    this.statut = 'attente', // Valeur par défaut du statut : "attente"
  });

  // Convertir l'objet Echange en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Inclure l'id dans la conversion
      'idUtilisateur1': idUtilisateur1,
      'idObjet1': idObjet1,
      'idUtilisateur2': idUtilisateur2,
      'objet2': objet2.toMap(), // Utiliser la méthode toMap() de l'objet2
      'dateEchange': dateEchange.toIso8601String(), // Convertir la date au format ISO
      'annonce': annonce.toJson(), // Utiliser la sérialisation JSON de l'annonce
      'message': message, // Inclure le message s'il existe
      'statut': statut, // Inclure le statut actuel
    };
  }

  // Créer un objet Echange à partir d'une Map venant de Firestore
  factory Echange.fromMap(Map<String, dynamic> map) {
    return Echange(
      id: map['id'], // Récupérer l'id à partir de la Map
      idUtilisateur1: map['idUtilisateur1'],
      idObjet1: map['idObjet1'],
      idUtilisateur2: map['idUtilisateur2'],
      objet2: Objet.fromMap(map['objet2']), // Créer l'objet2 à partir de la Map
      dateEchange: DateTime.parse(map['dateEchange']), // Parser la date ISO
      annonce: Annonce.fromJson(map['annonce']), // Désérialiser l'annonce
      message: map['message'], // Champ facultatif pour le message
      statut: map['statut'] ?? 'attente', // Valeur par défaut "attente"
    );
  }

  // Mettre à jour le statut de l'échange
  void mettreAJourStatut(String nouveauStatut) {
    statut = nouveauStatut;
  }
}
