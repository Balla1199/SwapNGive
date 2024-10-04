import 'package:cloud_firestore/cloud_firestore.dart';

class Avis {
  final String id; // Identifiant unique de l'avis
  final String utilisateurId; // Identifiant de l'utilisateur qui a laissé l'avis
  final String utilisateurEvalueId; // Identifiant de l'utilisateur évalué
  final String annonceId; // Identifiant de l'annonce associée
  final String typeAnnonce; // Type de l'annonce (échange ou don)
  final String contenu; // Contenu de l'avis
  final double note; // Note de l'avis (1 à 5)
  final DateTime dateCreation; // Date de création de l'avis

  // Constructeur
  Avis({
    required this.id,
    required this.utilisateurId,
    required this.utilisateurEvalueId,
    required this.annonceId, // Ajout de l'identifiant de l'annonce
    required this.typeAnnonce, // Ajout du type d'annonce (échange ou don)
    required this.contenu,
    required this.note,
    required this.dateCreation,
  }) {
    if (note < 1 || note > 5) {
      throw Exception("La note doit être comprise entre 1 et 5.");
    }
  }

  // Convertir un avis en Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'utilisateurId': utilisateurId,
      'utilisateurEvalueId': utilisateurEvalueId,
      'annonceId': annonceId, // Ajout de l'annonceId
      'typeAnnonce': typeAnnonce, // Ajout du type d'annonce
      'contenu': contenu,
      'note': note,
      'dateCreation': dateCreation.toIso8601String(),
    };
  }

  // Créer un avis à partir d'une Map Firestore
  factory Avis.fromMap(String id, Map<String, dynamic> map) {
    return Avis(
      id: id,
      utilisateurId: map['utilisateurId'] ?? '',
      utilisateurEvalueId: map['utilisateurEvalueId'] ?? '',
      annonceId: map['annonceId'] ?? '', // Récupération de l'annonceId
      typeAnnonce: map['typeAnnonce'] ?? '', // Récupération du type d'annonce
      contenu: map['contenu'] ?? '',
      note: (map['note'] ?? 0).toDouble(),
      dateCreation: DateTime.parse(map['dateCreation'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Créer un avis à partir d'un DocumentSnapshot Firestore
  factory Avis.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Avis(
      id: doc.id,
      utilisateurId: data['utilisateurId'] ?? '',
      utilisateurEvalueId: data['utilisateurEvalueId'] ?? '',
      annonceId: data['annonceId'] ?? '', // Récupération de l'annonceId
      typeAnnonce: data['typeAnnonce'] ?? '', // Récupération du type d'annonce
      contenu: data['contenu'] ?? '',
      note: (data['note'] ?? 0).toDouble(),
      dateCreation: DateTime.parse(data['dateCreation'] ?? DateTime.now().toIso8601String()),
    );
  }
}
