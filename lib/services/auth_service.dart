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
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      // Enregistrer des données supplémentaires dans Firestore
      await _firestore.collection('utilisateurs').doc(user?.uid).set({
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
      print('Tentative de connexion avec : email=$email, password=********');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Connexion réussie pour l\'email : $email');
      return userCredential.user;
    } catch (e) {
      print('Erreur lors de la connexion : $e');
      return null;
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
    print('Déconnexion réussie.');
  }

  // Get current user
  User? getCurrentUser() {
    User? user = _auth.currentUser;
    print('Utilisateur actuel : ${user?.email}');
    return user;
  }
  
Future<Utilisateur?> getUserDetails(String uid) async {
  try {
    print('Récupération des détails de l\'utilisateur pour l\'ID : $uid');
    DocumentSnapshot doc = await _firestore.collection('utilisateurs').doc(uid).get();
    
    if (doc.exists) {
      print('Utilisateur trouvé pour l\'ID : $uid');
      
      // Récupération de toutes les données de l'utilisateur
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
      
      // Assurez-vous que les champs existent et sont de type correct
      Role role = _stringToRole(userData['role'] ?? 'client'); // Conversion du rôle
      
      // Créer un objet Utilisateur à partir des données récupérées
      Utilisateur utilisateur = Utilisateur(
        id: uid,
        nom: userData['nom'] ?? '',
        email: userData['email'] ?? '',
        motDePasse: userData['motDePasse'] ?? '', // S'assurer qu'il est optionnel
        adresse: userData['adresse'] ?? '',
        telephone: userData['telephone'] ?? '',
        dateInscription: DateTime.parse(userData['dateInscription'] ?? DateTime.now().toIso8601String()),
        role: role, // Utiliser le rôle converti
      );

      return utilisateur;
    } else {
      print('Aucun utilisateur trouvé pour cet ID.');
      return null;
    }
  } catch (e) {
    print('Erreur lors de la récupération des détails de l\'utilisateur : $e');
    return null;
  }
}
// Récupérer les détails de l'utilisateur actuel
Future<Utilisateur?> getCurrentUserDetails() async {
  User? user = getCurrentUser(); // Récupérer l'utilisateur actuel
  if (user != null) {
    Utilisateur? utilisateur = await getUserDetails(user.uid); // Récupérer tous les détails de l'utilisateur
    if (utilisateur != null) {
      print('Détails de l\'utilisateur récupérés :');
      print('Nom: ${utilisateur.nom}');
      print('Email: ${utilisateur.email}');
      print('Téléphone: ${utilisateur.telephone}');
      print('Adresse: ${utilisateur.adresse}');
      print('Rôle: ${utilisateur.role}');
      print('Date d\'inscription: ${utilisateur.dateInscription}');
      print('motdepaase:${utilisateur.motDePasse}');
    } else {
      print('Aucun détail trouvé pour l\'utilisateur.');
    }
    return utilisateur;
  }
  print('Aucun utilisateur connecté.');
  return null;
}


   // Fonction pour convertir une chaîne de caractères en Role
  Role _stringToRole(String roleString) {
    switch (roleString) {
      case 'admin':
        return Role.admin;
      case 'client':
        return Role.client;
      default:
        return Role.client; // Rôle par défaut si le rôle est inconnu
    }
  }
    

}
