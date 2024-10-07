import 'package:flutter/material.dart';
import 'package:swapngive/models/Don.dart';
import 'package:swapngive/models/Echange.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/screens/reception/detaildonscreen.dart';
import 'package:swapngive/screens/reception/detailechangescreen.dart';
import 'package:swapngive/services/auth_service.dart';
import 'package:swapngive/services/don_service.dart';
import 'package:swapngive/services/echange_service.dart';
import 'package:swapngive/widgets/conversation_list_widget.dart';

class ReceptionScreen extends StatefulWidget {
  @override
  _ReceptionScreenState createState() => _ReceptionScreenState();
}

class _ReceptionScreenState extends State<ReceptionScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DonService _donService = DonService();
  final EchangeService _echangeService = EchangeService();
  List<Echange> _echanges = [];
  List<Don> _dons = [];
  String? currentUserId;
  String selectedFilter = 'reçu'; // Filtre par défaut pour les dons

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    AuthService authService = AuthService();
    Utilisateur? currentUser = await authService.getCurrentUserDetails();
    if (currentUser != null) {
      setState(() {
        currentUserId = currentUser.id;
      });
      await _loadEchanges();
      await _loadDons();
    } else {
      print("Aucun utilisateur trouvé.");
    }
  }

  Future<void> _loadEchanges() async {
    print("Chargement des échanges...");
    if (currentUserId != null) {
      List<Echange> echanges = await _echangeService.recupererEchangesParStatut('attente');
      setState(() {
        _echanges = echanges.where((echange) => echange.idUtilisateur1 == currentUserId || echange.idUtilisateur2 == currentUserId).toList();
      });
      print("Nombre d'échanges affichés: ${_echanges.length}");
    } else {
      print("L'utilisateur actuel n'est pas défini.");
    }
  }

  Future<void> _loadDons() async {
    if (currentUserId != null) {
      List<Don> dons = await _donService.recupererDonsParStatut('attente');
      setState(() {
        // Filtrer les dons en fonction du filtre sélectionné
        if (selectedFilter == 'reçu') {
          _dons = dons.where((don) => don.idDonneur == currentUserId).toList(); // Dons reçus
        } else {
          _dons = dons.where((don) => don.receveur.id == currentUserId).toList(); // Dons envoyés
        }
      });
      print("Nombre de dons affichés : ${_dons.length}");
    } else {
      print("L'utilisateur actuel n'est pas défini pour charger les dons.");
    }
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
            Tab(text: "Conversations"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildEchangesTab(),
          buildDonsTab(),
          buildConversationsTab(),
        ],
      ),
    );
  }

 Widget buildEchangesTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _echanges.length,
            itemBuilder: (context, index) {
              final echange = _echanges[index];

              // Appliquer le filtre
              if ((selectedFilter == 'reçu' && echange.idUtilisateur1 != currentUserId) || 
                  (selectedFilter == 'envoyé' && echange.idUtilisateur1 == currentUserId)) {
                return SizedBox.shrink(); // Ne rien afficher pour les échanges non filtrés
              }

              final objet = echange.annonce.objet;
              final nomObjet = objet.nom;
              final description = objet.description;

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
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedFilter = 'envoyé'; // Met à jour le filtre sélectionné
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedFilter == 'envoyé' ? Colors.blue : Colors.grey, // Change la couleur selon le filtre sélectionné
                ),
                child: Text("Envoyé"),
              ),
              SizedBox(width: 10), // Espacement entre les boutons
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedFilter = 'reçu'; // Met à jour le filtre sélectionné
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedFilter == 'reçu' ? Colors.blue : Colors.grey, // Change la couleur selon le filtre sélectionné
                ),
                child: Text("Reçu"),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildDonsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedFilter = 'reçu'; // Filtre pour les dons reçus
                    _loadDons(); // Recharge les dons après changement de filtre
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedFilter == 'reçu' ? Colors.blue : Colors.grey,
                ),
                child: Text("Reçu"),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedFilter = 'envoyé'; // Filtre pour les dons envoyés
                    _loadDons(); // Recharge les dons après changement de filtre
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedFilter == 'envoyé' ? Colors.blue : Colors.grey,
                ),
                child: Text("Envoyé"),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _dons.length,
            itemBuilder: (context, index) {
              final don = _dons[index];
              final objet = don.annonce.objet;

              final receveur = don.receveur;

              return Card(
                child: ListTile(
                  leading: (objet.imageUrl.isNotEmpty)
                      ? Image.network(objet.imageUrl)
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
                      AuthService authService = AuthService();
                      Utilisateur? currentUser = await authService.getCurrentUserDetails();

                      if (currentUser != null) {
                        String currentUserId = currentUser.id;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailDonScreen(don: don.toMap(), currentUserId: currentUserId),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Utilisateur non connecté.")));
                      }
                    },
                    child: Text("Voir Détails"),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildConversationsTab() {
    if (currentUserId == null) {
      return Center(child: CircularProgressIndicator());
    }

    return ConversationListWidget(userId: currentUserId!);
  }
}
