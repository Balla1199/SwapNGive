import 'package:flutter/material.dart';
import 'package:swapngive/models/Don.dart';
import 'package:swapngive/models/Echange.dart';
import 'package:swapngive/models/objet.dart';
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
  automaticallyImplyLeading: false,
  title: Stack(
    children: [
      Align(
        alignment: Alignment.centerLeft, // Aligne le logo à gauche
        child: Image.asset(
          'assets/images/logosansnom.jpg', // Chemin vers le logo
          height: 30, // Hauteur de l'image du logo
        ),
      ),
      Align(
        alignment: Alignment.center, // Centre le titre
        child: Text(
          "Réception",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold, // Taille du texte du titre
            ),
          
        ),
      ),
    ],
  ),
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
      // Les boutons de filtre en premier
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
                backgroundColor: selectedFilter == 'envoyé' ? Color.fromARGB(211, 217, 169, 169) : Colors.white, // Couleur active pour le filtre sélectionné
                textStyle: TextStyle(
                  color: Colors.white, // Texte blanc
                ),
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
                backgroundColor: selectedFilter == 'reçu' ? Color.fromARGB(211, 217, 169, 169) : Colors.white, // Couleur active pour le filtre sélectionné
                textStyle: TextStyle(
                  color: Colors.white, // Texte blanc
                ),
              ),
              child: Text("Reçu"),
            ),
          ],
        ),
      ),
      
      // La liste des cartes en dessous
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
            
            final objet2 = echange.objet2;
            final nomUtilisateur = objet2.utilisateur.nom;
            final message = echange.message ?? 'Pas de message';
            final Objet1 = echange.annonce.objet;
            final imageUrl = Objet1.imageUrl;

   return Padding(
  padding: const EdgeInsets.symmetric(vertical: 8.0), // Espacement vertical.
  child: Card(
    margin: EdgeInsets.all(10), // Marges autour de la carte.
    color: Color(0xFFD9A9A9).withOpacity(0.6), // Couleur rose pâle avec 60% d'opacité.
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Coins arrondis de 10 pixels.
    ),
    elevation: 0, // Suppression de l'ombre.
    child: Container(
      height: 130, // Hauteur ajustée de la carte.
      padding: EdgeInsets.all(10), // Espacement intérieur.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Alignement vertical centré.
        children: [
          // Image avec bordures arrondies.
          Padding(
            padding: const EdgeInsets.only(left: 20.0), // Espace à gauche de l'image.
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0), // Coins arrondis de l'image.
              child: Image.network(
                imageUrl.isNotEmpty ? imageUrl : 'assets/images/placeholder.png', // URL de l'image ou image par défaut.
                width: 70,
                height: 70,
                fit: BoxFit.cover, // Ajustement de l'image.
              ),
            ),
          ),
          SizedBox(width: 10), // Espace entre l'image et le texte.
          
          // Contenu textuel aligné avec l'image.
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Aligner verticalement le texte au centre.
              crossAxisAlignment: CrossAxisAlignment.start, // Aligner le texte à gauche.
              children: [
                Flexible( // Eviter les débordements
                  child: Text(
                    nomUtilisateur,
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold, // Texte en blanc et en gras.
                    ),
                    overflow: TextOverflow.ellipsis, // Truncate text if too long.
                  ),
                ),
                SizedBox(height: 5), // Espace entre le nom et le message.
                Flexible( // Eviter les débordements
                  child: Text(
                    'Message: $message',
                    style: TextStyle(color: Colors.white), // Texte en blanc.
                    overflow: TextOverflow.ellipsis, // Truncate text if too long.
                  ),
                ),
                SizedBox(height: 5), // Espace entre le message et le statut.
                Text(
                  'Statut: ${echange.statut ?? 'Statut non spécifié'}',
                  style: TextStyle(color: Colors.white), // Texte en blanc.
                ),
              ],
            ),
          ),
          
          // Colonne pour les icônes à droite.
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Espacement vertical des icônes.
            children: [
              // Icône d'yeux.
              IconButton(
                icon: Icon(Icons.remove_red_eye, color: Colors.white), // Icône avec couleur blanche.
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailEchangeScreen(echange: echange), // Redirection vers l'écran de détails.
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);

          },
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
                backgroundColor: selectedFilter == 'reçu' ? Color(0xFFD9A9A9) : Colors.white, // Couleur personnalisée pour "Reçu"
                textStyle: TextStyle(
                  color: Colors.white, // Texte en blanc
                ),
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
                backgroundColor: selectedFilter == 'envoyé' ? Color(0xFFD9A9A9) : Colors.grey, // Couleur personnalisée pour "Envoyé"
                textStyle: TextStyle(
                  color: Colors.white, // Texte en blanc
                ),
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

          return Padding(
  padding: const EdgeInsets.symmetric(vertical: 8.0), // Espacement vertical de 8.0 entre chaque carte.
  child: Card(
    margin: EdgeInsets.all(10), // Marges autour de la carte.
    color: Color(0xFFD9A9A9).withOpacity(0.6), // Couleur rose pâle avec 60% d'opacité.
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Coins arrondis de 10 pixels.
    ),
    elevation: 0, // Suppression de l'ombre.
    child: Container(
      padding: EdgeInsets.all(10), // Espacement intérieur de 10.
      child: ListTile(
        // Image ou icône par défaut si aucune image disponible.
        leading: (objet.imageUrl.isNotEmpty)
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8.0), // Coins arrondis pour l'image.
                child: Image.network(
                  objet.imageUrl,
                  width: 60,
                  height: 80,
                  fit: BoxFit.cover, // Ajustement de l'image.
                ),
              )
            : Icon(Icons.image_not_supported, size: 50, color: Colors.grey), // Icône par défaut en gris.
        title: Text(
          objet.nom,
          style: TextStyle(
            fontWeight: FontWeight.bold, // Texte en gras.
            color: Colors.white, // Texte en blanc.
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receveur : ${receveur.nom}',
              style: TextStyle(
                color: Colors.white, // Texte en blanc.
              ),
            ),
            Text(
              'Message : ${don.message ?? 'Pas de message'}',
              style: TextStyle(
                color: Colors.white, // Texte en blanc.
              ),
            ),
          ],
        ),
        // Icône "œil" pour voir les détails.
        trailing: IconButton(
          icon: Icon(Icons.remove_red_eye, color: Colors.white), // Icône "œil" en blanc.
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Utilisateur non connecté.")),
              );
            }
          },
        ),
      ),
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
