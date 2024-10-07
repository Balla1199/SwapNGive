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
    id: json['id'] ?? '', // Utilisez une chaîne vide comme valeur par défaut
    titre: json['titre'] ?? 'Titre non défini',
    description: json['description'] ?? 'Description non définie',
    date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(), // Si la date est manquante, utilisez la date actuelle
    type: TypeAnnonce.values.firstWhere(
      (e) => e.toString() == 'TypeAnnonce.' + (json['type'] ?? 'don'), // Valeur par défaut si le type est manquant
      orElse: () => TypeAnnonce.don,
    ),
    utilisateur: Utilisateur.fromMap(json['utilisateur'] ?? {}), // Fournissez un objet vide si l'utilisateur est nul
    categorie: Categorie.fromMap(json['categorie'] ?? {}), // Idem pour la catégorie
    objet: Objet.fromMap(json['objet'] ?? {}), // Vérifiez que l'objet est présent
    etat: Etat.fromMap(json['etat'] ?? {}), // Vérifiez que l'état est présent
    likes: json['likes'] ?? 0, // Par défaut, 0 likes
    statut: StatutAnnonce.values.firstWhere(
      (e) => e.toString() == 'StatutAnnonce.' + (json['statut'] ?? 'disponible'), // Valeur par défaut si le statut est manquant
      orElse: () => StatutAnnonce.disponible,
    ),
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
