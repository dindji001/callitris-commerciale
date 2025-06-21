import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../auth_provider.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:skeletonizer/skeletonizer.dart'; // Supprimé

class BanquePage extends StatefulWidget {
  @override
  _BanquePageState createState() => _BanquePageState();
}

class Journal {
  final String id;
  final String libelle;
  final String dateOpe;
  final String heureOpe;
  final String path;
  final String montant;
  final String compte;

  Journal({
    required this.id,
    required this.libelle,
    required this.dateOpe,
    required this.heureOpe,
    required this.path,
    required this.montant,
    required this.compte,
  });
}

class _BanquePageState extends State<BanquePage> {
  String searchText = '';
  bool _isLoading = true;
  List<Journal> journals = [];

  @override
  void initState() {
    super.initState();
    fetchJournals();
  }

  Future<void> fetchJournals() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      String idPersonnel = user!['id_personnel'].toString();

      final response = await http.get(
        Uri.parse(provide
            .getEndpoint('products/getBanque.php?personnelId=$idPersonnel')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      //print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        List<Journal> fetchedJournals = responseData.map((journalData) {
          String id = journalData['id_banque'].toString();
          String libelle = journalData['libelle'].toString();
          String dateOpe = journalData['date_add_banq'].toString();
          String heureOpe = journalData['time_add_banq'].toString();
          String montant = journalData['montant_banq'].toString();
          String path = journalData['recu_banq'].toString();
          String compte = journalData['num_compte_banq'].toString();

          return Journal(
            id: id,
            libelle: libelle,
            dateOpe: dateOpe,
            heureOpe: heureOpe,
            montant: montant,
            path: path,
            compte: compte,
          );
        }).toList();

        setState(() {
          journals = fetchedJournals;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        print('Erreur : ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur lors de la récupération des Journals: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Journal> displayedJournals = journals.where((journal) {
      return journal.libelle.toLowerCase().contains(searchText.toLowerCase()) ||
          journal.compte.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Espace Banque'),
        backgroundColor: Color.fromARGB(255, 249, 221, 175),
        actions: buildAppBarActions(context),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/edit_bank');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  Icons.balance,
                  color: Colors.white,
                ),
                label: Text(
                  'Faire un versement',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Rechercher une entrée',
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    'assets/icons/search.svg',
                    width: 20.0,
                    color: Colors.grey,
                  ),
                ),
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
                ? ListView.builder(
                    itemCount: 5, // Nombre arbitraire de squelettes
                    itemBuilder: (context, index) {
                      // Remplacer Skeletonizer par un widget de chargement simple
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Card(
                          color: Color.fromARGB(255, 152, 208, 253),
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Container(
                                width: 30.0,
                                height: 30.0,
                                color: Colors.grey[300],
                              ),
                            ),
                            title: Container(
                              width: double.infinity,
                              height: 20.0,
                              color: Colors.grey[300],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: 16.0,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(height: 4.0),
                                Container(
                                  width: double.infinity,
                                  height: 16.0,
                                  color: Colors.grey[300],
                                ),
                                SizedBox(height: 4.0),
                                Container(
                                  width: double.infinity,
                                  height: 16.0,
                                  color: Colors.grey[300],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : displayedJournals.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun mission trouvé',
                          style: TextStyle(fontSize: 18.0, color: Colors.red),
                        ),
                      )
                    : ListView.builder(
                        itemCount: displayedJournals.length,
                        itemBuilder: (context, index) {
                          final journal = displayedJournals[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Card(
                              color: Color.fromARGB(255, 152, 208, 253),
                              elevation: 4.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: SvgPicture.asset(
                                    'assets/icons/sack.svg',
                                    width: 30.0,
                                    color: Colors.orange,
                                  ),
                                ),
                                title: Text(
                                  journal.libelle,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Date: ${journal.dateOpe}'),
                                    Text('Heure: ${journal.heureOpe}'),
                                    Text('Montant: ${journal.montant}'),
                                    //Text('Compte: ${journal.compte}'),
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
