import 'package:flutter/material.dart';
import 'package:swapngive/services/utilisateur_service.dart';
import 'package:swapngive/services/categorie_service.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final UtilisateurService _utilisateurService = UtilisateurService();
  final CategorieService _categorieService = CategorieService();
  
  int _nouveauxUtilisateurs = 0;
  List<int> utilisateursActifs = [];
  List<Map<String, dynamic>> categoriesPopulaires = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNouveauxUtilisateurs();
    _loadActiveUsersData();
    _loadPopularCategories(); 
  }

  Future<void> _fetchNouveauxUtilisateurs() async {
    try {
      int nombre = await _utilisateurService.getNombreNouveauxUtilisateurs();
      setState(() {
        _nouveauxUtilisateurs = nombre;
      });
    } catch (e) {
      print('Erreur lors de la récupération des nouveaux utilisateurs: $e');
    }
  }

  Future<void> _loadActiveUsersData() async {
    try {
      List<int> tempList = [];
      for (int i = 0; i < 12; i++) {
        DateTime dateDebut = DateTime.now().subtract(Duration(days: i * 30));
        int nombreActifs = await _utilisateurService.getNombreUtilisateursActifsSurMois(dateDebut);
        tempList.add(nombreActifs);
      }
      setState(() {
        utilisateursActifs = tempList.reversed.toList();
      });
    } catch (e) {
      print('Erreur lors de la récupération des utilisateurs actifs: $e');
    }
  }

  Future<void> _loadPopularCategories() async {
    try {
      List<Map<String, dynamic>> categories = await _categorieService.getCategoriesPopulaires();
      setState(() {
        categoriesPopulaires = categories;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des catégories populaires: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 223, 225, 232), // Application de la couleur de fond
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSectionCard(
                      title: 'Nouveaux Utilisateurs',
                      child: _buildUserCounter(),
                    ),
                    SizedBox(height: 40),
                    _buildSectionCard(
                      title: 'Utilisateurs actifs sur un an',
                      child: _buildLineChart(),
                    ),
                    SizedBox(height: 40),
                    _buildSectionCard(
                      title: 'Catégories populaires',
                      child: _buildBarChart(),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildUserCounter() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$_nouveauxUtilisateurs',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      height: 300,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: utilisateursActifs
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value.toDouble()))
                  .toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [Colors.deepPurpleAccent, Colors.deepPurple],
              ),
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const mois = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(mois[value.toInt() % 12], style: TextStyle(fontSize: 10, color: Colors.grey)),
                  );
                },
                interval: 1,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 10000,
                getTitlesWidget: (value, meta) {
                  return Text('${value ~/ 1000}K', style: TextStyle(fontSize: 10, color: Colors.grey));
                },
                reservedSize: 40,
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 10000,
            verticalInterval: 1,
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey),
          ),
          minY: 0,
          maxY: 30000,
          minX: 0,
          maxX: 11,
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      height: 300,
      child: BarChart(
        BarChartData(
          barGroups: categoriesPopulaires
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final categorie = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: categorie['nombreAnnonces'].toDouble(),
                      gradient: LinearGradient(
                        colors: [Colors.blueAccent, Colors.lightBlue],
                      ),
                      width: 20,
                    ),
                  ],
                );
              })
              .toList(),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  var index = value.toInt();
                  if (index < categoriesPopulaires.length) {
                    var categorie = categoriesPopulaires[index]['categorie'];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(categorie.nom, style: TextStyle(fontSize: 10, color: Colors.grey)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString(), style: TextStyle(fontSize: 10, color: Colors.grey));
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
