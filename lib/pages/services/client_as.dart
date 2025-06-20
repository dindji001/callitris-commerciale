import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:callitris/pages/auth_provider.dart';

class ClientSatisfairePage extends StatefulWidget {
  @override
  _ClientSatisfairePageState createState() => _ClientSatisfairePageState();
}

class Client {
  final String id;
  final String nom;
  final String prenom;
  final String contact;
  final String code;
  final String journalier;
  final String nbjr;

  Client({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.contact,
    required this.code,
    required this.journalier,
    required this.nbjr,
  });
}

class _ClientSatisfairePageState extends State<ClientSatisfairePage> {
  String searchText = '';
  List<Client> clients = [];
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  Future<void> fetchClients() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      String idPersonnel = user!['id_personnel'].toString();

      final response = await http.get(
        Uri.parse(provide.getEndpoint(
            'products/getClientSatisfait.php?personnel_id=$idPersonnel')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      //final List<dynamic> responseData = jsonDecode(response.body);
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        // ignore: unused_local_variable
        final Map<String, dynamic> clientData = responseData[0];
        // tableau des clients List converti en Map
        List<Client> fetchedClients = responseData.map((clientData) {
          String id = clientData['id_client'].toString();
          String nom = clientData['nom_client'].toString();
          String prenom = clientData['prenom_client'].toString();
          String contact = clientData['telephone_client'].toString();
          String journalier = clientData['journalier'].toString();
          String code = clientData['code_cmd'].toString();
          String nbjr = clientData['nbjr'].toString();

          return Client(
              id: id,
              nom: nom,
              prenom: prenom,
              contact: contact,
              code: code,
              journalier: journalier,
              nbjr: nbjr);
        }).toList();

        setState(() {
          clients = fetchedClients;
          _isLoading = false;
        });
      } else {
        print('Erreur : ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Erreur lors de la récupération des clients: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Clients á satisfaire'),
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
                hintText: 'Rechercher un client',
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
                : clients.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun client á satisfaire trouvé',
                          style: TextStyle(fontSize: 18.0, color: Colors.red),
                        ),
                      )
                    : ListView.builder(
                        itemCount: clients.length,
                        itemBuilder: (context, index) {
                          final client = clients[index];
                          // Filtrez la liste des clients en fonction du texte de recherche
                          if (searchText.isNotEmpty &&
                              (!client.nom
                                      .toLowerCase()
                                      .contains(searchText.toLowerCase()) &&
                                  !client.prenom
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
                                  child:
                                      Icon(Icons.person, color: Colors.white),
                                ),
                                title: Text(
                                  '${client.nom} ${client.prenom}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Code Commande: ${client.code}'),
                                    Text('Contact: ${client.contact}'),
                                    Text('Journalier: ${client.journalier}'),
                                    Text('Jours Payés: ${client.nbjr}'),
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
