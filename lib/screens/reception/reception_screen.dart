import 'package:flutter/material.dart';
import 'package:swapngive/models/Don.dart';
import 'package:swapngive/models/Echange.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/screens/reception/detaildonscreen.dart';
import 'package:swapngive/screens/reception/detailechangescreen.dart';
import 'package:swapngive/services/auth_service.dart';
import 'package:swapngive/services/don_service.dart';
import 'package:swapngive/services/echange_service.dart';

class ReceptionScreen extends StatefulWidget {
  @override
  _ReceptionScreenState createState() => _ReceptionScreenState();
}

class _ReceptionScreenState extends State<ReceptionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Services pour récupérer les données
  final DonService _donService = DonService();
  final EchangeService _echangeService = EchangeService();

  // Listes pour stocker les échanges et dons
  List<Echange> _echanges = [];
  List<Don> _dons = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // 3 onglets

    // Charger les données à l'initialisation
    _loadEchanges();
    _loadDons();
  }

  // Charger les échanges depuis Firestore
  Future<void> _loadEchanges() async {
    List<Echange> echanges = await _echangeService.recupererTousLesEchanges();
    setState(() {
      _echanges = echanges;
    });
  }

  // Charger les dons depuis Firestore
  Future<void> _loadDons() async {
    List<Don> dons = await _donService.recupererTousLesDons();
    setState(() {
      _dons = dons;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Réception"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "Échanges"),
            Tab(text: "Dons"),
            Tab(text: "Discussions"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildEchangesTab(),  // Tab des Échanges
          buildDonsTab(),      // Tab des Dons
          buildDiscussionsTab(), // Tab des Discussions
        ],
      ),
    );
  }
// Widget pour l'onglet des Échanges
Widget buildEchangesTab() {
  return ListView.builder(
    itemCount: _echanges.length,
    itemBuilder: (context, index) {
      final echange = _echanges[index];

      // Récupération de l'objet via l'annonce de l'échange
      final objet = echange.annonce.objet;

      // Accès aux propriétés de l'objet directement
      final nomObjet = objet.nom; // Au lieu de objet?['nom']
      final description = objet.description; // Au lieu de objet?['description']

      return Card(
        child: ListTile(
          title: Text(nomObjet),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${echange.dateEchange ?? 'Date non spécifiée'}'),
              Text('Description: $description'),
              Text('Statut: ${echange.statut ?? 'Statut non spécifié'}'),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: () {
              // Naviguer vers les détails de l'échange
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DetailEchangeScreen(echange: echange)),
              );
            },
            child: Text("Voir Détails"),
          ),
        ),
      );
    },
  );
}

// Widget pour l'onglet des Dons
Widget buildDonsTab() {
  return ListView.builder(
    itemCount: _dons.length,
    itemBuilder: (context, index) {
      final don = _dons[index];

      // Accéder à l'objet du don
      final objet = don.annonce.objet; // Assurez-vous que c'est un Map<String, dynamic>

      // Détails du receveur
      final receveur = don.receveur; // Utilisez l'accesseur de l'objet Don

      return Card(
        child: ListTile(
          leading: (objet.imageUrl.isNotEmpty)
              ? Image.network(objet.imageUrl) // Assurez-vous que c'est une chaîne ou une liste
              : Icon(Icons.image_not_supported),
          title: Text(objet.nom),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Receveur : ${receveur.nom}'),
              Text('Message : ${don.message ?? 'Pas de message'}'),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: () async {
              // Récupérer l'utilisateur actuel pour obtenir currentUserId
              AuthService authService = AuthService();
              Utilisateur? currentUser = await authService.getCurrentUserDetails();

              if (currentUser != null) {
                String currentUserId = currentUser.id; // ID de l'utilisateur actuel
                // Naviguer vers une page détaillée pour le don
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailDonScreen(don: don.toMap(), currentUserId: currentUserId), // Passer 'don' et 'currentUserId'
                  ),
                );
              } else {
                // Gérer le cas où l'utilisateur n'est pas connecté
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Utilisateur non connecté.")));
              }
            },
            child: Text("Voir Détails"),
          ),
        ),
      );
    },
  );
}



  // Widget pour l'onglet des Discussions
  Widget buildDiscussionsTab() {
    return Center(
      child: Text('Aucune discussion pour le moment.'),
    );
  }
}
