import 'package:callitris/pages/auth_provider.dart';
import 'package:callitris/pages/clients/vers_tontine.dart';
import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class ClientDetailTontinePage extends StatefulWidget {
  final String id;

  ClientDetailTontinePage({required this.id});

  @override
  _ClientDetailTontinePageState createState() =>
      _ClientDetailTontinePageState();
}

class Client {
  final String id;
  final String nom;
  final String prenom;
  final String contact;
  final String contact2;
  final String adresse;

  Client({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.contact,
    required this.contact2,
    required this.adresse,
  });
}

class Tontine {
  final String id;
  final String prixJournalier;
  final int nombreJours;
  final String solde;
  final String libelle;
  final String day;

  Tontine({
    required this.id,
    required this.prixJournalier,
    required this.nombreJours,
    required this.solde,
    required this.libelle,
    required this.day,
  });
}

class _ClientDetailTontinePageState extends State<ClientDetailTontinePage> {
  Client? client;
  bool isLoading = true;
  List<Tontine> tontines = [];
  List<Tontine> filteredTontines = [];
  bool reachedTontines = true;
  TextEditingController montantJournalierController = TextEditingController();
  String? monnaie;

  @override
  void dispose() {
    // Disposez du TextEditingController pour éviter les fuites de mémoire
    montantJournalierController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchClientData();
    fetchTontines();
    fetchMonnaie();
  }

  Future<void> fetchClientData() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final provide = Provider.of<AuthProvider>(context, listen: false);

      final response = await http.get(
        Uri.parse(provide
            .getEndpoint('client/getClientById.php?id_client=${widget.id}')),
        headers: {
          'Authorization': token!,
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String id = responseData['id_client'].toString();
        String nom = responseData['nom_client'].toString();
        String prenom = responseData['prenom_client'].toString();
        String contact = responseData['telephone_client'].toString();
        String contact2 = responseData['telephone2_client'].toString();
        String adresse = responseData['domicile_client'].toString();

        setState(() {
          client = Client(
            id: id,
            nom: nom,
            prenom: prenom,
            contact: contact,
            contact2: contact2,
            adresse: adresse,
          );
          isLoading = false;
        });
      } else {
        print('Erreur : ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération des données du client: $error');
    }
  }

  Future<void> fetchTontines() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      final response = await http.get(
        Uri.parse(provide.getEndpoint(
            'products/getTontinesClient.php?id_client=${widget.id}')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      //print(response.statusCode);
      //print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        List<Tontine> fetchedTontines = responseData.map((tontineData) {
          String id = tontineData['id_colombe'].toString();
          String prixJournalier = tontineData['journalier_col'].toString();
          int nombreJours = int.parse(tontineData['compteur_col'] ?? '0');
          String solde = tontineData['solde_col'].toString();
          String libelle = tontineData['libelle_col'].toString();
          String day = tontineData['date_ajout'].toString();

          return Tontine(
            id: id,
            prixJournalier: prixJournalier,
            nombreJours: nombreJours,
            solde: solde,
            libelle: libelle,
            day: day,
          );
        }).toList();

