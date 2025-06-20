import 'package:callitris/pages/menu.dart';
import 'package:callitris/pages/services/boutique.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:callitris/pages/auth_provider.dart';
import 'package:callitris/pages/clients/user_page_boutique.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ClientBoutiquePage extends StatefulWidget {
  @override
  _ClientBoutiquePageState createState() => _ClientBoutiquePageState();
}

class Client {
  final String id;
  final String nom;
  final String prenom;
  final String startDate;
  final String startHeure;
  final String contact;
  final String contact2;
  final String adresse;

  Client({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.startDate,
    required this.startHeure,
    required this.contact,
    required this.contact2,
    required this.adresse,
  });
}

class _ClientBoutiquePageState extends State<ClientBoutiquePage> {
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
            'client/getClientCompte.php?id_personnel=$idPersonnel&compte_id=1')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        List<Client> fetchedClients = responseData.map((clientData) {
          String id = clientData['id_client'].toString();
          String nom = clientData['nom_client'].toString();
          String prenom = clientData['prenom_client'].toString();
          String contact = clientData['telephone_client'].toString();
          String contact2 = clientData['telephone2_client'].toString();
          String adresse = clientData['domicile_client'].toString();
          String startDate = clientData['date_ajout'].toString();
          String startHeure = clientData['heure_ajout'].toString();

          return Client(
            id: id,
            nom: nom,
            prenom: prenom,
            startDate: startDate,
            startHeure: startHeure,
            contact: contact,
            contact2: contact2,
            adresse: adresse,
          );
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
      setState(() {
        _isLoading = false;
      });
      print('Erreur lors de la récupération des clients: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Diviser le texte de recherche en mots séparés
    List<String> searchTerms = searchText.toLowerCase().split(' ');

    // Filtrer les clients en fonction des mots de recherche
    List<Client> displayedClients = clients.where((client) {
      // Vérifier si tous les mots de recherche correspondent à un client
      return searchTerms.every((term) {
        return client.nom.toLowerCase().contains(term) ||
            client.prenom.toLowerCase().contains(term) ||
            client.contact.toLowerCase().contains(term);
      });
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Clients Boutique (${displayedClients.length})'),
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
          if (displayedClients.isEmpty && searchText.isNotEmpty)
            const Center(
              child: Text(
                'Aucun client trouvé !',
                style: TextStyle(
                  fontSize:
                      18, // Ajustez la taille de la police selon vos besoins
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    itemCount: 5, // Nombre arbitraire de squelettes
                    itemBuilder: (context, index) {
                      return Skeletonizer(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
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
                                  'assets/icons/clipboard.svg',
                                  width: 30.0,
                                  color: Colors.orange,
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
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: displayedClients.length,
                    itemBuilder: (context, index) {
                      final client = displayedClients[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Card(
                          color: Color.fromARGB(255, 152, 208, 253),
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: SvgPicture.asset(
                                'assets/icons/clipboard.svg',
                                width: 30.0,
                                color: Colors.orange,
                              ),
                            ),
                            title: Text(
                              '${client.nom} ${client.prenom} ${client.contact}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16, // Taille de la police du titre
                              ),
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Flexible(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _viewClientDetails(context, client.id);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orangeAccent,
                                    ),
                                    child: Text(
                                      'Versement',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors
                                            .white, // Taille de la police du bouton
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                    width: 8.0), // Espace entre les boutons
                                Flexible(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      _goToBoutique(context, client.id);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      // Taille du bouton
                                    ),
                                    child: Text(
                                      'Commande',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors
                                            .white, // Taille de la police du bouton
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Contact: ${client.contact}',
                                      style: TextStyle(
                                        fontSize:
                                            14, // Taille de la police du sous-titre
                                      ),
                                    ),
                                    Text(
                                      'Adresse: ${client.adresse}',
                                      style: TextStyle(
                                        fontSize:
                                            14, // Taille de la police du texte
                                      ),
                                    ),
                                    Text(
                                      'Contact Proche: ${client.contact2}',
                                      style: TextStyle(
                                        fontSize:
                                            14, // Taille de la police du texte
                                      ),
                                    ),
                                    Text(
                                      'Crée le: ${client.startDate} ${client.startHeure}',
                                      style: TextStyle(
                                        fontSize:
                                            14, // Taille de la police du texte
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                  ],
                                ),
                              ),
                            ],
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

  void _goToBoutique(BuildContext context, String clientId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BoutiquePage(id: clientId),
      ),
    );
  }

  void _viewClientDetails(BuildContext context, String clientId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientDetailBoutiquePage(id: clientId),
      ),
    );
  }
}
