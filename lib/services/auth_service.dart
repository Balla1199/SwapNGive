import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/utilisateur.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

 // Register user
Future<User?> registerUser(String name, String email, String password, String adresse, String telephone, String role) async {
  try {
    print('Tentative d\'inscription avec : name=$name, email=$email, password=********, adresse=$adresse, telephone=$telephone, role=$role');
    
    // Créer un nouvel utilisateur avec Firebase Auth
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;

    // Enregistrer des données supplémentaires dans Firestore
    await FirebaseFirestore.instance.collection('users').doc(user?.uid).set({
      'nom': name,
      'email': email,
      'telephone': telephone,
      'adresse': adresse,
      'role': role,
      'dateInscription': DateTime.now().toIso8601String(),
    });

    print('Inscription réussie pour l\'email : $email');
    return user;
  } catch (e) {
    print("Erreur lors de l'inscription : $e");
    return null;
  }
}



  // Login user
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Erreur lors de la connexion : $e');
      return null;
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
