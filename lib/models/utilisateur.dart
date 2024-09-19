class Utilisateur {
   String id;
   String nom;
   String email;
   String motDePasse;
  String adresse;
   String telephone;
   DateTime dateInscription;
  String role;

  Utilisateur({
    required this.id,
    required this.nom,
    required this.email,
    required this.motDePasse,
    required this.adresse,
    required this.telephone,
    required this.dateInscription,
    this.role = 'client',  // Rôle par défaut "client"
  });

  // Méthode pour convertir l'utilisateur en Map (utile pour Firebase Firestore par exemple)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'email': email,
      'adresse': adresse,
      'telephone': telephone,
      'dateInscription': dateInscription.toIso8601String(),
      'role': role,
    };
  }

  // Méthode pour créer un Utilisateur à partir d'un Map (lors de la récupération des données)
  factory Utilisateur.fromMap(Map<String, dynamic> map) {
    return Utilisateur(
      id: map['id'],
      nom: map['nom'],
      email: map['email'],
      motDePasse: map['motDePasse'],
      adresse: map['adresse'],
      telephone: map['telephone'],
      dateInscription: DateTime.parse(map['dateInscription']),
      role: map['role'] ?? 'client',
    );
  }
}
