import 'package:flutter/material.dart';
import 'package:swapngive/screens/reception/details_screen.dart';
import 'package:swapngive/services/echange_service.dart';

class ReceptionScreen extends StatefulWidget {
  @override
  _ReceptionScreenState createState() => _ReceptionScreenState();
}

class _ReceptionScreenState extends State<ReceptionScreen> {
  late Future<List<Map<String, dynamic>>> _echangesFuture;

  @override
  void initState() {
    super.initState();
    // Utilisation de getEchangesAsMap() pour récupérer les échanges
    _echangesFuture = EchangeService().getEchangesAsMap();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _echangesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Aucun échange trouvé.'));
        }

        // Afficher la liste des échanges
        List<Map<String, dynamic>> echanges = snapshot.data!;
        return ListView.builder(
          itemCount: echanges.length,
          itemBuilder: (context, index) {
            // Affichez ici les détails de chaque échange
            final echange = echanges[index];

            // Récupérer le nom de l'objet depuis l'annonce
            final annonce = echange['annonce']; // Assurez-vous que c'est la clé correcte pour l'annonce
            final objet1 = annonce['objet']; // Accéder à l'objet associé
            final objetNom = objet1['nom'] ?? 'Nom de l\'objet non disponible';

            final statut = echange['statut'] ?? 'Statut non disponible';
            final dateEchange = echange['dateEchange'] ?? 'Date non disponible';

            return ListTile(
              title: Text(objetNom),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Statut: $statut'),
                  Text(
                    'Date d\'échange: ${DateTime.tryParse(dateEchange)?.toLocal().toString().split(' ')[0] ?? 'Date non valide'}',
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailsEchangeScreen(
                        echangeId: echange['id'],
                      ),
                    ),
                  );
                },
                child: Text('Voir Détails'),
              ),
            );
          },
        );
      },
    );
  }
}
