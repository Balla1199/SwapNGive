import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapngive/models/utilisateur.dart';
import 'package:swapngive/services/utilisateur_service.dart';


class SidebarLayout extends StatefulWidget {
  final List<Widget> screens; // Liste des écrans à afficher
  final int selectedIndex; // Index de l'écran sélectionné
  final Function(int) onItemTapped; // Fonction pour gérer les éléments tapés

  SidebarLayout({
    required this.screens,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  _SidebarLayoutState createState() => _SidebarLayoutState();
}

class _SidebarLayoutState extends State<SidebarLayout> {
  final UtilisateurService _utilisateurService = UtilisateurService();
  Utilisateur? _utilisateur; // Stocke les infos de l'utilisateur connecté

  @override
  void initState() {
    super.initState();
    _loadUtilisateur(); // Charger les informations de l'utilisateur
  }

  // Fonction pour charger les informations de l'utilisateur
  Future<void> _loadUtilisateur() async {
    User? currentUser = _utilisateurService.getCurrentUser();
    if (currentUser != null) {
      Utilisateur? utilisateur = await _utilisateurService.getUtilisateurById(currentUser.uid);
      if (utilisateur != null) {
        setState(() {
          _utilisateur = utilisateur;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          // Barre latérale
          Container(
            width: 200,
            color: Colors.white,
            child: Column(
              children: <Widget>[
                // En-tête avec logo et texte
                Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Image.asset(
                        'images/logosansnom.jpg',
                        width: 60,
                        height: 60,
                      ),
                      SizedBox(width: 20),
                      Text(
                        'Falen',
                        style: TextStyle(
                          fontFamily: 'MrBedfort-Regular',
                          color: Color(0xFFD9A9A9),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Menu items
                _buildMenuItem(
                  title: 'Dashboard',
                  icon: Icons.dashboard,
                  index: 0,
                  selectedIndex: widget.selectedIndex,
                  onItemTapped: widget.onItemTapped,
                ),
                _buildMenuItem(
                  title: 'Users',
                  icon: Icons.group,
                  index: 1,
                  selectedIndex: widget.selectedIndex,
                  onItemTapped: widget.onItemTapped,
                ),
                _buildMenuItem(
                  title: 'Categories',
                  icon: Icons.category,
                  index: 2,
                  selectedIndex: widget.selectedIndex,
                  onItemTapped: widget.onItemTapped,
                ),
                _buildMenuItem(
                  title: 'Etats',
                  icon: Icons.check_circle,
                  index: 3,
                  selectedIndex: widget.selectedIndex,
                  onItemTapped: widget.onItemTapped,
                ),
                
                // Espace entre les éléments et le profil
                Spacer(),
                
                // Affichage du profil utilisateur
                if (_utilisateur != null) _buildUserProfile(_utilisateur!),
              ],
            ),
          ),

          // Contenu principal
          Expanded(
            child: widget.screens[widget.selectedIndex],
          ),
        ],
      ),
    );
  }

  // Méthode pour construire un élément du menu
  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required int index,
    required int selectedIndex,
    required Function(int) onItemTapped,
  }) {
    return GestureDetector(
      onTap: () {
        widget.onItemTapped(index);
      },
      child: Container(
        decoration: BoxDecoration(
          color: selectedIndex == index ? Color(0xFFD9A9A9) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          selected: selectedIndex == index,
          title: Text(
            title,
            style: TextStyle(
              color: selectedIndex == index ? Colors.white : Color(0xFF9197B3),
            ),
          ),
          leading: Icon(
            icon,
            color: selectedIndex == index ? Colors.white : Color(0xFF9197B3),
          ),
        ),
      ),
    );
  }

  // Méthode pour construire le widget du profil utilisateur en bas de la barre latérale
  Widget _buildUserProfile(Utilisateur utilisateur) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFF3F4F6), // Couleur de fond de la zone de profil
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Affichage de la photo de profil
          CircleAvatar(
            radius: 25,
            backgroundImage: utilisateur.photoProfil != null
                ? NetworkImage(utilisateur.photoProfil!) // Affichage depuis Firebase
                : AssetImage('images/user.png') as ImageProvider, // Placeholder si aucune photo n'est disponible
          ),
          SizedBox(width: 10),

          // Informations sur l'utilisateur
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                utilisateur.nom ?? 'Utilisateur', // Nom de l'utilisateur
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
  utilisateur.getRoleString() ?? 'Role inconnu', // Rôle de l'utilisateur
  style: TextStyle(
    color: Colors.grey,
  ),
),

            ],
          ),
        ],
      ),
    );
  }
}
