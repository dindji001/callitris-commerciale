import 'dart:convert';
import 'package:callitris/pages/auth_provider.dart';
import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class LineDefault extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Performances'),
        backgroundColor: Color.fromARGB(255, 249, 221, 175),
        actions: buildAppBarActions(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LineDefaultChart(),
            ],
          ),
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
          children: [
            Expanded(
              child: StatCard(
                title: 'Nouv. Clients',
                amount: '${stats?.client ?? 0}',
                icon: Icons.shopping_bag,
                gradient: [Colors.blue.shade400, Colors.blue.shade700],
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: StatCard(
                title: 'Nouv. Commandes ',
                amount: '${stats?.commande ?? 0}',
                icon: Icons.account_balance_wallet,
                gradient: [Colors.green.shade400, Colors.green.shade700],
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: StatCard(
                title: 'Nouv. Tontines',
                amount: '${stats?.tontine ?? 0}',
                icon: Icons.attach_money,
                gradient: [Colors.orange.shade400, Colors.orange.shade700],
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: StatCard(
                title: 'Nouv. Missions',
                amount: '${stats?.mission ?? 0}',
                icon: Icons.credit_card,
                gradient: [Colors.purple.shade400, Colors.purple.shade700],
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
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
