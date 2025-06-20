import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:callitris/pages/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyAppBarNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onDestinationSelected;
  final Widget body;

  const MyAppBarNavigation({
    Key? key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.body,
  }) : super(key: key);

  @override
  _MyAppBarNavigationState createState() => _MyAppBarNavigationState();
}

class _MyAppBarNavigationState extends State<MyAppBarNavigation> {
  int currentPageIndex = 0;
  String salaire = '0 F';
  @override
  void initState() {
    super.initState();
    fetchSalaire();
  }

  Future<void> fetchSalaire() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      String idPersonnel = user!['id_personnel'].toString();

      final response = await http.get(
        Uri.parse(provide
            .getEndpoint('products/getSalaire.php?personnel_id=$idPersonnel')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      //print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> salaireData = jsonDecode(response.body);
        String total = salaireData['total'].toString();
        setState(() {
          salaire = total;
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
    return Scaffold(
      bottomNavigationBar: navigationBar(),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Color.fromARGB(255, 249, 221, 175),
        leading: Image.asset(
          'assets/logo_callitris.png',
          width: 40,
          height: 40,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                // Action à effectuer lors du clic sur le bouton
                // Par exemple, naviguer vers une autre page
                Navigator.pushNamed(context, '/salaire');
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0), // Bordures arrondies
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  color:
                      Color.fromARGB(255, 245, 146, 40), // Arrière-plan foncé
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                        radius: 10,
                        child: SvgPicture.asset(
                          'assets/icons/salary.svg',
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.0),
                      Text(
                        salaire,
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/chart.svg',
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/statistic');
            },
          ),
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/perf.svg',
              color: Colors.blue,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/indicateur');
            },
          ),
        ],
      ),
      body: widget.body,
    );
  }

  NavigationBar navigationBar() {
    return NavigationBar(
      onDestinationSelected: widget.onDestinationSelected,
      indicatorColor: Colors.blue,
      backgroundColor: Color.fromARGB(255, 214, 129, 2),
      selectedIndex: widget.currentIndex,
      destinations: <Widget>[
        NavigationDestination(
          //selectedIcon: SvgPicture.asset('assets/icons/home.svg'),
          icon: SvgPicture.asset(
            'assets/icons/home.svg',
            color: Colors.white,
          ),
          label: 'Accueil',
        ),
        NavigationDestination(
          icon: Badge(
              child: SvgPicture.asset(
            'assets/icons/profile.svg',
            color: Colors.white,
          )),
          label: 'Clients',
        ),
        NavigationDestination(
          icon: Badge(
              child: SvgPicture.asset(
            'assets/icons/briefcase-2.svg',
            color: Colors.white,
          )),
          label: 'Services',
        ),
        NavigationDestination(
          icon: Badge(
              child: SvgPicture.asset(
            'assets/icons/reglage.svg',
            color: Colors.white,
          )),
          label: 'Profile',
        ),
      ],
    );
  }
}
