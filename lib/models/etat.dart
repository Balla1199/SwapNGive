class Etat {
  String id;
  String nom;

  Etat({
    required this.id,
    required this.nom,
  });

  // Méthode pour convertir un Etat en Map (pour l'enregistrement dans Firestore par exemple)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
    };
  }

  // Méthode pour créer un Etat à partir d'un Map (lors de la récupération des données)
  factory Etat.fromMap(Map<String, dynamic> map) {
    return Etat(
      id: map['id'],
      nom: map['nom'],
    );
  }

  // Implémentation de l'égalité
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Etat) return false;
    return id == other.id; // Vérifiez l'égalité sur l'id
  }

  // Méthode pour obtenir le hashCode
  @override
  int get hashCode => id.hashCode; // Utilisez l'id pour le hashCode
}
