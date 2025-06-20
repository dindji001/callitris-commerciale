import 'dart:convert';
import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class StateCarnet {
  final String livret;
  final int carnet;
  final int commande;
  final int restant;

  StateCarnet({
    required this.livret,
    required this.carnet,
    required this.commande,
    required this.restant,
  });

  factory StateCarnet.fromJson(Map<String, dynamic> json) {
    return StateCarnet(
      livret: json['livret'] ?? 'Inconnu',
      carnet: int.tryParse(json['carnet'].toString()) ?? 0,
      commande: int.tryParse(json['commande'].toString()) ?? 0,
      restant: int.tryParse(json['restantr'].toString()) ?? 0,
    );
  }
}

class CommandePage extends StatefulWidget {
  @override
  _CommandePageState createState() => _CommandePageState();
}

class _CommandePageState extends State<CommandePage> {
  List<StateCarnet> stateCarnets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCarnet();
    });
  }

  Future<void> _fetchCarnet() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final response = await http.get(
        Uri.parse(provide.getEndpoint(
            'products/getStatCarnet.php?personnelId=${user?['id_personnel']}')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      //print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          stateCarnets =
              responseData.map((data) => StateCarnet.fromJson(data)).toList();
          isLoading = false;
        });
      } else {
        print('Erreur : ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (error) {
      print('Erreur lors de la récupération des données carnet : $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Etat de Mes Carnets'),
        backgroundColor: Color.fromARGB(255, 249, 221, 175),
        actions: buildAppBarActions(context),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: stateCarnets.length,
                itemBuilder: (context, index) {
                  final carnet = stateCarnets[index];
                  return StatisticCard(carnet: carnet);
                },
              ),
            ),
    );
  }
}

class StatisticCard extends StatelessWidget {
  final StateCarnet carnet;

  StatisticCard({required this.carnet});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              carnet.livret,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                StatisticTab(
                  title: 'Carnet',
                  icon: 'assets/icons/ballot-check.svg',
                  value: carnet.carnet.toString(),
                  onTap: () {},
                ),
                StatisticTab(
                  title: 'Vendu',
                  icon: 'assets/icons/cart-minus.svg',
                  value: carnet.commande.toString(),
                  onTap: () {},
                ),
                StatisticTab(
                  title: 'Reste',
                  icon: 'assets/icons/box-check.svg',
                  value: carnet.restant.toString(),
                  onTap: () {},
                ),
              ],
            ),
          ],
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
        margin: EdgeInsets.symmetric(vertical: 2.0),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color.fromARGB(255, 191, 108, 254),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 40,
              height: 40,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  value,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
