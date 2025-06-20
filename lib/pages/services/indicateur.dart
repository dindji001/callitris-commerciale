import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:callitris/pages/auth_provider.dart';

class IndicateurPage extends StatefulWidget {
  @override
  _IndicateurPageState createState() => _IndicateurPageState();
}

class Commande {
  final String nomClient;
  final String prenomClient;
  final String telephoneClient;
  final String nap;
  final String payer;
  final String journalier;
  final String reste;
  final String nbjr;
  final String lastDateAdd;
  final String nomPers;
  final String prenomPers;
  final String dateDebutCotisation;
  final String nombreJour;
  final String indicateur;

  Commande({
    required this.nomClient,
    required this.prenomClient,
    required this.telephoneClient,
    required this.nap,
    required this.payer,
    required this.journalier,
    required this.reste,
    required this.nbjr,
    required this.lastDateAdd,
    required this.nomPers,
    required this.prenomPers,
    required this.dateDebutCotisation,
    required this.nombreJour,
    required this.indicateur,
  });

  factory Commande.fromJson(Map<String, dynamic> json) {
    return Commande(
      nomClient: json['nom_client'],
      prenomClient: json['prenom_client'],
      telephoneClient: json['telephone_client'],
      nap: json['nap'],
      payer: json['payer'],
      journalier: json['journalier'],
      reste: json['reste'],
      nbjr: json['nbjr'],
      lastDateAdd: json['last_date_add'],
      nomPers: json['nom_pers'],
      prenomPers: json['prenom_pers'],
      dateDebutCotisation: json['date_debut_cotisation'],
      nombreJour: json['nombre_jour'],
      indicateur: json['indicateur'],
    );
  }
}

class _IndicateurPageState extends State<IndicateurPage> {
  List<Commande> commandes = [];

  @override
  void initState() {
    super.initState();
    fetchCommandes();
  }

  Future<void> fetchCommandes() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      String idPersonnel = user!['id_personnel'].toString();

      final response = await http.get(
        Uri.parse(provide.getEndpoint(
            'products/getIndicateur.php?personnel_id=$idPersonnel')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      //print(response.body);
      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          commandes =
              responseData.map((data) => Commande.fromJson(data)).toList();
        });
      } else {
        print('Erreur : ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération des commandes: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 249, 221, 175),
          title: Text('Mes Indicateurs'),
          actions: buildAppBarActions(context),
        ),
        body: ListView.builder(
          itemCount: commandes.length,
          itemBuilder: (context, index) {
            final commande = commandes[index];
            return Card(
              color: _getCardColor(commande.indicateur),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5,
              margin: EdgeInsets.all(10),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${commande.nomClient} ${commande.prenomClient}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          commande.indicateur == 'actif'
                              ? Icons.check_circle
                              : Icons.info,
                          color: commande.indicateur == 'actif'
                              ? Colors.green
                              : Colors.red,
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Divider(),
                    Text(
                      'Téléphone: ${commande.telephoneClient}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'NAP: ${commande.nap}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'Payé: ${commande.payer}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'Journalier: ${commande.journalier}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'Reste: ${commande.reste}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      'Nb Jour: ${commande.nbjr}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Dernière date ajout: ${commande.lastDateAdd}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Début cotisation: ${commande.dateDebutCotisation}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Nom personnel: ${commande.nomPers}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Prénom personnel: ${commande.prenomPers}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Nombre de jours: ${commande.nombreJour}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Indicateur: ${commande.indicateur}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: commande.indicateur == 'actif'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // Action à effectuer lors de l'appui sur le bouton
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: commande.indicateur == 'actif'
                                ? Colors.green
                                : Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          child: Text(
                            commande.indicateur == 'actif'
                                ? 'Actif'
                                : 'Inactif',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }

  Color _getCardColor(String indicateur) {
    switch (indicateur) {
      case 'actif':
        return Color.fromARGB(255, 196, 246, 198);
      case 'passif':
        return Color.fromARGB(255, 250, 206, 141);
      case 'inactif':
        return const Color.fromARGB(255, 250, 215, 212);
      default:
        return Colors.white;
    }
  }
}
