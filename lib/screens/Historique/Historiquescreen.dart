import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import pour formater la date
import 'package:swapngive/models/Don.dart';
import 'package:swapngive/models/Echange.dart';
import 'package:swapngive/screens/Historique/historique_detail_don_screen.dart';
import 'package:swapngive/screens/Historique/historique_detail_echange_screen.dart';
import 'package:swapngive/screens/avis/Avis_Form_Screen.dart';
import 'package:swapngive/services/don_service.dart';
import 'package:swapngive/services/echange_service.dart';
import 'package:swapngive/services/auth_service.dart';
import 'package:swapngive/models/utilisateur.dart'; // Import du modèle Utilisateur

class HistoriqueScreen extends StatefulWidget {
  @override
  _HistoriqueScreenState createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  final EchangeService _echangeService = EchangeService();
  final DonService _donService = DonService();
  final AuthService _authService = AuthService();
  Utilisateur? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  // Récupérer l'utilisateur actuel
  Future<void> _loadCurrentUser() async {
    Utilisateur? user = await _authService.getCurrentUserDetails();
    setState(() {
      _currentUser = user;
    });
  }

  // Méthode pour formater la date dans un format lisible
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
@override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0), // Espacement entre le logo et le titre
              child: Image.asset(
                'assets/images/logosansnom.jpg', // Remplacez par le chemin de votre logo
                width: 40, // Ajustez la largeur selon vos besoins
                height: 40, // Ajustez la hauteur selon vos besoins
              ),
            ),
            // Titre centré dans l'espace restant
            Expanded(
              child: Center(
                child: Text(
                  'Historique',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Titre en gras
                    fontSize: 20, // Ajustez la taille de la police selon vos besoins
                  ),
                ),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          tabs: [
            Tab(text: 'Échange'),
            Tab(text: 'Don'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          _buildEchangeTab(),
          _buildDonTab(),
        ],
      ),
    ),
  );
}

Widget _buildEchangeTab() {
  if (_currentUser == null) {
    return Center(child: CircularProgressIndicator());
  }

  // Récupère les échanges ayant le statut "Accepté" ou "Refusé"
  return FutureBuilder<List<Echange>>(
    future: _echangeService.recupererEchangesParUtilisateurEtStatut(_currentUser!.id, 'accepté'),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Erreur: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return Center(child: Text('Aucun échange trouvé.'));
      } else {
        // Affiche les échanges acceptés
        List<Echange> acceptedExchanges = snapshot.data!;

        // Appel supplémentaire pour les échanges refusés
        return FutureBuilder<List<Echange>>(
          future: _echangeService.recupererEchangesParUtilisateurEtStatut(_currentUser!.id, 'refusé'),
          builder: (context, rejectedSnapshot) {
            if (rejectedSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (rejectedSnapshot.hasError) {
              return Center(child: Text('Erreur: ${rejectedSnapshot.error}'));
            } else if (!rejectedSnapshot.hasData || rejectedSnapshot.data!.isEmpty) {
              return ListView.builder(
                itemCount: acceptedExchanges.length,
                itemBuilder: (context, index) {
                  final echange = acceptedExchanges[index];
                  return _buildEchangeCard(echange);
                },
              );
            } else {
              // Combine les échanges acceptés et refusés
              List<Echange> allExchanges = []
                ..addAll(acceptedExchanges)
                ..addAll(rejectedSnapshot.data!);

              return ListView.builder(
                itemCount: allExchanges.length,
                itemBuilder: (context, index) {
                  final echange = allExchanges[index];
                  return _buildEchangeCard(echange);
                },
              );
            }
          },
        );
      }
    },
  );
}


  Widget _buildDonTab() {
    if (_currentUser == null) {
      return Center(child: CircularProgressIndicator());
    }

   return FutureBuilder<List<Don>>(
  // Fusionner les dons avec le statut 'Accepté' et 'Refusé'
  future: Future.wait([
    _donService.recupererDonsParUtilisateurEtStatut(_currentUser!.id, 'accepté'),
    _donService.recupererDonsParUtilisateurEtStatut(_currentUser!.id, 'refusé'),
  ]).then((results) {
    // Log les résultats pour vérifier les dons récupérés
    print('Dons acceptés: ${results[0].length}, Dons refusés: ${results[1].length}');
    
    // Combine les deux résultats (Accepté et Refusé) en une seule liste
    return [...results[0], ...results[1]];
  }),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
      return Center(child: Text('Erreur: ${snapshot.error}'));
    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return Center(child: Text('Aucun don trouvé.'));
    } else {
      return ListView.builder(
        itemCount: snapshot.data!.length,
        itemBuilder: (context, index) {
          final don = snapshot.data![index];
          return _buildDonCard(don);
        },
      );
    }
  },
);


  }
