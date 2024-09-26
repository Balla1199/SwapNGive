import 'package:flutter/material.dart';
import 'package:swapngive/routing.dart';
import 'package:swapngive/screens/reception/details_screen.dart';
import 'package:swapngive/services/proposition_service.dart';
import 'package:swapngive/models/proposition.dart'; // Assurez-vous d'importer le modèle Proposition

class ReceptionScreen extends StatefulWidget {
  @override
  _ReceptionScreenState createState() => _ReceptionScreenState();
}

class _ReceptionScreenState extends State<ReceptionScreen> with SingleTickerProviderStateMixin {
  late Future<List<Proposition>> _echangesFuture;
  late Future<List<Proposition>> _donsFuture;

  @override
  void initState() {
    super.initState();
    print('Chargement des propositions d\'échange et de don...');
    _echangesFuture = PropositionService().getPropositionsByType('echange');
    _donsFuture = PropositionService().getPropositionsByType('don');
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // 3 onglets : Échanges, Don, Discussions
      child: Scaffold(
        appBar: AppBar(
          title: Text('Réceptions'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Échanges'),
              Tab(text: 'Don'),
              Tab(text: 'Discussions'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildEchangesTab(),   // Contenu pour le filtre "Échanges"
            _buildDonTab(),        // Contenu pour le filtre "Don"
            _buildDiscussionsTab(), // Contenu pour le filtre "Discussions"
          ],
        ),
      ),
    );
  }

  // Fonction pour construire le contenu de l'onglet "Échanges"
  Widget _buildEchangesTab() {
    return FutureBuilder<List<Proposition>>(
      future: _echangesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('Chargement des échanges en cours...');
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Erreur lors du chargement des échanges: ${snapshot.error}');
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print('Aucun échange trouvé.');
          return Center(child: Text('Aucun échange trouvé.'));
        }

        // Afficher la liste des échanges
        List<Proposition> propositions = snapshot.data!;
        print('Nombre d\'échanges trouvés: ${propositions.length}');
        return ListView.builder(
          itemCount: propositions.length,
          itemBuilder: (context, index) {
            final proposition = propositions[index];
            final annonce = proposition.annonce; // Assurez-vous que votre modèle Proposition a le champ 'annonce'
            
            // Accès direct aux propriétés de l'objet Annonce
            final objet1 = annonce.objet; // Assurez-vous que votre modèle Annonce a une propriété 'objet'
            final objetNom = objet1.nom ?? 'Nom de l\'objet non disponible'; // Accédez au nom de l'objet
            final statut = proposition.statut ?? 'Statut non disponible';
            final dateProposition = proposition.dateProposition ?? DateTime.now(); // Remplacer par une date par défaut si nécessaire

            return ListTile(
              title: Text(objetNom),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Statut: $statut'), // Utilisez proposition.statut
                  Text(
                    'Date de la proposition: ${dateProposition.toLocal().toString().split(' ')[0]}', // Assurez-vous que dateProposition est bien de type DateTime
                  ),
                ],
              ),
             trailing: ElevatedButton(
  onPressed: () {
    if (proposition != null) {
      // Naviguer vers la page de détails de la proposition si l'objet n'est pas null
      Navigator.pushNamed(
        context,
        AppRoutes.detailPropositionScreen,
        arguments: proposition, // Passez directement l'objet proposition ici
      );
    } else {
      // Gérez le cas où la proposition est null
      print("Erreur : la proposition est null et ne peut pas être passée.");
    }
  },
  child: Text('Détails'),
),

            );
          },
        );
      },
    );
  }

  // Contenu pour l'onglet "Don"
  Widget _buildDonTab() {
    return Center(
      child: Text(
        'Aucun don disponible pour le moment.', // Message à afficher
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), // Style du texte
      ),
    );
  }

  // Contenu pour l'onglet "Discussions"
  Widget _buildDiscussionsTab() {
    return Center(
      child: Text("Liste des discussions à venir."),
    );
  }
}
