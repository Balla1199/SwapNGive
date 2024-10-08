import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapngive/models/Avis.dart';

class AvisService {
  final CollectionReference _collection = FirebaseFirestore.instance.collection('avis');

  Future<void> ajouterAvis(Avis avis) async {
    try {
      await _collection.add(avis.toMap());
      print('Avis ajouté avec succès');
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'avis : $e');
      throw e;
    }
  }

  Future<List<Avis>> getAvisUtilisateur(String utilisateurEvalueId) async {
    try {
      print('Chargement des avis pour l\'utilisateur évalué avec ID : $utilisateurEvalueId');
      
      QuerySnapshot snapshot = await _collection
          .where('utilisateurEvalueId', isEqualTo: utilisateurEvalueId)
          .get();

      if (snapshot.docs.isEmpty) {
        print('Aucun avis trouvé pour cet utilisateur');
        return [];
      }

      List<Avis> avisList = snapshot.docs.map((doc) {
        print('Document trouvé : ${doc.data()}'); // Affiche les données du document
        return Avis.fromFirestore(doc);
      }).toList();

      print('Avis récupérés avec succès : ${avisList.length} avis trouvés');
      return avisList;
    } catch (e) {
      print('Erreur lors de la récupération des avis : $e');
      throw e;
    }
  }

  // Nouvelle méthode pour obtenir la somme totale des notes
Future<double> getSommeTotalNotes(String utilisateurEvalueId) async {
  try {
    List<Avis> avisList = await getAvisUtilisateur(utilisateurEvalueId);
    // Calcul de la somme des notes
    double sommeTotal = avisList.fold(0.0, (sum, avis) => sum + avis.note);
    print('Somme totale des notes : $sommeTotal');
    return sommeTotal; // Retourne un double
  } catch (e) {
    print('Erreur lors du calcul de la somme des notes : $e');
    throw e;
  }
}
 
 Future<double> getMoyenneNotes(String utilisateurEvalueId) async {
  try {
    List<Avis> avisList = await getAvisUtilisateur(utilisateurEvalueId);
    if (avisList.isEmpty) {
      return 0.0; // Aucun avis, donc moyenne à 0
    }
    
    double sommeTotal = avisList.fold(0.0, (sum, avis) => sum + avis.note);
    double moyenne = sommeTotal / avisList.length;
    
    print('Moyenne des notes : $moyenne');
    return moyenne;
  } catch (e) {
    print('Erreur lors du calcul de la moyenne des notes : $e');
    throw e;
  }
}


}
