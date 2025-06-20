import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:callitris/pages/auth_provider.dart';

class LivraisonPage extends StatefulWidget {
  @override
  _LivraisonPageState createState() => _LivraisonPageState();
}

class Option {
  final String id;
  final String value;

  Option(this.id, this.value);
}

class _LivraisonPageState extends State<LivraisonPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<DeliveryInfo> _deliveries = [];
  List<DeliveryInfo> _filteredDeliveries = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();
  Option? selectedChoice;
  List<Option> _planningOptions = [];

  Future<void> _fetchPlanningOptions() async {
    final provide = Provider.of<AuthProvider>(context, listen: false);
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final response = await http.get(
      Uri.parse(provide.getEndpoint('products/getPlanning.php')),
      headers: {'Authorization': token!, 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Option> options = data.map((item) {
        return Option(
            item['id_campagne_detail'].toString(), item['name_cmp'].toString());
      }).toList();
      setState(() {
        _planningOptions = options;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPlanningOptions();
    _searchController.addListener(_onSearchChanged);
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    fetchDeliveries();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    // Mettre à jour les livraisons filtrées en fonction de l'onglet sélectionné
    setState(() {
      if (_tabController.index == 0) {
        // Filtrer les livraisons en attente
        _filteredDeliveries = _deliveries
            .where(
                (delivery) => delivery.finished == 1 && delivery.delivered == 0)
            .toList();
      } else {
        // Filtrer les livraisons livrées
        _filteredDeliveries =
            _deliveries.where((delivery) => delivery.delivered == 1).toList();
      }
    });
  }

  void _onSearchChanged() {
    setState(() {
      _filteredDeliveries = _deliveries.where((delivery) {
        final searchValue = _searchController.text.toLowerCase();
        return delivery.commande.contains(searchValue) ||
            delivery.nom.toLowerCase().contains(searchValue) ||
            delivery.dateFin.toLowerCase().contains(searchValue) ||
            delivery.contact.toLowerCase().contains(searchValue) ||
            delivery.prenom.contains(searchValue);
      }).toList();
    });
  }

  Future<void> fetchDeliveries() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final user = Provider.of<AuthProvider>(context, listen: false)
          .user; // Ajoutez l'ID du personnel ici

      final response = await http.get(
        Uri.parse(provide.getEndpoint(
            'products/getLivraison.php?personnel_id=${user?['id_personnel']}')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        List<DeliveryInfo> fetchedDeliveries = responseData.map((deliveryData) {
          String commande = deliveryData['code_cmd'].toString();
          String dateFin = deliveryData['last_date_add'].toString();
          String nom = deliveryData['nom_client'].toString();
          String prenom = deliveryData['prenom_client'].toString();
          String contact = deliveryData['telephone_client'].toString();
          String choix = deliveryData['choix'] ?? ' ';
          int delivered = int.parse(deliveryData['delivered'].toString());
          int finished = int.parse(deliveryData['finished'].toString());

          return DeliveryInfo(commande, dateFin, nom, prenom, contact, choix,
              delivered, finished);
        }).toList();

        setState(() {
          _deliveries = fetchedDeliveries;
          _filteredDeliveries = List.from(_deliveries);
          _isLoading = false;
        });
      } else {
        print('Erreur : ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération des livraisons: $error');
    }
  }

  Future<void> _sendPlan(
      String choixId, String commandeId, String campagne) async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      final response = await http.post(
        Uri.parse(provide.getEndpoint('products/addPlan.php')),
        body: jsonEncode({
          'choixId': choixId,
          'commandeId': commandeId,
          'campagne': campagne
        }),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      //print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'],
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          fetchDeliveries();
        });
      } else {
        print('Erreur : ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération des livraisons: $error');
    }
  }

  Future<void> _refreshData() async {
    await fetchDeliveries(); // Met à jour les données de livraison
    setState(() {
      _filteredDeliveries = List.from(_deliveries);
      print(
          'test'); // Met à jour _filteredDeliveries avec les nouvelles données
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 249, 221, 175),
        title: Text('Suivi de Livraison'),
        actions: buildAppBarActions(context),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                'En attente',
                style: TextStyle(
                  fontSize: 16, // Taille de la police
                  fontWeight: FontWeight.bold, // Police en gras
                  color: _tabController.index == 0
                      ? Colors.black
                      : Colors
                          .grey, // Couleur du texte en fonction de l'onglet actif
                ),
              ),
            ),
            Tab(
              child: Text(
                'Livrées',
                style: TextStyle(
                  fontSize: 16, // Taille de la police
                  fontWeight: FontWeight.bold, // Police en gras
                  color: _tabController.index == 1
                      ? Colors.black
                      : Colors
                          .grey, // Couleur du texte en fonction de l'onglet actif
                ),
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Rechercher',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Contenu de l'onglet "En attente"
                        _buildDeliveryList(_filteredDeliveries
                            .where((delivery) =>
                                delivery.delivered == 0 &&
                                delivery.finished == 1)
                            .toList()),
                        // Contenu de l'onglet "Livrées"
                        _buildDeliveryList(_filteredDeliveries
                            .where((delivery) => delivery.delivered == 1)
                            .toList()),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDeliveryList(List<DeliveryInfo> deliveries) {
    return ListView.builder(
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        return buildDeliveryCard(deliveries[index]);
      },
    );
  }

  Widget buildDeliveryCard(DeliveryInfo delivery) {
    // Variable pour stocker le texte et la couleur en fonction de l'état de la livraison
    String deliveryStatusText;
    Color deliveryStatusColor;

    // Vérifier l'état de la livraison
    if (delivery.delivered == 0) {
      // Livraison en attente
      deliveryStatusText = 'En attente de livraison';
      deliveryStatusColor =
          Colors.red; // Couleur pour les livraisons en attente
    } else {
      // Livraison en cours de livraison
      deliveryStatusText = 'Livraison effectuée';
      deliveryStatusColor =
          Colors.green; // Couleur pour les livraisons en cours de livraison
    }

    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'N° CMD: ${delivery.commande}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Text('Nom: ${delivery.nom}'),
                Text('Prenoms: ${delivery.prenom}'),
                Text('Date de Fin: ${delivery.dateFin}'),
                Text('Contact: ${delivery.contact}'),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(Icons.circle, color: deliveryStatusColor, size: 12.0),
                    SizedBox(width: 4.0),
                    Text(deliveryStatusText,
                        style: TextStyle(
                            fontSize: 12.0, color: deliveryStatusColor)),
                  ],
                ),
              ],
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/truck-check.svg',
                  color: Colors.blue,
                  height: 40,
                ),
                SizedBox(height: 8.0),
                // Bouton "Choix" ouvrant un menu déroulant
                if (delivery.delivered == 0)
                  delivery.choix != ' '
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 3,
                                offset:
                                    Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              delivery.choix,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        )
                      : PopupMenuButton<Option>(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 3,
                                  offset: Offset(
                                      0, 2), // changes position of shadow
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              selectedChoice?.value ?? 'Choisir',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          itemBuilder: (BuildContext context) {
                            return _planningOptions.map((Option option) {
                              return PopupMenuItem<Option>(
                                value: option,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 3,
                                        offset: Offset(
                                            0, 2), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    option.value,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          onSelected: (Option choice) {
                            setState(() {
                              selectedChoice = choice;
                              _sendPlan(
                                  choice.id, delivery.commande, choice.value);
                            });

                            //
                          },
                        ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryInfo {
  final String commande;
  final String dateFin;
  final String nom;
  final String prenom;
  final String contact;
  final String choix;
  final int delivered;
  final int finished;

  DeliveryInfo(this.commande, this.dateFin, this.nom, this.prenom, this.contact,
      this.choix, this.delivered, this.finished);
}
