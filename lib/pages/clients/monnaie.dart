import 'package:callitris/pages/auth_provider.dart';
import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:provider/provider.dart';

class VersementPage extends StatefulWidget {
  final String id;
  final String cle;
  final String client;
  VersementPage({required this.id, required this.cle, required this.client});

  @override
  _VersementPageState createState() => _VersementPageState();
}

class Versement {
  final String journalier;
  final String verser;
  final String date;
  final String heure;

  Versement({
    required this.journalier,
    required this.verser,
    required this.date,
    required this.heure,
  });
}

class _VersementPageState extends State<VersementPage> {
  List<Versement> versements = [];
  late TextEditingController _montantController;
  String? idCom;
  String? cle;
  String? livret;
  String? pack;
  String? nomProduit;
  String? nbre_jours;
  String? journalier;
  String? jour_paye;
  String? jour_reste;

  final _controller1 = TextEditingController();
  final _controller2 = TextEditingController();
  final NumberFormat _numberFormat = NumberFormat("#,###", "fr_FR");
  double? monnaie;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchCommandeInfo();
    fetchVersements();
    fetchMonnaie();
    _montantController = TextEditingController();
  }

  Future<void> fetchMonnaie() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final provide = Provider.of<AuthProvider>(context, listen: false);

      final response = await http.get(
        Uri.parse(provide
            .getEndpoint('client/getMonnaie.php?clientId=${widget.client}')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        double monnaieValue = double.parse(responseData['montant']);
        ;

        setState(() {
          monnaie = monnaieValue;
        });
      } else {
        print(
            'Erreur lors de la récupération de la monnaie : ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération de la monnaie : $error');
    }
  }

  void _formatMontant() {
    String text = _montantController.text.replaceAll(' ', '');
    if (text.isNotEmpty) {
      int value = int.parse(text);
      _montantController.value = TextEditingValue(
        text: _numberFormat.format(value),
        selection:
            TextSelection.collapsed(offset: _numberFormat.format(value).length),
      );
    }
  }

  Future<void> fetchCommandeInfo() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      final response = await http.get(
        Uri.parse(provide.getEndpoint(
            'products/getCommandeById.php?commandeId=${widget.id}')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      //print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        if (responseData.isNotEmpty) {
          final commandeData = responseData[0];

          setState(() {
            idCom = commandeData['id'].toString();
            cle = commandeData['cle'].toString();
            livret = commandeData['livret'].toString();
            pack = commandeData['pack'].toString();
            nomProduit = commandeData['code_cmd'].toString();
            jour_paye = commandeData['paye'].toString();
            journalier = commandeData['journalier'].toString();
            nbre_jours = commandeData['jour'].toString();
            jour_reste = commandeData['reste'].toString();
          });
        }
      } else {
        print('Erreur : ${response.statusCode}');
      }
    } catch (error) {
      print(
          'Erreur lors de la récupération des informations de la commande : $error');
    }
  }

  Future<void> fetchVersements() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      //String idPersonnel = user!['id_personnel'].toString();

      final response = await http.get(
        Uri.parse(provide.getEndpoint(
            'products/getVersementsCompte.php?id=${widget.id}&compte_id=1')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        List<Versement> fetchedVersements = responseData.map((versementData) {
          String journalier = versementData['montant_vers'] ?? '0';
          String verser = versementData['montant_vers'] ?? '0';
          String date = versementData['date_vers'] ?? '';
          String heure = versementData['heure_vers'] ?? '';

          return Versement(
              journalier: journalier, verser: verser, date: date, heure: heure);
        }).toList();

        setState(() {
          versements = fetchedVersements;
        });
      } else {
        print('Erreur : ${response.statusCode}');
      }
    } catch (error) {
      print(
          'Erreur lors de la récupération de l\'historique des versements: $error');
    }
  }

  @override
  void dispose() {
    _montantController.dispose();
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  String _formatNumber(String s) {
    return _numberFormat.format(int.parse(s.replaceAll(' ', '')));
  }

  Future<void> _envoyerMontant(double montant) async {
    setState(() {
      isSubmitting = true; // Définir isSubmitting sur true avant la soumission
    });

    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      String personnelId = user!['id_personnel'].toString();
      if (montant < (double.parse(journalier.toString()))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Le montant doit etre superieur ou egal au montant journalier $journalier F',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final response = await http.post(
        Uri.parse(provide.getEndpoint('products/addVersementCom.php')),
        headers: {
          'Authorization': token!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'commande_id': widget.id,
          'cle': widget.cle,
          'clientId': widget.client,
          'montant': montant,
          'personnelId': personnelId,
          'monnaie': monnaie,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        // Traitement en cas de succès
        print('Données envoyées avec succès à l\'API');
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print(responseData['code']);

        if (responseData['code'] == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseData['message'],
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            fetchVersements();
            fetchCommandeInfo();
            fetchMonnaie();
          });
        }
      } else {
        // Gérer les erreurs
        print('Erreur lors de l\'envoi du montant: ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de l\'envoi du montant: $error');
    } finally {
      setState(() {
        isSubmitting = false; // Réinitialiser isSubmitting après la soumission
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Versement Commande'),
        backgroundColor: Color.fromARGB(255, 249, 221, 175),
        actions: buildAppBarActions(context),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bouton de versement avec une icône
            ElevatedButton.icon(
              onPressed: () {
                //_showMontantModal(context);
                _showNouvelleTontineSheet(context);
              },
              icon: Icon(Icons.payment, color: Colors.white),
              label: Text(
                'Effectuer un versement',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    EdgeInsets.symmetric(vertical: 10.0), // Ajuster le padding
                backgroundColor: Colors.blue, // Couleur de fond du bouton
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0), // Bord arrondi
                ),
              ),
            ),
            SizedBox(height: 20.0),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatisticTab(
                  title: 'Nombre de Jours',
                  icon: 'assets/icons/review.svg',
                  onTap: () {},
                  value: nbre_jours ?? '',
                ),
                StatisticTab(
                  title: 'Journalier',
                  icon: 'assets/icons/ballot-check.svg',
                  onTap: () {},
                  value: journalier ?? '',
                ),
              ],
            ),
            SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatisticTab(
                  title: 'Jours Payés',
                  icon: 'assets/icons/review.svg',
                  onTap: () {},
                  value: jour_paye ??
                      '0', // Remplacer par le nombre réel de clients
                ),
                StatisticTab(
                  title: 'Jours Restants',
                  icon: 'assets/icons/ballot-check.svg',
                  onTap: () {},
                  value: jour_reste ?? '',
                ),
              ],
            ),

            SizedBox(height: 20.0),
