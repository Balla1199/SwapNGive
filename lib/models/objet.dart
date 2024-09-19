class Objet {
  String id;           // Identifiant de l'objet
  String nom;          // Nom de l'objet
  String description;  // Description de l'objet
  String idEtat;       // L'identifiant de l'état de l'objet
  String idCategorie;  // L'identifiant de la catégorie de l'objet
  DateTime dateAjout;  // La date d'ajout de l'objet
  String idUtilisateur;// L'identifiant de l'utilisateur ayant ajouté l'objet
  String imageUrl;     // L'URL ou le chemin de l'image de l'objet

  // Constructeur
  Objet({
    required this.id,
    required this.nom,
    required this.description,
    required this.idEtat,
    required this.idCategorie,
    required this.dateAjout,
    required this.idUtilisateur,
    required this.imageUrl,
  });

  // Convertir un Objet en Map pour Firestore ou autre base de données
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'description': description,
      'idEtat': idEtat,
      'idCategorie': idCategorie,
      'dateAjout': dateAjout.toIso8601String(), // Convertir la date au format ISO
      'idUtilisateur': idUtilisateur,
      'imageUrl': imageUrl, // Ajouter le champ imageUrl dans la Map
    };
  }

  // Convertir une Map en Objet
  factory Objet.fromMap(Map<String, dynamic> map) {
    return Objet(
      id: map['id'] as String,
      nom: map['nom'] as String,
      description: map['description'] as String,
      idEtat: map['idEtat'] as String,
      idCategorie: map['idCategorie'] as String,
      dateAjout: DateTime.parse(map['dateAjout'] as String), // Convertir la chaîne en DateTime
      idUtilisateur: map['idUtilisateur'] as String,
      imageUrl: map['imageUrl'] as String, // Récupérer l'URL de l'image depuis la Map
    );
  }
}