Widget _buildEchangeCard(Echange echange) {
  return Card(
    margin: EdgeInsets.all(10),
    color: Color(0xFFD9A9A9).withOpacity(0.6), // Couleur de la carte avec opacité.
    child: Container(
      width: 300, // Largeur de la carte.
      height: 130, // Hauteur ajustée.
      padding: EdgeInsets.all(10), // Espacement intérieur.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Alignement vertical centré.
        children: [
          // Image avec bordures arrondies
          Padding(
            padding: const EdgeInsets.only(left: 20.0), // Espace à gauche de l'image.
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0), // Bordures arrondies de 10 pixels.
              child: Image.network(
                echange.annonce.objet.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10), // Espace entre l'image et le texte
          
          // Contenu textuel aligné avec l'image
          Expanded( // Utiliser Expanded pour ajuster le texte.
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Aligner verticalement le texte au centre.
              crossAxisAlignment: CrossAxisAlignment.start, // Aligner le texte à gauche.
              children: [
                Text(
                  echange.annonce.objet.nom,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Texte en blanc et en gras.
                ),
                SizedBox(height: 5), // Espace entre le nom et la date.
                Text(
                  'Date: ${_formatDate(echange.dateEchange)}',
                  style: TextStyle(color: Colors.white), // Texte en blanc.
                ),
              ],
            ),
          ),
          
          // Colonne pour les icônes à droite
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacer les icônes verticalement.
            children: [
              // Icône d'yeux.
              IconButton(
                icon: Icon(Icons.visibility, color: Colors.white), // Icône d'yeux.
                onPressed: () {
                  // Navigation vers HistoriqueDetailEchangeScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoriqueDetailEchangeScreen(echange: echange),
                    ),
                  );
                },
              ),
              // Icône d'évaluation avec du padding en bas
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0), // Padding en bas.
                child: IconButton(
                  icon: Icon(Icons.star, color: Colors.yellow),
                  onPressed: () {
                    // Navigation vers l'écran d'évaluation (AvisFormScreen)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvisFormScreen(
                          utilisateurEvalueId: echange.annonce.utilisateur.id, // L'ID de l'utilisateur à évaluer.
                          typeAnnonce: 'echange', // Type d'annonce.
                          annonceId: echange.annonce.id, // L'ID de l'annonce associée à l'échange.
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  // Ajout du bouton d'évaluation dans la carte de don
Widget _buildDonCard(Don don) {
  return Card(
    margin: EdgeInsets.all(10),
    color: Color(0xFFD9A9A9).withOpacity(0.6), // Couleur de la carte avec opacité.
    child: Container(
      width: 300, // Largeur de la carte.
      height: 130, // Hauteur ajustée.
      padding: EdgeInsets.all(10), // Espacement intérieur.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Alignement vertical centré.
        children: [
          // Image avec bordures arrondies
          Padding(
            padding: const EdgeInsets.only(left: 20.0), // Espace à gauche de l'image.
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0), // Bordures arrondies de 10 pixels.
              child: Image.network(
                don.annonce.objet.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10), // Espace entre l'image et le texte
          
          // Contenu textuel aligné avec l'image
          Expanded( // Utiliser Expanded pour ajuster le texte.
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Aligner verticalement le texte au centre.
              crossAxisAlignment: CrossAxisAlignment.start, // Aligner le texte à gauche.
              children: [
                Text(
                  don.annonce.objet.nom,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Texte en blanc et en gras.
                ),
                SizedBox(height: 5), // Espace entre le nom et la date.
                Text(
                  '${_formatDate(don.dateDon)}',
                  style: TextStyle(color: Colors.white), // Texte en blanc.
                ),
              ],
            ),
          ),
          
          // Colonne pour les icônes à droite
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacer les icônes verticalement.
            children: [
              // Icône d'yeux.
              IconButton(
                icon: Icon(Icons.visibility, color: Colors.white), // Icône d'yeux.
                onPressed: () {
                  // Navigation vers HistoriqueDetailDonScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HistoriqueDetailDonScreen(don: don),
                    ),
                  );
                },
              ),
              // Icône d'évaluation avec du padding en bas
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0), // Padding en bas.
                child: IconButton(
                  icon: Icon(Icons.star, color: Colors.yellow),
                  onPressed: () {
                    // Navigation vers l'écran d'évaluation (AvisFormScreen)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvisFormScreen(
                          utilisateurEvalueId: don.annonce.utilisateur.id, // L'ID de l'utilisateur à évaluer.
                          typeAnnonce: 'don', // Type d'annonce.
                          annonceId: don.annonce.id, // L'ID de l'annonce associée au don.
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

}
