import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Echange.dart';

class EchangeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> enregistrerEchange(Echange echange) async {
    await _firestore.collection('echanges').add(echange.toJson());
  }

  // Méthode pour récupérer les échanges, etc.
}
