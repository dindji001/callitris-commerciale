//import 'package:callitris/pages/clients/update_commande.dart';
import 'package:callitris/pages/clients/vers_boutique.dart';
import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:callitris/pages/auth_provider.dart';
import 'package:callitris/pages/services/boutique.dart';

class ClientDetailBoutiquePage extends StatefulWidget {
  final String id;

  ClientDetailBoutiquePage({required this.id});

  @override
  _ClientDetailBoutiquePageState createState() =>
      _ClientDetailBoutiquePageState();
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

class Commande {
  final String id;
  final String prixJournalier;
  final String nombreJours;
  final String livret;
  final String code;
  final String pack;
  final String cle;
  final String payer;
  final String reste;

  Commande({
    required this.id,
    required this.prixJournalier,
    required this.nombreJours,
    required this.livret,
    required this.code,
    required this.pack,
    required this.cle,
    required this.payer,
    required this.reste,
  });
}

class _ClientDetailBoutiquePageState extends State<ClientDetailBoutiquePage> {
  Client? client;
  bool isLoading = true;
  List<Commande> commandes = [];
  List<Commande> filteredCommandes = [];
  bool reachedCommandes = true;
  String? monnaie;

  @override
  void initState() {
    super.initState();
    fetchClientData();
    fetchCommandes();
    fetchMonnaie();
  }

  Future<void> fetchMonnaie() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final provide = Provider.of<AuthProvider>(context, listen: false);

      final response = await http.get(
        Uri.parse(
            provide.getEndpoint('client/getMonnaie.php?clientId=${widget.id}')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      //print (response.body);
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

  Future<void> fetchClientData() async {
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final provide = Provider.of<AuthProvider>(context, listen: false);

      final response = await http.get(
        Uri.parse(provide
            .getEndpoint('client/getClientById.php?id_client=${widget.id}')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
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

  Future<void> fetchCommandes() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      final response = await http.get(
        Uri.parse(provide.getEndpoint(
            'products/getCommandesClient.php?id_client=${widget.id}')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      //print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        List<Commande> fetchedCommandes = responseData.map((commandeData) {
          String id = commandeData['id'].toString();
          String prixJournalier = commandeData['journalier'].toString();
          String nombreJours = commandeData['jour'].toString();
          String livret = commandeData['livret'].toString();
          String code = commandeData['code_cmd'].toString();
          String pack = commandeData['pack'].toString();
          String cle = commandeData['cle'].toString();
          String payer = commandeData['paye'].toString();
          String reste = commandeData['reste'].toString();

          return Commande(
            id: id,
            prixJournalier: prixJournalier,
            nombreJours: nombreJours,
            livret: livret,
            code: code,
            pack: pack,
            cle: cle,
            payer: payer,
            reste: reste,
          );
        }).toList();

        setState(() {
          commandes = fetchedCommandes;
          filteredCommandes = List.from(commandes);
        });
      } else {
        print('Erreur : ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération des commandes: $error');
    }
  }

  void filterCommandes(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredCommandes = commandes
            .where((commande) =>
                commande.id.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        filteredCommandes = List.from(commandes);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détail Client Boutique'),
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
                              client!.adresse,
                              monnaie,
                              client!.contact2),
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
      String adresse, String? monnaie, String contact2) {
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
                    'Monnaie: $monnaie F',
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
              'Suivi des Commandes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BoutiquePage(id: client!.id)));

              //print(result);
              if (result == null) {
                // Recharger les données
                await fetchClientData();
                await fetchCommandes();
                await fetchMonnaie();
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              backgroundColor: Colors.orangeAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            label: Text(
              'Nouvelle Commande',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search),
          hintText: 'Rechercher une commande',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onChanged: (query) {
          filterCommandes(query);
        },
      ),
    );
  }

  Widget _buildCommandesList() {
    return SingleChildScrollView(
      physics: reachedCommandes ? NeverScrollableScrollPhysics() : null,
      child: Column(
        children: [
          SizedBox(height: 16),
          ...filteredCommandes.map((commande) {
            return Card(
              elevation: 5,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading:
                        Icon(Icons.assignment, color: Colors.blue, size: 36),
                    title: Text(
                      '${commande.livret}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text('Nº Commande : ${commande.code}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        Text('Num Pack : ${commande.pack}'),
                        Text('Montant Journalier : ${commande.prixJournalier}'),
                        Text('Nombre de Jours : ${commande.nombreJours}'),
                        Text('Jours Payés : ${commande.payer}'),
                        Text('Jours Restants : ${commande.reste}'),
                        //Text('Option: ${commande.option}'),
                      ],
                    ),
                    contentPadding: EdgeInsets.all(10),
                    isThreeLine: true,
                  ),
                  Divider(height: 1, thickness: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VersementPage(
                                  id: commande.id,
                                  cle: commande.cle,
                                  client: widget.id,
                                ),
                              ),
                            );
                            //print(result);
                            if (result == null) {
                              // Recharger les données
                              await fetchClientData();
                              await fetchCommandes();
                              await fetchMonnaie();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue,
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 20.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          icon: Icon(Icons.attach_money),
                          label: Text(
                            'Versement',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 12),
                        /* 
                        if (double.parse(commande.payer) > 0)
                         ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BoutiqueUpdatePage(
                                    clientId: widget.id,
                                    commandeId: commande.id,
                                    cle: commande.cle,
                                    code: commande.code,
                                    payer: commande.payer,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.yellowAccent,
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 20.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            icon: Icon(Icons.edit),
                            label: Text('Modifier'),
                          ),*/
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
