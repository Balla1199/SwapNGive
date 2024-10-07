import 'package:swapngive/models/Categorie.dart';
import 'package:swapngive/models/etat.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/models/utilisateur.dart';

// Enum pour le type d'annonce
enum TypeAnnonce {
  don,
  echange,
}

// Enum pour le statut de l'annonce
enum StatutAnnonce {
  disponible,
  indisponible,
}

// Modèle Annonce mis à jour avec des objets complets
class Annonce {
  String id;
  String titre;
  String description;
  DateTime date;
  TypeAnnonce type;
  Utilisateur utilisateur;
  Categorie categorie;
  Objet objet;
  Etat etat; // Utilisation de l'objet Etat
  int likes; // Nouveau champ pour les likes
  StatutAnnonce statut; // Nouveau champ pour le statut de l'annonce

  // Constructeur
  Annonce({
    required this.id,
    required this.titre,
    required this.description,
    required this.date,
    required this.type,
    required this.utilisateur,
    required this.categorie,
    required this.objet,
    required this.etat,
    this.likes = 0, // Initialiser à 0 likes par défaut
    this.statut = StatutAnnonce.disponible, // Initialiser à 'disponible' par défaut
  });

  // Méthode pour convertir l'objet Annonce en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'utilisateur': utilisateur.toMap(),
      'categorie': categorie.toMap(),
      'objet': objet.toMap(),
      'etat': etat.toMap(), // Ajouter l'état au JSON
      'likes': likes, // Ajouter les likes au JSON
      'statut': statut.toString().split('.').last, // Ajouter le statut au JSON
    };
  }

  // Méthode pour créer un objet Annonce à partir de JSON
  factory Annonce.fromJson(Map<String, dynamic> json) {
    return Annonce(
      id: json['id'],
      titre: json['titre'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      type: TypeAnnonce.values.firstWhere((e) => e.toString() == 'TypeAnnonce.' + json['type']),
      utilisateur: Utilisateur.fromMap(json['utilisateur']),
      categorie: Categorie.fromMap(json['categorie']),
      objet: Objet.fromMap(json['objet']),
      etat: Etat.fromMap(json['etat']), // Récupérer l'état à partir du JSON
      likes: json['likes'] ?? 0, // Récupérer les likes ou initialiser à 0
      statut: StatutAnnonce.values.firstWhere((e) => e.toString() == 'StatutAnnonce.' + json['statut']),
    );
  }

  // Convertir l'objet Annonce en Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'date': date.toIso8601String(),
      'type': type.toString().split('.').last,
      'utilisateur': utilisateur.toMap(),
      'categorie': categorie.toMap(),
      'objet': objet.toMap(),
      'etat': etat.toMap(), // Ajouter l'état au Map
      'likes': likes, // Ajouter les likes au Map
      'statut': statut.toString().split('.').last, // Ajouter le statut au Map
    };
  }
}
