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

  // Surcharger == pour comparer deux instances de Categorie
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Categorie &&
      other.id == id &&
      other.nom == nom;
  }

  // Surcharger hashCode pour garantir l'unicité
  @override
  int get hashCode => id.hashCode ^ nom.hashCode;
}