        setState(() {
          tontines = fetchedTontines;
          filteredTontines = List.from(tontines);
        });
      } else {
        print('Erreur : ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération des données de la tontine: $error');
    }
  }

  Future<void> fetchMonnaie() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      final response = await http.get(
        Uri.parse(
            provide.getEndpoint('client/getMonnaie.php?clientId=${widget.id}')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String monnaieValue = responseData['montant'].toString();

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

  void filterTontines(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredTontines = tontines
            .where((tontine) =>
                tontine.id.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        filteredTontines = List.from(tontines);
      }
    });
  }

  void _sendNewTontine(
      double montantJournalier, String libelleEpargne, String clientId) async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      String idPersonnel = user!['id_personnel'].toString();
      final response = await http.post(
        Uri.parse(provide.getEndpoint('products/addTontine.php')),
        headers: {
          'Authorization': token!,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'journalier': montantJournalier,
          'libelle_col': libelleEpargne,
          'clientId': clientId,
          'personnelId': idPersonnel,
        }),
      );
      if (response.statusCode == 200) {
        // Succès de la requête
        // print(response.body);
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // print(responseData['code']);

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
            // Réinitialiser la liste des tontines pour forcer la récupération des données mises à jour depuis l'API
            tontines.clear();
            filteredTontines.clear();
            fetchTontines();
          });
        }
      } else {
        // Erreur lors de la requête
        print(
            'Erreur lors de l\'envoi des données à l\'API: ${response.statusCode}');
        // print(response.body);
      }
    } catch (error) {
      // Gestion des erreurs
      print('Erreur lors de l\'envoi des données à l\'API: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détail Client Tontine'),
        backgroundColor: Color.fromARGB(255, 249, 221, 175),
        actions: buildAppBarActions(context),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: client != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 16),
                          _buildClientInfo(
                              client!.nom,
                              client!.prenom,
                              client!.contact,
                              client!.contact2,
                              client!.adresse,
                              monnaie),
                          SizedBox(height: 24),
                          _buildShoppingButton(),
                          SizedBox(height: 16),
                          _buildSearchBar(),
                          SizedBox(height: 8),
                          _buildCommandesList(),
                        ],
                      )
                    : Text("Client non trouvé."),
              ),
            ),
    );
  }

  Widget _buildClientInfo(String nom, String prenom, String contact,
      String contact2, String adresse, String? monnaie) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Colors.blue[50], // Couleur de fond de la carte
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60, // Largeur du conteneur de l'avatar
              height: 60, // Hauteur du conteneur de l'avatar
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // Couleur de fond de l'avatar
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/clipboard.svg',
                  width: 40.0,
                  color: Colors.orange,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$nom $prenom',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Contact: $contact',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Contact Proche: $contact2',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    'Adresse: $adresse',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 12),
                  Divider(),
                  SizedBox(height: 8),
                  Text(
                    'Monnaie: $monnaie FCFA',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Mes Comptes Tontine',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              _showNouvelleTontineSheet(context);
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              backgroundColor: Colors.orangeAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            icon: Icon(Icons.euro, color: Colors.white),
            label: Text(
              'Epargner',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showNouvelleTontineSheet(BuildContext context) {
    double montantJournalier = 0;
    double totalRetraitPossible = 0;
    double totalSoldeAttendu = 0;
    String libelleEpargne = '';

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Nouvelle Tontine',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(labelText: 'Libellé épargne'),
                      onChanged: (value) {
                        setState(() {
                          libelleEpargne = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: montantJournalierController,
                      decoration:
                          InputDecoration(labelText: 'Montant journalier'),
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        setState(() {
                          try {
                            montantJournalier = double.parse(value);
                            totalRetraitPossible = montantJournalier * 20;
                            totalSoldeAttendu = montantJournalier * 21;
                          } catch (e) {
                            print(
                                'Erreur lors de la conversion de la valeur saisie en double: $e');
                            totalRetraitPossible = 1;
                            totalSoldeAttendu = 1;
                          }
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Total retrait possible: $totalRetraitPossible',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Total solde attendu: $totalSoldeAttendu',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        _sendNewTontine(
                            montantJournalier, libelleEpargne, widget.id);
                        Navigator.pop(
                            context); // Ferme la modalité après l'envoi des données

                        // Réinitialisez les valeurs des champs après la validation et la fermeture de la modalité
                        setState(() {
                          montantJournalierController.clear();
                          montantJournalier = 0;
                          libelleEpargne = '';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 20), // Ajuster le padding
                        backgroundColor:
                            Colors.blue, // Couleur de fond du bouton
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.0), // Bord arrondi
                        ),
                      ),
                      child: Text(
                        'Enregistrer',
                        style: TextStyle(fontSize: 20, color: Colors.white),
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Rechercher une tontine',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: (query) {
          filterTontines(query);
        },
      ),
    );
  }

  Widget _buildCommandesList() {
    return SingleChildScrollView(
      physics: reachedTontines ? NeverScrollableScrollPhysics() : null,
      child: Column(
        children: [
          SizedBox(height: 16),
          ...filteredTontines.map((tontine) {
            return Card(
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.money_rounded, color: Colors.blue),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${tontine.libelle}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('Journalier: ${tontine.prixJournalier}'),
                              Text('Jours: ${tontine.nombreJours}'),
                              Text('Solde: ${tontine.solde}'),
                              Text('Date: ${tontine.day}'),
                            ],
                          ),
                        ),
                        SizedBox(
                            width:
                                16), // Ajout d'un espace entre le texte et les boutons
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VersementTontinePage(
                                        id: tontine.id, client: widget.id),
                                  ),
                                );

                                //print(result);
                                if (result == null) {
                                  // Recharger les données
                                  await fetchClientData();
                                  await fetchTontines();
                                  await fetchMonnaie();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              child: Text(
                                'Verser',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 0, thickness: 1),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
