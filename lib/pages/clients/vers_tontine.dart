import 'package:callitris/pages/auth_provider.dart';
import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:provider/provider.dart';

import '../../widget/ciruclarWidget.dart';

class VersementTontinePage extends StatefulWidget {
  final String id;
  final String client;
  VersementTontinePage({required this.id, required this.client});

  @override
  _VersementTontinePageState createState() => _VersementTontinePageState();
}

class Versement {
  final String journalier;
  final String verser;
  final String reelVerser;
  final String monnaieReste;
  final String monnaieReel;
  final String date;
  final String heure;

  Versement({
    required this.journalier,
    required this.verser,
    required this.reelVerser,
    required this.monnaieReste,
    required this.monnaieReel,
    required this.date,
    required this.heure,
  });
}

class _VersementTontinePageState extends State<VersementTontinePage> {
  double montantEpargne = 0;
  List<Versement> versements = [];
  late int compteur = 0;

  late TextEditingController _montantController;
  int? solde;
  double? journalier;

  String? libelle;
  double? monnaie;

  final _controllerMontant = TextEditingController();
  final _controllerJours = TextEditingController();
  final NumberFormat _numberFormat = NumberFormat("#,###", "fr_FR");

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _chargerHistorique();
    _tontineInfo();
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
          print(monnaie);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Versement Tontine'),
        backgroundColor: Color.fromARGB(255, 249, 221, 175),
        actions: buildAppBarActions(context),
      ),
      body: isSubmitting
          ? ShowLoadingDialog()
          : Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // _showMontantModal(context);
                      _showNouvelleTontineSheet(context);
                    },
                    icon: Icon(Icons.payment, color: Colors.white),
                    label: Text(
                      'Effectuer un versement',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 50), // Ajuster le padding
                      backgroundColor:
                          Colors.orange, // Couleur de fond du bouton
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // Bord arrondi
                      ),
                    ),
                  ),

                  // Tableau avec boutons d'entrée
                  Container(
                    padding: EdgeInsets.all(3),
                    child: DataTable(
                      columnSpacing: 20.0, // Espacement entre les colonnes
                      columns: [
                        DataColumn(
                            label: TextButton(
                          onPressed: null,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              getColorForButton(1, compteur),
                            ),
                          ),
                          child: Text(
                            '1',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        )),
                        DataColumn(
                            label: TextButton(
                          onPressed: null,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              getColorForButton(2, compteur),
                            ),
                          ),
                          child: Text(
                            '2',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        )),
                        DataColumn(
                            label: TextButton(
                          onPressed: null,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              getColorForButton(3, compteur),
                            ),
                          ),
                          child: Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        )),
                        DataColumn(
                            label: TextButton(
                          onPressed: null,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              getColorForButton(4, compteur),
                            ),
                          ),
                          child: Text(
                            '4',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        )),
                      ],
                      rows: [
                        DataRow(cells: [
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(5, compteur),
                              ),
                            ),
                            child: Text(
                              '5',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(6, compteur),
                              ),
                            ),
                            child: Text(
                              '6',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(7, compteur),
                              ),
                            ),
                            child: Text(
                              '7',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(8, compteur),
                              ),
                            ),
                            child: Text(
                              '8',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(9, compteur),
                              ),
                            ),
                            child: Text(
                              '9',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(10, compteur),
                              ),
                            ),
                            child: Text(
                              '10',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(11, compteur),
                              ),
                            ),
                            child: Text(
                              '11',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(12, compteur),
                              ),
                            ),
                            child: Text(
                              '12',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(13, compteur),
                              ),
                            ),
                            child: Text(
                              '13',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(14, compteur),
                              ),
                            ),
                            child: Text(
                              '14',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(15, compteur),
                              ),
                            ),
                            child: Text(
                              '15',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(16, compteur),
                              ),
                            ),
                            child: Text(
                              '16',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(17, compteur),
                              ),
                            ),
                            child: Text(
                              '17',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(18, compteur),
                              ),
                            ),
                            child: Text(
                              '18',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(19, compteur),
                              ),
                            ),
                            child: Text(
                              '19',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(20, compteur),
                              ),
                            ),
                            child: Text(
                              '20',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(TextButton(
                            onPressed: null,
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                getColorForButton(21, compteur),
                              ),
                            ),
                            child: Text(
                              '21',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )),

                          DataCell(
                            Text(
                              solde.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          DataCell(
                              Container()), // Cellule vide pour aligner correctement la dernière colonne
                          DataCell(
                              Container()), // Cellule vide pour aligner correctement la dernière colonne
                        ]),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  // Section pour l'historique
                  Text(
                    'HISTORIQUE DU COMPTE : ${libelle}',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: DataTable(
                        columnSpacing: 20.0,
                        columns: [
                          DataColumn(label: Text('Verser')),
                          DataColumn(label: Text('Monnaie')),
                          DataColumn(label: Text('Restante')),
                          DataColumn(label: Text('Date')),
                          DataColumn(label: Text('Heure')),
                        ],
                        rows:
                            _buildRows(), // Utiliser une méthode pour construire les lignes du DataTable
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _formatNumber(String s) {
    // Remplace les points par des espaces avant de formater
    return _numberFormat.format(int.parse(
        s.replaceAll('.', '').replaceAll(' ', '').replaceAll('\u202F', '')));
  }

///////
  ///
  ///

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
        montantJ = journalier ?? 0;
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
          resteMonnaie = (montantSaisi + monnaieToUse) % montantJ;
          quotient = (montantSaisi + monnaieToUse) ~/ montantJ;
        } else {
          resteMonnaie = 0;
          quotient = 0;
        }

        // Utilisation de updateState pour mettre à jour les valeurs affichées
        updateState(() {});
        monnaieExact =
            (useMonnaie ? ((quotient * montantJ.toInt()) - montantSaisi) : 0);
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
                      'Versement Tontine',
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
                                  borderSide: BorderSide(color: Colors.orange),
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
                                  borderSide: BorderSide(color: Colors.orange),
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
                      onPressed: () {
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
                      child: Text(
                        'Enregistrer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  ///
  ///

///////

  void _envoyerMontant(montantSaisi, resteMonnaie, monnaieExact) async {
    setState(() {
      isSubmitting = true; // Définir isSubmitting sur true avant la soumission
    });
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      String idPersonnel = user!['id_personnel'].toString();

      Map<String, dynamic> requestBody = {
        'montantSaisi': montantSaisi,
        'monnaieExact': monnaieExact,
        'restMonnaie': resteMonnaie,
        'clientId': widget.client,
        'tontine_id': widget.id,
        'personnelId': idPersonnel,
        'monnaie': monnaie,
      };
      if (montantSaisi + monnaieExact < (journalier ?? 0)) {
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
        Uri.parse(provide.getEndpoint('products/addVersementTontine.php')),
        headers: {
          'Authorization': token!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );
      //print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        //print(responseData['code']);

        if (responseData['code'] == 201) {
          setState(() {
            isSubmitting =
                false; // Définir isSubmitting sur true avant la soumission
          });
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
            _chargerHistorique();
            _tontineInfo();
            fetchMonnaie();
          });
        }
      } else {
        print('Erreur lors de l\'envoi du montant: ${response.body}');
      }
    } catch (error) {
      print('Erreur lors de l\'envoi du montant: $error');
    } finally {
      setState(() {
        isSubmitting = false; // Réinitialiser isSubmitting après la soumission
      });
    }
  }

  List<DataRow> _buildRows() {
    List<DataRow> rows = [];
    for (int i = 0; i < versements.length; i++) {
      Versement versement = versements[i];
      rows.add(
        DataRow(cells: [
          //DataCell(Text((i + 1).toString())), // Numéro de ligne

          DataCell(Text(versement.reelVerser)), // Montant versé
          DataCell(Text(versement.monnaieReel)), // monnaie reel
          DataCell(Text(versement.monnaieReste)), // monnaie reel
          DataCell(Text(versement.date)), // Date du versement
          DataCell(Text(versement.heure)), // Heure du versement
        ]),
      );
    }
    return rows;
  }

  Future<void> _tontineInfo() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      final response = await http.get(
        Uri.parse(provide
            .getEndpoint('products/getTontineById.php?tontineId=${widget.id}')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> tontineData = jsonDecode(response.body);

        setState(() {
          compteur = int.parse(tontineData['compteur_col']);
          journalier = double.parse(tontineData['journalier_col']);
          solde = (compteur * journalier!).toInt();
          libelle = tontineData['libelle_col'].toString();
        });
      } else {
        print(
            'Erreur lors de la récupération des informations de la tontine: ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors du chargement de tontine: $error');
    }
  }

  void _chargerHistorique() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final versementsResponse = await http.get(
        Uri.parse(provide.getEndpoint(
            'products/getVersementsCompte.php?compte_id=2&id=${widget.id}')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );

      if (versementsResponse.statusCode == 200) {
        final List<dynamic> data = jsonDecode(versementsResponse.body);
        List<Versement> historiqueVersements = data.map((versData) {
          String journalier = versData['montant_vers'].toString();
          String verser = versData['montant_vers'].toString();
          String reelVerser = versData['montant_saisi'].toString();
          String monnaieReste = versData['monnaie_reste'].toString();
          String monnaieReel = versData['monnaie'].toString();
          String date = versData['date_vers'].toString();
          String heure = versData['heure_vers'].toString();

          return Versement(
              journalier: journalier,
              verser: verser,
              reelVerser: reelVerser,
              monnaieReste: monnaieReste,
              monnaieReel: monnaieReel,
              date: date,
              heure: heure);
        }).toList();

        setState(() {
          this.compteur =
              compteur; // Mettre à jour la valeur du compteur dans l'état de votre widget

          versements = historiqueVersements;
        });
      } else {
        print(
            'Erreur lors du chargement de l\'historique des versements: ${versementsResponse.statusCode}');
      }
    } catch (error) {
      print('Erreur lors du chargement de l\'historique: $error');
    }
  }

  Color getColorForButton(int number, int compteur) {
    if (number <= compteur) {
      return Colors
          .green; // Si le numéro est inférieur ou égal au compteur + 1, la couleur est verte
    } else if (number == compteur + 1) {
      return Colors
          .blue; // Si le numéro est compris entre le compteur + 1 et le double du compteur, la couleur est bleue
    } else {
      return Colors.red; // Sinon, la couleur est grise
    }
  }

  Color getColorForText(int number, int compteur) {
    if (number <= compteur) {
      return Colors
          .green; // Si le numéro est inférieur ou égal au compteur + 1, la couleur est verte
    } else if (number == compteur + 1) {
      return Colors
          .blue; // Si le numéro est compris entre le compteur + 1 et le double du compteur, la couleur est bleue
    } else {
      return Colors.red; // Sinon, la couleur est grise
    }
  }
}
