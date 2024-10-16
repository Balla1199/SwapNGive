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
          title: Text('Historique'),
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

    return FutureBuilder<List<Echange>>(
      future: _echangeService.recupererEchangesParUtilisateur(_currentUser!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aucun échange trouvé.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final echange = snapshot.data![index];
              return _buildEchangeCard(echange);
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
      future: _donService.recupererDonsParUtilisateur(_currentUser!.id),
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

  // Ajout du bouton d'évaluation dans la carte d'échange
  Widget _buildEchangeCard(Echange echange) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        leading: Image.network(echange.annonce.objet.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(echange.annonce.objet.nom),
        subtitle: Text('Statut: ${echange.statut}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Date: ${_formatDate(echange.dateEchange)}'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    // Navigation vers HistoriqueDetailEchangeScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoriqueDetailEchangeScreen(echange: echange),
                      ),
                    );
                  },
                  child: Text('Voir détails'),
                ),
                IconButton(
                  icon: Icon(Icons.star, color: Colors.yellow),
                  onPressed: () {
                    // Navigation vers l'écran d'évaluation (AvisFormScreen)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvisFormScreen(
                          utilisateurEvalueId: echange.annonce.utilisateur.id, // L'ID de l'utilisateur à évaluer
                          typeAnnonce: 'echange', // Type d'annonce
                          annonceId: echange.annonce.id, // L'ID de l'annonce associée à l'échange
                        ),
                      ),
                    );
                  },
                )
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
      child: ListTile(
        leading: Image.network(don.annonce.objet.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
        title: Text(don.annonce.objet.nom),
        subtitle: Text('Statut: ${don.statut}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Date: ${_formatDate(don.dateDon)}'),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    // Navigation vers HistoriqueDetailDonScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoriqueDetailDonScreen(don: don),
                      ),
                    );
                  },
                  child: Text('Voir détails'),
                ),
                IconButton(
                  icon: Icon(Icons.star, color: Colors.yellow),
                  onPressed: () {
                    // Navigation vers l'écran d'évaluation (AvisFormScreen)
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AvisFormScreen(
                          utilisateurEvalueId: don.annonce.utilisateur.id, // L'ID de l'utilisateur à évaluer
                          typeAnnonce: 'don', // Type d'annonce
                          annonceId: don.annonce.id, // L'ID de l'annonce associée au don
                        ),
                      ),
                    );
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
