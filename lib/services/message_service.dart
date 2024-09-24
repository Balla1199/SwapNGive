import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Message.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> envoyerMessage(Message message) async {
    await _firestore.collection('messages').add(message.toJson());
  }

  // Méthode pour récupérer les messages, etc.
}
