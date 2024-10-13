import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:swapngive/models/Don.dart';
import 'package:swapngive/models/Echange.dart';
import 'package:swapngive/screens/Historique/historique_detail_don_screen.dart';
import 'package:swapngive/screens/Historique/historique_detail_echange_screen.dart';
import 'package:swapngive/services/don_service.dart';
import 'package:swapngive/services/echange_service.dart';
import 'package:intl/intl.dart'; // Import pour formater la date

class HistoriqueScreen extends StatefulWidget {
  @override
  _HistoriqueScreenState createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends State<HistoriqueScreen> {
  final EchangeService _echangeService = EchangeService();
  final DonService _donService = DonService();

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
    return FutureBuilder<List<Echange>>(
      future: _echangeService.recupererEchangesParStatut('accepté'),
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
    return FutureBuilder<List<Don>>(
      future: _donService.recupererDonsParStatut('accepté'),
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

  // Carte d'affichage pour un échange avec image, nom de l'objet, et date formatée
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
          ],
        ),
      ),
    );
  }

  // Carte d'affichage pour un don avec image, nom de l'objet, et date formatée
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
          ],
        ),
      ),
    );
  }

  // Méthode pour formater la date dans un format lisible
  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
