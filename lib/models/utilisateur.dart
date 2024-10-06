import 'package:cloud_firestore/cloud_firestore.dart';

// Enum pour le rôle
enum Role {
  admin,
  client,
  user,
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
  String? photoProfil; // URL de la photo de profil, nullable

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
    this.photoProfil, // Champ facultatif pour la photo de profil
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
      'role': role.toString().split('.').last,
      'photoProfil': photoProfil, // Inclure la photo de profil dans la Map
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
      photoProfil: map['photoProfil'], // Récupérer la photo de profil (nullable)
    );
  }

  // Méthode pour créer un Utilisateur à partir d'un DocumentSnapshot Firestore
  factory Utilisateur.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

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
      photoProfil: data['photoProfil'], // Récupérer l'URL de la photo de profil
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

  // Convertir le rôle en chaîne de caractères
  String getRoleString() {
    return role.toString().split('.').last; // 'admin', 'client', etc.
  }
}
