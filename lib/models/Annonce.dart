import 'package:swapngive/models/Categorie.dart';
import 'package:swapngive/models/objet.dart';
import 'package:swapngive/models/utilisateur.dart';


// Enum pour le type d'annonce
enum TypeAnnonce {
  don,
  echange,
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
  });

  // Méthode pour convertir l'objet Annonce en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'date': date.toIso8601String(), // Convertir la date au format ISO
      'type': type.toString().split('.').last, // Convertir l'enum en string
      'utilisateur': utilisateur.toMap(), // Convertir l'utilisateur en Map
      'categorie': categorie.toMap(), // Utiliser toMap pour la catégorie
      'objet': objet.toMap(), // Utiliser toMap pour l'objet
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
      utilisateur: Utilisateur.fromMap(json['utilisateur']), // Utiliser fromMap pour l'utilisateur
      categorie: Categorie.fromMap(json['categorie']), // Utiliser fromMap pour la catégorie
      objet: Objet.fromMap(json['objet']), // Utiliser fromMap pour l'objet
    );
  }
}
