import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String conversationId; // ID de la conversation associée
  final String annonceId; // ID de l'annonce associée
  final String typeAnnonce; // Type de l'annonce (échange ou don)
  final String senderId; // ID de l'expéditeur (apprenant ou formateur)
  final String receiverId; // ID du destinataire
  final String content; // Contenu du message
  final DateTime timestamp; // Horodatage du message

  Message({
    required this.id,
    required this.conversationId,
    required this.annonceId,
    required this.typeAnnonce, // Ajouter typeAnnonce (échange ou don)
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  // Convertir un message en map pour Firestore
  Map<String, dynamic> toMap() {
    return {
      'conversationId': conversationId,
      'annonceId': annonceId,
      'typeAnnonce': typeAnnonce, // Ajouter typeAnnonce
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
    };
  }

  // Créer un message à partir d'une map Firestore
  static Message fromMap(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      conversationId: map['conversationId'],
      annonceId: map['annonceId'],
      typeAnnonce: map['typeAnnonce'], // Récupérer le type d'annonce
      senderId: map['senderId'],
      receiverId: map['receiverId'],
      content: map['content'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
