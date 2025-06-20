import 'package:callitris/pages/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:callitris/pages/app_bar_navigation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
}

class Dash {
  final String total_versement;
  final String total_encaissement;
  final String dernier_passage;
  final String derniere_somme;
  final String total_reliquat;
  final String total_retrait;
  final String total_boutique;
  final String total_courant;
  final String total_pret;

  Dash({
    required this.total_versement,
    required this.total_encaissement,
    required this.dernier_passage,
    required this.derniere_somme,
    required this.total_reliquat,
    required this.total_retrait,
    required this.total_boutique,
    required this.total_courant,
    required this.total_pret,
  });
}

class HomePageState extends State<HomePage> {
  Dash? dash;

  @override
  void initState() {
    super.initState();
    fetchDash();
  }

  Future<void> fetchDash() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      String idPersonnel = user!['id_personnel'].toString();

      final response = await http.get(
        Uri.parse(provide
            .getEndpoint('client/getDash.php?personnel_id=$idPersonnel')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );

      final List<dynamic> responsData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = responsData[0];
        String total_versement = responseData['total_versement'].toString();
        String dernier_passage = responseData['dernier_passage'].toString();
        String derniere_somme = responseData['derniere_somme'].toString();
        String total_reliquat = responseData['total_reliquat'].toString();
        String total_retrait = responseData['total_retrait'].toString();
        String total_boutique = responseData['total_boutique'].toString();
        String total_courant = responseData['total_courant'].toString();
        String total_pret = responseData['total_pret'].toString();
        String total_encaissement =
            responseData['total_encaissement'].toString();

        setState(() {
          dash = Dash(
            total_encaissement: total_encaissement,
            total_versement: total_versement,
            dernier_passage: dernier_passage,
            derniere_somme: derniere_somme,
            total_reliquat: total_reliquat,
            total_retrait: total_retrait,
            total_boutique: total_boutique,
            total_courant: total_courant,
            total_pret: total_pret,
          );
        });
      } else {
        print('Erreur : ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération des clients: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userDetail = Provider.of<AuthProvider>(context, listen: false).user;
    return MyAppBarNavigation(
      currentIndex: 0,
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            // Naviguer vers la page d'accueil
            break;
          case 1:
            Navigator.pushNamed(context, '/client');
            break;
          case 2:
            Navigator.pushNamed(context, '/services');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      body: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Text(
                    'Salut ${userDetail?['nom_pers']} ${userDetail?['prenom_pers']},',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 10,
                    shrinkWrap: true,
                    children: [
                      CustomCard(
                        color: Colors.blue,
                        svgPath: 'assets/icons/coin-up-arrow.svg',
                        title: 'Encaissement',
                        value: dash?.total_encaissement ?? '0 F',
                        onTap: () {
                          //Navigator.pushNamed(context, '/versement');
                        },
                      ),
                      CustomCard(
                        color: Colors.blue,
                        svgPath: 'assets/icons/cart-minus.svg',
                        title: 'Boutique',
                        value: dash?.total_boutique ?? '0 F',
                        onTap: () {
                          //
                        },
                      ),
                      CustomCard(
                        color: Colors.blue,
                        svgPath: 'assets/icons/wallet.svg',
                        title: 'Tontine',
                        value: dash?.total_courant ?? '0 F',
                        onTap: () {
                          //
                        },
                      ),
                      CustomCard(
                        color: Colors.blue,
                        svgPath: 'assets/icons/sack.svg',
                        title: 'Retrait',
                        value: dash?.total_retrait ?? '0 F',
                        onTap: () {
                          //
                        },
                      ),
                      CustomCard(
                        color: Colors.blue,
                        svgPath: 'assets/icons/salary.svg',
                        title: 'Reliquat',
                        value: dash?.total_reliquat ?? '0 F',
                        onTap: () {
                          //
                        },
                      ),
                      CustomCard(
                        color: Colors.blue,
                        svgPath: 'assets/icons/time-past.svg',
                        title: 'Dern. passage',
                        value: dash?.dernier_passage ?? 'AUCUN',
                        onTap: () {
                          //
                        },
                      ),
                      CustomCard(
                        color: Colors.blue,
                        svgPath: 'assets/icons/sack.svg',
                        title: 'Dern. Somme',
                        value: dash?.derniere_somme ?? '0 F',
                        onTap: () {
                          //
                        },
                      ),
                      CustomCard(
                        color: Colors.red,
                        svgPath: 'assets/icons/credit.svg',
                        title: 'Total Pret',
                        value: dash?.total_pret ?? '0 F',
                        onTap: () {},
                      ),
                      CustomCard(
                        color: Colors.blue,
                        svgPath: 'assets/icons/banque.svg',
                        title: 'Versement',
                        value: dash?.total_versement ?? '0 F',
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String svgPath;
  final String title;
  final String value;
  final Color color;
  final VoidCallback onTap; // Ajoutez ce paramètre

  const CustomCard({
    Key? key,
    required this.svgPath,
    required this.title,
    required this.value,
    required this.color,
    required this.onTap, // Ajoutez ce paramètre
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Utilisez ce paramètre ici
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue.withOpacity(0.5)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              width: 40,
              height: 40,
              color: color,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
