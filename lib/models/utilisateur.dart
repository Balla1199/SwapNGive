import 'package:cloud_firestore/cloud_firestore.dart';

// Enum pour le rôle
enum Role {
  admin,
  client, user,
  // Ajoutez d'autres rôles ici si nécessaire
}

class Utilisateur {
  String id;
  String nom;
  String email;
  String motDePasse;
  String adresse;
  String telephone;
  DateTime dateInscription;
  Role role;

  // Constructeur de la classe Utilisateur
  Utilisateur({
    required this.id,
    required this.nom,
    required this.email,
    required this.motDePasse,
    required this.adresse,
    required this.telephone,
    required this.dateInscription,
    required this.role,
  });

  // Convertir un utilisateur en Map pour Firestore ou autre base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'motDePasse': motDePasse,
      'adresse': adresse,
      'telephone': telephone,
      'dateInscription': dateInscription.toIso8601String(),
      // Convertir l'énumération en chaîne de caractères pour Firestore
      'role': role.toString().split('.').last,
    };
  }

  // Méthode pour créer un Utilisateur à partir d'un Map (récupéré de Firestore ou autre base de données)
  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'] ?? '',
      nom: map['nom'] ?? '',
      email: map['email'] ?? '',
      motDePasse: map['motDePasse'] ?? '',
      adresse: map['adresse'] ?? '',
      telephone: map['telephone'] ?? '',
      dateInscription: DateTime.parse(map['dateInscription'] ?? DateTime.now().toIso8601String()),
      role: _stringToRole(map['role'] ?? 'client'), // Gestion de la chaîne "role"
    );
  }

  // Méthode pour créer un Utilisateur à partir d'un DocumentSnapshot Firestore
  factory Utilisateur.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Gestion de la conversion pour la date d'inscription
    final dateInscription = data['dateInscription'];
    DateTime parsedDate;
    if (dateInscription is Timestamp) {
      parsedDate = dateInscription.toDate();
    } else if (dateInscription is String) {
      parsedDate = DateTime.parse(dateInscription);
    } else {
      parsedDate = DateTime.now(); // Valeur par défaut en cas d'erreur
    }

    return Utilisateur(
      id: doc.id,
      nom: data['nom'] ?? '',
      email: data['email'] ?? '',
      motDePasse: data['motDePasse'] ?? '',
      adresse: data['adresse'] ?? '',
      telephone: data['telephone'] ?? '',
      dateInscription: parsedDate,
      role: _stringToRole(data['role'] ?? 'client'), // Conversion de la chaîne "role"
    );
  }

  // Fonction pour convertir une chaîne de caractères en Role
  static Role _stringToRole(String roleString) {
    switch (roleString) {
      case 'admin':
        return Role.admin;
      case 'client':
        return Role.client;
      default:
        return Role.client; // Rôle par défaut si le rôle est inconnu
    }
  }
}
