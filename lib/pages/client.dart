import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'app_bar_navigation.dart';
import 'auth_provider.dart';
import 'package:flutter_svg/svg.dart';
// import 'package:skeletonizer/skeletonizer.dart'; // Supprimé

class ClientPage extends StatefulWidget {
  @override
  _ClientPageState createState() => _ClientPageState();
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
  final String? tontine;
  final String? boutique;

  Client({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.startDate,
    required this.startHeure,
    required this.contact,
    required this.contact2,
    required this.adresse,
    required this.tontine,
    required this.boutique,
  });
}

class _ClientPageState extends State<ClientPage> {
  String searchText = '';
  bool _isLoading = true;
  List<Client> clients = [];

  @override
  void initState() {
    super.initState();
    fetchClients();
  }

  Future<void> _registerClientCompte(String clientId, int typeCompte) async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      final Map<String, dynamic> requestBody = {
        'typeCompte': typeCompte,
        'clientId': clientId,
      };

      final response = await http.post(
        Uri.parse(provide.getEndpoint('client/addCompte.php')),
        body: json.encode(requestBody),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'],
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushNamed(context, '/client');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'],
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Une erreur est survenue lors de l\'enregistrement.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchClients() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      String idPersonnel = user!['id_personnel'].toString();

      final response = await http.get(
        Uri.parse(provide
            .getEndpoint('client/getClient.php?id_personnel=$idPersonnel')),
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
          String tontine = clientData['tontine'].toString();
          String boutique = clientData['boutique'].toString();

          return Client(
            id: id,
            nom: nom,
            prenom: prenom,
            startDate: startDate,
            startHeure: startHeure,
            contact: contact,
            contact2: contact2,
            adresse: adresse,
            tontine: tontine,
            boutique: boutique,
          );
        }).toList();

        setState(() {
          clients = fetchedClients;
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
      print('Erreur lors de la récupération des clients: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
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
    return MyAppBarNavigation(
        currentIndex: 1,
        onDestinationSelected: (int index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 2:
              Navigator.pushNamed(context, '/services');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        body: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mes Clients (${displayedClients.length})',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/add_client');
                      },
                      icon: Icon(Icons.person_2),
                      label: Text('Nouveau Client'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Couleur du bouton
                        foregroundColor: Colors.white, // Couleur du texte
                        minimumSize: Size(150, 40), // Taille du bouton
                      ),
                    ),
                  ],
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
                      fontSize: 18,
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
                          // Remplacer Skeletonizer par un widget de chargement simple
                          return Padding(
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
                                    fontSize:
                                        16, // Taille de la police du titre
                                  ),
                                ),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Flexible(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          _makeBoutique(context, client.id);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              client.boutique == '1'
                                                  ? Colors.green
                                                  : Colors.red,
                                          // Taille du bouton
                                        ),
                                        child: Text(
                                          'Boutique',
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
                                          _makeTontine(context, client.id);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: client.tontine == '1'
                                              ? Colors.green
                                              : Colors.red,
                                          minimumSize:
                                              Size(100, 40), // Taille du bouton
                                        ),
                                        child: Text(
                                          'Tontine',
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
        ));
  }

  void _makeTontine(BuildContext context, String clientId) {
    Client? client = clients.firstWhere((client) => client.id == clientId);

    if (client.tontine == '1') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le client ${client.nom} a déjà un compte tontine.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      _registerClientCompte(clientId, 2);
    }
  }

  void _makeBoutique(BuildContext context, String clientId) {
    Client? client = clients.firstWhere((client) => client.id == clientId);

    if (client.boutique == '1') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le client ${client.nom} a déjà un compte boutique.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      _registerClientCompte(clientId, 1);
    }
  }
}
