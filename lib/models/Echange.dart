import 'package:swapngive/models/Annonce.dart';
import 'package:swapngive/models/objet.dart';

class Echange {
  String idUtilisateur1;
  String idObjet1;
  String idUtilisateur2;
  Objet objet2; // Changement : objet2 est une instance de Objet
  DateTime dateEchange;
  Annonce annonce; // Assurez-vous que cette classe a aussi une méthode toJson
  String? message; // Message optionnel
  String statut; // Statut de l'échange ("attente", "accepté", "refusé")

  Echange({
    required this.idUtilisateur1,
    required this.idObjet1,
    required this.idUtilisateur2,
    required this.objet2,
    required this.dateEchange,
    required this.annonce,
    this.message,
    this.statut = 'attente', // Par défaut à "attente"
  });

  // Convertir l'objet Echange en Map
  Map<String, dynamic> toMap() {
    return {
      'idUtilisateur1': idUtilisateur1,
      'idObjet1': idObjet1,
      'idUtilisateur2': idUtilisateur2,
      'objet2': objet2.toMap(), // Utilisez la sérialisation de l'objet ici
      'dateEchange': dateEchange.toIso8601String(),
      'annonce': annonce.toJson(), // Sérialiser l'objet Annonce en JSON
      'message': message, // Champ message
      'statut': statut, // Champ statut en tant que chaîne de caractères
    };
  }

  // Créer un objet Echange à partir d'une Map
  factory Echange.fromMap(Map<String, dynamic> map) {
    return Echange(
      idUtilisateur1: map['idUtilisateur1'],
      idObjet1: map['idObjet1'],
      idUtilisateur2: map['idUtilisateur2'],
      objet2: Objet.fromMap(map['objet2']), // Créez l'objet à partir de la Map
      dateEchange: DateTime.parse(map['dateEchange']),
      annonce: Annonce.fromJson(map['annonce']), // Désérialiser l'annonce à partir de JSON
      message: map['message'], // Message optionnel
      statut: map['statut'] ?? 'attente', // Valeur par défaut "attente" si non définie
    );
  }
}
