class Categorie {
  String id; // Utilisez String pour les IDs de documents Firestore
  String nom;

  Categorie({required this.id, required this.nom});

  // Convertir Categorie en une Map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
    };
  }

  // Convertir une Map en Categorie
  factory Categorie.fromMap(Map<String, dynamic> map) {
    return Categorie(
      id: map['id'] as String,
      nom: map['nom'] as String,
    );
  }
}
