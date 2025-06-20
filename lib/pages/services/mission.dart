import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:callitris/pages/auth_provider.dart';

class MissionPage extends StatefulWidget {
  @override
  _MissionPageState createState() => _MissionPageState();
}

class Mission {
  final String id;
  final String debut;
  final String fin;
  final String objet;
  final String detail;

  Mission({
    required this.id,
    required this.debut,
    required this.fin,
    required this.objet,
    required this.detail,
  });
}

class _MissionPageState extends State<MissionPage> {
  String searchText = '';
  List<Mission> missions = [];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    fetchMissions();
  }

  Future<void> fetchMissions() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      String idPersonnel = user!['id_personnel'].toString();

      final response = await http.get(
        Uri.parse(provide
            .getEndpoint('products/getMission.php?personnelId=$idPersonnel')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      //final List<dynamic> responseData = jsonDecode(response.body);
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        // ignore: unused_local_variable
        final Map<String, dynamic> missionData = responseData[0];
        // tableau des missions List converti en Map
        List<Mission> fetchedMissions = responseData.map((missionData) {
          String id = missionData['id_mission'].toString();
          String debut = missionData['date_debut_mis'].toString();
          String fin = missionData['date_fin_mis'].toString();
          String objet = missionData['objet_mis'].toString();
          String detail = missionData['detail_mis'].toString();

          return Mission(
            id: id,
            debut: debut,
            fin: fin,
            objet: objet,
            detail: detail,
          );
        }).toList();

        setState(() {
          missions = fetchedMissions;
          _isLoading = false;
        });
      } else {
        print('Erreur : ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Erreur lors de la récupération des missions : $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Missions'),
        backgroundColor: Color.fromARGB(255, 249, 221, 175),
        actions: buildAppBarActions(context),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher une Mission',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : missions.isEmpty
                    ? Center(
                        child: Text(
                          'Aucune mission trouvée',
                          style: TextStyle(fontSize: 18.0, color: Colors.red),
                        ),
                      )
                    : ListView.builder(
                        itemCount: missions.length,
                        itemBuilder: (context, index) {
                          final client = missions[index];
                          // Filtrez la liste des clients en fonction du texte de recherche
                          if (searchText.isNotEmpty &&
                              (!client.objet
                                      .toLowerCase()
                                      .contains(searchText.toLowerCase()) &&
                                  !client.detail
                                      .toLowerCase()
                                      .contains(searchText.toLowerCase()))) {
                            return Container(); // Retourne un conteneur vide si le client ne correspond pas à la recherche
                          }
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Card(
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: SvgPicture.asset(
                                    'assets/icons/mission.svg',
                                    width: 40,
                                    height: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  '${client.objet}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Detail: ${client.detail}'),
                                    Text(
                                        'Du ${client.debut}  au ${client.fin}'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
