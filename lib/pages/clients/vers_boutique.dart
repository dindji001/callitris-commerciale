import 'package:callitris/pages/auth_provider.dart';
import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:provider/provider.dart';

import '../../widget/ciruclarWidget.dart';

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
  final String reelVers;
  final String monnaieReste;
  final String monnaieVers;
  final String date;
  final String heure;

  Versement({
    required this.journalier,
    required this.verser,
    required this.reelVers,
    required this.monnaieReste,
    required this.monnaieVers,
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

  final _controllerMontant = TextEditingController();
  final _controllerJours = TextEditingController();
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

  void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false, // Empêche la fermeture en cliquant en dehors
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                "Succès",
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Text(
            message,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "OK",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
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
      //print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String monnaieValue = responseData['montant'].toString();
        setState(() {
          monnaie = double.parse(monnaieValue);
          //print(monnaie);
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
          String journalier = versementData['montant_vers'].toString();
          String verser = versementData['montant_vers'].toString();
          String reelVers = versementData['montant_saisi'].toString();
          String monnaieReste = versementData['monnaie_reste'].toString();
          String monnaieVers = versementData['monnaie'].toString();
          String date = versementData['date_vers'].toString();
          String heure = versementData['heure_vers'].toString();

          return Versement(
              journalier: journalier,
              verser: verser,
              reelVers: reelVers,
              monnaieReste: monnaieReste,
              monnaieVers: monnaieVers,
              date: date,
              heure: heure);
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
    _controllerMontant.dispose();
    _controllerJours.dispose();
    super.dispose();
  }

  String _formatNumber(String s) {
    // Remplace les points par des espaces avant de formater
    return _numberFormat.format(int.parse(
        s.replaceAll('.', '').replaceAll(' ', '').replaceAll('\u202F', '')));
  }

  Future<void> _envoyerMontant(
      int montantSaisi, double resteMonnaie, int monnaieExact) async {
    setState(() {
      isSubmitting = true; // Définir isSubmitting sur true avant la soumission
    });

    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      String personnelId = user!['id_personnel'].toString();
      if (montantSaisi + monnaieExact < (double.parse(journalier.toString()))) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 48.0,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Le montant doit etre superieur ou egal au montant journalier $journalier F',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
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
          'montant': montantSaisi,
          'monnaieExact': monnaieExact,
          'resteMonnaie': resteMonnaie,
          'personnelId': personnelId,
          'monnaie': monnaie,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        // Traitement en cas de succès
        //print('Données envoyées avec succès à l\'API');
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        //print(responseData['code']);

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
          setState(() {
            isSubmitting =
                false; // Définir isSubmitting sur true avant la soumission
          });
          showSuccessDialog(context, responseData['message']);
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

  bool useMonnaie = false; // Variable pour suivre l'état du switch

  void _showNouvelleTontineSheet(BuildContext context) {
    double montantJ = 0;
    int montantSaisi = 0;
    int nbrePaye = 0;
    int quotient = 0;
    int monnaieExact = 0;
    double resteMonnaie = 0;

    void recalculerMontants(StateSetter updateState) {
      try {
        montantJ = double.parse(journalier ?? '0');
        String amount = _controllerMontant.text
            .replaceAll('.', '')
            .replaceAll(' ', '')
            .replaceAll('\u202F', '');
        montantSaisi = amount.isNotEmpty ? int.parse(amount) : 0;

        double monnaieToUse = useMonnaie ? (monnaie ?? 0) : 0;

        if (montantSaisi >= montantJ && (resteMonnaie + monnaie!) < montantJ) {
          useMonnaie = false;
          monnaieToUse = 0;
          //print(useMonnaie); // Désactivation du switch
        }

        if (montantJ > 0 && montantSaisi >= (montantJ - monnaieToUse)) {
          resteMonnaie =
              (montantSaisi + monnaieToUse) % montantJ; // monnaie restante
          quotient = (montantSaisi + monnaieToUse) ~/ montantJ;
        } else {
          resteMonnaie = 0;
          quotient = 0;
        }

        // Utilisation de updateState pour mettre à jour les valeurs affichées
        updateState(() {});
        monnaieExact = (useMonnaie
            ? ((quotient * montantJ.toInt()) - montantSaisi)
            : 0); // monnaie exacte utilisée ajouter pour l achat
        print('Montant saisi: $montantSaisi');
        print('Montant journalier: $montantJ');
        print('Quotient calculé: $quotient');
        print('Monnaie restante: $resteMonnaie');
        print('Monnaie exact utilisée : $monnaieExact');
      } catch (e) {
        print('Erreur lors de la conversion de la valeur saisie en double: $e');
        resteMonnaie = 0;
        quotient = 0;
        monnaieExact = 0;
        updateState(() {});
      }
    }

    if (jour_reste != '0') {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
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
                        'Versement Boutique',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Utiliser la monnaie de $monnaie F',
                            style: TextStyle(fontSize: 20),
                          ),
                          Switch(
                            value: useMonnaie,
                            onChanged: (bool value) {
                              setState(() {
                                useMonnaie = value;
                                //print(useMonnaie);
                                recalculerMontants(setState);
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextFormField(
                                controller: _controllerMontant,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                      String newText =
                                          _formatNumber(newValue.text);
                                      return TextEditingValue(
                                        text: newText,
                                        selection: TextSelection.collapsed(
                                            offset: newText.length),
                                      );
                                    },
                                  ),
                                ],
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  recalculerMontants(setState);
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.orange),
                                  ),
                                  labelText: 'Montant à verser',
                                ),
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              child: TextFormField(
                                controller: _controllerJours,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.orange),
                                  ),
                                  labelText: 'Jours à payer',
                                ),
                                style: TextStyle(fontSize: 16),
                                onChanged: (value) {
                                  try {
                                    nbrePaye = int.parse(value);
                                    setState(() {});
                                    print('Nombre payer  : $nbrePaye');
                                  } catch (e) {
                                    print(
                                        'Erreur lors de la conversion de la valeur nombre de jours: $e');
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.0),
                        color: Colors.grey,
                        child: Text(
                          'Jours Correspondants : $quotient Jour(s)',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.0),
                        color: Colors.grey,
                        child: Text(
                          'Monnaie restante : $resteMonnaie FCFA',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: isSubmitting
                            ? null
                            : () {
                                if (!useMonnaie &&
                                    (resteMonnaie + monnaie!) > montantJ) {
                                  // Show a message to the user
                                  showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.error,
                                              color: Colors.red,
                                              size: 48.0,
                                            ),
                                            SizedBox(height: 16.0),
                                            Text(
                                              'Le total des monnaies dépasse le montant journalier. La monnaie doit etre utilisée.',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  return;
                                }
                                if (montantSaisi >= 0 &&
                                    (quotient == nbrePaye) &&
                                    nbrePaye > 0) {
                                  _envoyerMontant(
                                      montantSaisi, resteMonnaie, monnaieExact);
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pop(context);
                                  showDialog<void>(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.error,
                                              color: Colors.red,
                                              size: 48.0,
                                            ),
                                            SizedBox(height: 16.0),
                                            Text(
                                              'Veuillez entrer le montant et le nombre de jours correspondant',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }

                                setState(() {
                                  _montantController.clear();
                                  _controllerJours.clear();
                                  _controllerMontant.clear();
                                  resteMonnaie = 0;
                                  quotient = 0;
                                  useMonnaie = false;
                                });
                              },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 25),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
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
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 48.0,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Impossible de faire un versement, aucun jour de versement restant.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
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
      body:isSubmitting
          ? ShowLoadingDialog()
          : Padding(
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
                          label: Text('Journalier',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                      DataColumn(
                          label: Text('Réel Verser',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                      DataColumn(
                          label: Text('Monnaie Utilisée',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                      DataColumn(
                          label: Text('Monnaie Restante',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                      DataColumn(
                          label: Text('Date',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white))),
                      DataColumn(
                          label: Text('Heure',
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
                          DataCell(Text(versement.reelVers)),
                          DataCell(Text(versement.monnaieVers)),
                          DataCell(Text(versement.monnaieReste)),
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