// Section pour l'historique des versements
            Text(
              'HISTORIQUE DES VERSEMENTS : ${livret}',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
// Tableau pour afficher l'historique des versements
            Flexible(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith(
                        (states) => Colors.blueGrey),
                    columns: [
                      DataColumn(
                          label: Text('JOURNALIER',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                      DataColumn(
                          label: Text('VERSER',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                      DataColumn(
                          label: Text('DATE',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                      DataColumn(
                          label: Text('HEURE',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                    ],
                    rows: versements.asMap().entries.map((entry) {
                      int index = entry.key;
                      Versement versement = entry.value;
                      return DataRow(
                        color: MaterialStateColor.resolveWith((states) =>
                            index % 2 == 0 ? Colors.grey[200]! : Colors.white),
                        cells: [
                          DataCell(Text(journalier ?? '')),
                          DataCell(Text(versement.verser)),
                          DataCell(Text(DateFormat('dd/MM/yyyy')
                              .format(DateTime.parse(versement.date)))),
                          DataCell(Text(versement.heure)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNouvelleTontineSheet(BuildContext context) {
    double montantJ = 0;
    int montantSaisi = 0;
    int quotient = 0;
    double totalRetraitPossible = 0;

    if (jour_reste != '0.0') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.grey[100], // Couleur de fond de la bottom sheet
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(20)), // Coins arrondis en haut
        ),
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Montant à verser',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.blueGrey[800], // Couleur du texte
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _montantController,
                        decoration: InputDecoration(
                          labelText: 'Montant en FCFA',
                          labelStyle: TextStyle(color: Colors.blueGrey[600]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: Colors.blueGrey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                        ),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) {
                          setState(() {
                            try {
                              montantJ = double.parse(journalier.toString());
                              montantSaisi = int.parse(value);
                              if (montantJ > 0 &&
                                  montantSaisi > 0 &&
                                  montantSaisi >= (montantJ - (monnaie ?? 0))) {
                                totalRetraitPossible =
                                    (montantSaisi + (monnaie ?? 0)) % montantJ;
                                quotient =
                                    (montantSaisi + (monnaie ?? 0)) ~/ montantJ;
                                print('monnaie : $totalRetraitPossible');
                              } else {
                                totalRetraitPossible = 0;
                                quotient = 0;
                              }
                            } catch (e) {
                              print(
                                  'Erreur lors de la conversion de la valeur saisie en double: $e');
                              totalRetraitPossible = 0;
                              quotient = 0;
                            }
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nombre de Jour : $quotient',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blueGrey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Monnaie Client: $totalRetraitPossible FCFA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.blueGrey[700],
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                double montant = montantSaisi + (monnaie ?? 0);
                                print('montant saisi : $montant');
                                if (montant > 0) {
                                  print(montant);
                                  _envoyerMontant(montant);
                                  Navigator.pop(
                                      context); // Ferme la bottom sheet
                                } else {
                                  // Afficher un message d'erreur si le champ est vide
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Veuillez entrer un montant'),
                                      backgroundColor: Colors
                                          .red, // Couleur de fond du SnackBar
                                    ),
                                  );
                                }
                                setState(() {
                                  _montantController.clear();
                                  totalRetraitPossible = 0;
                                  quotient = 0;
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24),
                          backgroundColor:
                              Colors.blue, // Couleur de fond du bouton
                          //backgroundColor:Colors.white, // Couleur du texte du bouton
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10.0), // Bord arrondi
                          ),
                          elevation: 5, // Ombre du bouton
                        ),
                        child: isSubmitting
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Text('Enregistrer'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
              'Impossible de faire un versement, aucun jour de versement restant.'),
        ),
      );
    }
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
        width: 180,
        height: 70,
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
