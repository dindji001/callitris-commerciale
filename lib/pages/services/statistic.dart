import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:callitris/pages/auth_provider.dart';

import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class StatisticPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 249, 221, 175),
          title: Text('Mes Statistiques'),
          actions: buildAppBarActions(context)),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Etats généraux',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatisticTab(
                      title: 'Clients',
                      icon: 'assets/icons/review.svg',
                      onTap: () {
                        Navigator.pushNamed(context, '/client_as');
                      },
                      value: 'á 80%', // Remplacer par le nombre réel de clients
                    ),
                    SizedBox(width: 8),
                    StatisticTab(
                      title: 'Carnets',
                      icon: 'assets/icons/ballot-check.svg',
                      onTap: () {
                        Navigator.pushNamed(context, '/carnet');
                      },
                      value: '',
                    ),
                  ],
                ),
                SizedBox(height: 32),
                Text(
                  'Mes Performances',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                LineDefaultChart(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StatisticTab extends StatelessWidget {
  final String title;
  final String icon;
  final String value;
  final VoidCallback onTap;

  const StatisticTab({
    required this.title,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 165,
        height: 120,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color.fromARGB(255, 252, 166, 38), // couleur de fond orange
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              icon,
              width: 40,
              height: 40,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class OtherTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  const OtherTab({
    required this.title,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 110,
        height: 120,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color.fromARGB(255, 238, 64, 122), // Couleur de fond rose
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class LineDefaultChart extends StatefulWidget {
  @override
  _LineDefaultState createState() => _LineDefaultState();
}

class Stat {
  final String client;
  final String commande;
  final String tontine;
  final String mission;

  Stat({
    required this.client,
    required this.commande,
    required this.tontine,
    required this.mission,
  });
}

class CourbeValeur {
  final String jour;
  final int boutique;
  final int tontine;

  CourbeValeur({
    required this.jour,
    required this.boutique,
    required this.tontine,
  });
}

class _LineDefaultState extends State<LineDefaultChart> {
  List<CourbeValeur>? courbeValeurs;

  @override
  void initState() {
    super.initState();
    fetchCourbeValeur();
    fetchStats();
  }

  Stat? stats;

  Future<void> fetchStats() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      String idPersonnel = user!['id_personnel'].toString();

      final response = await http.get(
        Uri.parse(provide
            .getEndpoint('products/getStatCom.php?personnel_id=$idPersonnel')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      //print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> salaireData = jsonDecode(response.body);

        String client = salaireData['nouveaux_clients'].toString();
        String commande = salaireData['nouvelles_commandes'].toString();
        String tontine = salaireData['nouvelles_tontines'].toString();
        String mission = salaireData['nouvelles_missions'].toString();

        setState(() {
          stats = Stat(
            client: client,
            commande: commande,
            tontine: tontine,
            mission: mission,
          );
        });
      } else {
        print('Erreur : ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération des clients: $error');
    }
  }

  Future<void> fetchCourbeValeur() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      String idPersonnel = user!['id_personnel'].toString();

      final response = await http.get(
        Uri.parse(provide.getEndpoint(
            'products/getStatistic.php?personnel_id=$idPersonnel')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      //print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        List<CourbeValeur> values = [];
        jsonData.forEach((key, value) {
          values.add(CourbeValeur(
            jour: key,
            boutique: value['boutique'] as int,
            tontine: value['tontine'] as int,
          ));
        });
        setState(() {
          courbeValeurs = values;
        });
      } else {
        print('Erreur : ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération des valeurs de la courbe : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PerformanceTab(
              title: 'Mission',
              icon: 'assets/icons/mission.svg',
              color: Colors.purpleAccent,
              onTap: () {
                Navigator.pushNamed(context, '/mission');
              },
              value: '${stats?.mission ?? 0}',
            ),
            PerformanceTab(
              title: 'Nouv. Tontines',
              icon: 'assets/icons/wallet.svg',
              color: Color.fromARGB(255, 248, 226, 30),
              onTap: () {
                //
              },
              value:
                  '${stats?.tontine ?? 0}', // Valeur de la performance pour Perfo
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PerformanceTab(
              title: 'Nouv. Clients',
              icon: 'assets/icons/supplier.svg',
              color: Colors.blue,
              onTap: () {
                //
              },
              value: '${stats?.client ?? 0}',
            ),
            PerformanceTab(
              title: 'Nouv. Commandes',
              icon: 'assets/icons/cart-minus.svg',
              color: Colors.green,
              onTap: () {
                //
              },
              value:
                  '${stats?.commande ?? 0}', // Valeur de la performance pour Perfo
            ),
          ],
        ),
        SizedBox(height: 16),
        Card(
          elevation: 8,
          margin: EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade300,
                  const Color.fromARGB(255, 47, 154, 242)
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade800.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildDefaultLineChart(),
            ),
          ),
        )
      ],
    );
  }

  SfCartesianChart _buildDefaultLineChart() {
    return SfCartesianChart(
      //backgroundColor: Colors.white.withOpacity(45),
      plotAreaBorderWidth: 0,
      title: ChartTitle(text: 'Courbe des versements'),
      legend:
          Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
      primaryXAxis: const CategoryAxis(
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          interval: 1,
          majorGridLines: MajorGridLines(width: 0)),
      primaryYAxis: const NumericAxis(
          labelFormat: '{value} pt',
          axisLine: AxisLine(width: 0),
          majorTickLines: MajorTickLines(color: Colors.transparent)),
      series: _getDefaultLineSeries(),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  List<LineSeries<CourbeValeur, String>> _getDefaultLineSeries() {
    if (courbeValeurs == null) {
      return [];
    }
    return <LineSeries<CourbeValeur, String>>[
      LineSeries<CourbeValeur, String>(
        color: Colors.orange,
        dataSource: courbeValeurs!,
        xValueMapper: (CourbeValeur sales, _) => sales.jour,
        yValueMapper: (CourbeValeur sales, _) => sales.boutique,
        name: 'Boutique',
        markerSettings: const MarkerSettings(isVisible: true),
      ),
      LineSeries<CourbeValeur, String>(
        color: Colors.yellow,
        dataSource: courbeValeurs!,
        xValueMapper: (CourbeValeur sales, _) => sales.jour,
        yValueMapper: (CourbeValeur sales, _) => sales.tontine,
        name: 'Tontine',
        markerSettings: const MarkerSettings(isVisible: true),
      )
    ];
  }
}

class PerformanceTab extends StatelessWidget {
  final String title;
  final String icon;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const PerformanceTab({
    required this.title,
    required this.icon,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 165,
        height: 120,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: color,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              icon,
              width: 40,
              height: 40,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final List<Color> gradient;

  const StatCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 25,
              color: Colors.white,
            ),
            SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Text(
              amount,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 2,
                    color: Colors.black,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
