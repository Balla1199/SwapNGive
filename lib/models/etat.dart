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
}
