import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  String id;
  String annonceId; // ID de l'annonce associée
  String typeAnnonce; // Type de l'annonce (échange ou don)
  String senderId; // ID de l'expéditeur
  String receiverId; // ID du destinataire
  String lastMessage; // Dernier message échangé
  DateTime lastMessageTimestamp; // Horodatage du dernier message
  bool hasUnreadMessages; // Indicateur de messages non lus

  Conversation({
    required this.id,
    required this.annonceId,
    required this.typeAnnonce,
    required this.senderId,
    required this.receiverId,
    required this.lastMessage,
    required this.lastMessageTimestamp,
    this.hasUnreadMessages = false, // Définissez une valeur par défaut
  });

  // Convertir une conversation en map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'annonceId': annonceId,
      'typeAnnonce': typeAnnonce,
      'senderId': senderId,
      'receiverId': receiverId,
      'lastMessage': lastMessage,
      'lastMessageTimestamp': lastMessageTimestamp,
      'hasUnreadMessages': hasUnreadMessages, // Incluez ce champ dans la conversion
    };
  }

  // Créer une conversation à partir d'une map Firestore
  static Conversation fromMap(String id, Map<String, dynamic> map) {
    return Conversation(
      id: id,
      annonceId: map['annonceId'],
      typeAnnonce: map['typeAnnonce'],
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      lastMessage: map['lastMessage'],
      lastMessageTimestamp: (map['lastMessageTimestamp'] as Timestamp).toDate(),
      hasUnreadMessages: map['hasUnreadMessages'] ?? false, // Assurez-vous de gérer la valeur par défaut
    );
  }
}
