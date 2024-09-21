import 'package:swapngive/models/Categorie.dart';
import 'package:swapngive/models/etat.dart';
import 'package:swapngive/models/utilisateur.dart';

class Objet {
  String id;           // Identifiant de l'objet
  String nom;          // Nom de l'objet
  String description;  // Description de l'objet
  Etat etat;           // L'état de l'objet
  Categorie categorie; // La catégorie de l'objet
  DateTime dateAjout;  // La date d'ajout de l'objet
  Utilisateur utilisateur; // L'utilisateur ayant ajouté l'objet
  String imageUrl;     // L'URL ou le chemin de l'image de l'objet

  // Constructeur
  Objet({
    required this.id,
    required this.nom,
    required this.description,
    required this.etat,
    required this.categorie,
    required this.dateAjout,
    required this.utilisateur,
    required this.imageUrl,
  });

 Map<String, dynamic> toMap() {
  return {
    'id': id,
    'nom': nom,
    'description': description,
    'etat': {'id': etat.id, 'nom': etat.nom},
    'categorie': {'id': categorie.id, 'nom': categorie.nom},
    'dateAjout': dateAjout.toIso8601String(),
    'utilisateur': {
      'id': utilisateur.id,
      'nom': utilisateur.nom,
      'email': utilisateur.email,
      'adresse': utilisateur.adresse,
      'telephone': utilisateur.telephone,
      'dateInscription': utilisateur.dateInscription.toIso8601String(),
      'role': utilisateur.role.toString().split('.').last, // Stocker le rôle sous forme de chaîne
    },
    'imageUrl': imageUrl,
  };
}


  // Convertir une Map en Objet
  factory Objet.fromMap(Map<String, dynamic> map) {
    return Objet(
      id: map['id'] as String? ?? '', // Valeur par défaut pour id
      nom: map['nom'] as String? ?? 'Nom indisponible', // Valeur par défaut pour nom
      description: map['description'] as String? ?? 'Description indisponible', // Valeur par défaut pour description
      etat: map['etat'] != null
          ? Etat(
              id: map['etat']['id'] as String? ?? '', // Valeur par défaut pour etat.id
              nom: map['etat']['nom'] as String? ?? 'État inconnu', // Valeur par défaut pour etat.nom
            )
          : Etat(id: '', nom: 'État inconnu'), // Valeur par défaut si etat est null
      categorie: map['categorie'] != null
          ? Categorie(
              id: map['categorie']['id'] as String? ?? '', // Valeur par défaut pour categorie.id
              nom: map['categorie']['nom'] as String? ?? 'Catégorie inconnue', // Valeur par défaut pour categorie.nom
            )
          : Categorie(id: '', nom: 'Catégorie inconnue'), // Valeur par défaut si categorie est null
      dateAjout: DateTime.tryParse(map['dateAjout'] as String) ?? DateTime.now(), // Conversion de dateAjout
      utilisateur: map['utilisateur'] != null
          ? Utilisateur(
              id: map['utilisateur']['id'] as String? ?? '', // Valeur par défaut pour utilisateur.id
              nom: map['utilisateur']['nom'] as String? ?? 'Utilisateur inconnu', // Valeur par défaut pour utilisateur.nom
              email: map['utilisateur']['email'] as String? ?? '', // Valeur par défaut pour email
              motDePasse: map['utilisateur']['motDePasse'] as String? ?? '', // Valeur par défaut pour motDePasse
              adresse: map['utilisateur']['adresse'] as String? ?? '', // Valeur par défaut pour adresse
              telephone: map['utilisateur']['telephone'] as String? ?? '', // Valeur par défaut pour téléphone
              dateInscription: DateTime.tryParse(map['utilisateur']['dateInscription'] as String) ?? DateTime.now(), // Conversion de dateInscription
              role: Role.values.firstWhere(
                (e) => e.toString() == 'Role.' + (map['utilisateur']['role'] as String? ?? ''),
                orElse: () => Role.user, // Valeur par défaut pour le rôle
              ),
            )
          : Utilisateur(
            id: '', 
            nom: 'Utilisateur inconnu', 
            email: '', 
            motDePasse: '', 
            adresse: '', 
            telephone: '', 
            dateInscription: DateTime.now(), 
            role: Role.user // Valeur par défaut si utilisateur est null
          ),
    imageUrl: map['imageUrl'] as String? ?? '', // Valeur par défaut pour imageUrl
  );
  }
}
