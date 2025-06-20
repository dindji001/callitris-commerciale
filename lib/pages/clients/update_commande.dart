import 'dart:convert';
//import 'dart:ffi';
import 'package:callitris/pages/clients/user_page_boutique.dart';
import 'package:callitris/pages/menu.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../auth_provider.dart';
//import 'panier_page.dart';

class Option {
  final String id;
  final String value;

  Option(this.id, this.value);
}

class Kit {
  final String id;
  final String livret;
  final String option_kit;
  final String montant;
  final String total_prod;
  final double cout_journal;
  final String photo_kit;

  Kit({
    required this.id,
    required this.livret,
    required this.option_kit,
    required this.montant,
    required this.total_prod,
    required this.cout_journal,
    required this.photo_kit,
  });
}

class BoutiqueUpdatePage extends StatefulWidget {
  final String clientId;
  final String commandeId;
  final String code;
  final String cle;
  final String payer;

  BoutiqueUpdatePage(
      {required this.clientId,
      required this.commandeId,
      required this.cle,
      required this.code,
      required this.payer});

  @override
  _BoutiqueUpdatePageState createState() => _BoutiqueUpdatePageState();
}

class _BoutiqueUpdatePageState extends State<BoutiqueUpdatePage> {
  int totalQuantity = 0;
  bool isLivretAvailable = true;
  List<String> panierItems = [];
  Option? selectedOption1;
  Option? selectedOption2;
  List<Option> _dureeOptions = [];
  List<Option> _livretOptions = [];
  List<Kit> kits = [];

  Future<void> _fetchDureeOptions() async {
    panierItems.clear();
    final provide = Provider.of<AuthProvider>(context, listen: false);
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    final response = await http.get(
      Uri.parse(provide.getEndpoint('products/getDuree.php')),
      headers: {'Authorization': token!, 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Option> options = data.map((item) {
        return Option(
            item['id_duree'].toString(), item['nombre_mois'].toString());
      }).toList();
      setState(() {
        _dureeOptions = options;
      });
    }
  }

  Future<void> _fetchLivretOptions(String dureeId) async {
    panierItems.clear();
    final provide = Provider.of<AuthProvider>(context, listen: false);
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    String localId = user!['local_id'].toString();

    final response = await http.get(
      Uri.parse(provide.getEndpoint(
          'products/getLivret.php?duree_id=$dureeId&local_id=$localId')),
      headers: {'Authorization': token!, 'Content-Type': 'application/json'},
    );
    print(response.body);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Option> options = data.map((item) {
        return Option(
            item['id_livret'].toString(), item['code_livret'].toString());
      }).toList();
      setState(() {
        _livretOptions = options;
      });

      if (_livretOptions.isEmpty) {
        isLivretAvailable = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Aucun carnet lié à cette durée.',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      }
    }
  }

  Future<void> _fetchKit(String idLivret) async {
    try {
      panierItems.clear();
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final provide = Provider.of<AuthProvider>(context, listen: false);

      final response = await http.get(
        Uri.parse(
            provide.getEndpoint('products/getKit.php?livret_id=$idLivret')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      String loadImg2(String imagePath) {
        // Vérifie si "../../" existe dans le chemin
        if (imagePath.contains("../../")) {
          // Remplace "../../" par "app/"
          imagePath = imagePath.replaceAll("../../", "app/");
        }

        // Retourne l'URL complète
        return "https://app.callitris-distribution.com/$imagePath";
      }

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);

        List<Kit> fetchedKits = responseData.map((kitData) {
          String id_kit = kitData['id_kit'].toString();
          String livret = kitData['livret_id'].toString();
          String option_kit = kitData['option_kit'].toString();

          // Convertir les champs de montant et cout_journal en double
          double montant_kit =
              double.tryParse(kitData['montant_total_kit'].toString()) ?? 0.0;
          double cout_journal =
              double.tryParse(kitData['cout_journalier_kit'].toString()) ?? 0.0;

          String total_prod = kitData['total_prod_kit'].toString();
          //String imageUrl = kitData['photo_kit'].toString();

          String photo_kit = loadImg2(kitData['photo_kit'].toString());
          //String photo_kit ='https://app.callitris-distribution.com/${imageUrl.substring(imageUrl.indexOf('/') + 1)}';

          return Kit(
            id: id_kit,
            livret: livret,
            option_kit: option_kit,
            montant: montant_kit.toString(),
            total_prod: total_prod,
            photo_kit: photo_kit,
            cout_journal: cout_journal,
          );
        }).toList();

        setState(() {
          kits = fetchedKits;
        });
      } else {
        print('Erreur : ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération des kits: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Modification ${widget.code}'),
          backgroundColor: Color.fromARGB(255, 249, 221, 175),
          actions: buildAppBarActions(context),
        ),
        body: Column(
          children: [
            _buildDropDownField(
              'Durée *',
              _dureeOptions,
              selectedOption1,
              (Option? value) {
                setState(() {
                  selectedOption1 = value;
                  selectedOption2 = null;
                });
                if (value != null) {
                  _fetchLivretOptions(value.id);
                }
              },
            ),
            SizedBox(height: 10),
            if (selectedOption1 == null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Veuillez sélectionner la durée du livret pour passer à l\'étape suivante.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (selectedOption1 != null && _livretOptions.isNotEmpty)
              Column(
                children: [
                  // Je vérifi si les livrets sont disponibles
                  _buildDropDownField(
                    'Numéro du livret *',
                    _livretOptions,
                    selectedOption2,
                    (Option? value) {
                      setState(() {
                        selectedOption2 = value;
                      });
                      if (value != null) {
                        _fetchKit(value.id);
                        isLivretAvailable == true;
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  if (selectedOption2 == null)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Veuillez sélectionner le numéro du livret pour afficher tous les kits qui y sont.',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            if (_livretOptions.isEmpty && isLivretAvailable == false)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Aucun carnet lié à cette durée.',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (selectedOption1 != null && selectedOption2 != null)
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: kits.length,
                  itemBuilder: (context, index) {
                    final kit = kits[index];
                    return AspectRatio(
                      aspectRatio: 0.7,
                      child: FillImageCard(
                        width: 200,
                        title: '${kit.option_kit} => ${kit.cout_journal} f / j',
                        photo: kit.photo_kit,
                        kit: kit,
                        clientId: widget.clientId,
                        cleHold: widget.cle,
                        payerHold: widget.payer,
                      ),
                    );
                  },
                ),
              ),
          ],
        ));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDureeOptions();
    });
  }

  Widget _buildDropDownField(String labelText, List<Option> options,
      Option? selectedValue, Function(Option?) onChanged) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<Option>(
        value: selectedValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(),
        ),
        items: options.map((Option option) {
          return DropdownMenuItem<Option>(
            value: option,
            child: Text(option.value),
          );
        }).toList(),
      ),
    );
  }
}

class FillImageCard extends StatelessWidget {
  final double width;
  final String photo;
  final String title;
  final Kit kit;
  final String clientId;
  final String cleHold;
  final String payerHold;

  FillImageCard(
      {required this.width,
      required this.photo,
      required this.title,
      required this.kit,
      required this.clientId,
      required this.cleHold,
      required this.payerHold});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
              color: Color.fromARGB(255, 54, 149, 244),
              width: 2), // Ajout de la couleur de la bordure
        ),
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                child: CachedNetworkImage(
                  imageUrl: photo,
                  placeholder: (context, url) => Container(
                    width: 50,
                    height: 50,
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 5,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                iconColor: Color.fromARGB(
                    255, 54, 149, 244), // Changer la couleur du bouton
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ArticleDetailPage(
                      kit: kit,
                      clientId: clientId,
                      cleHold: cleHold,
                      payerHold: payerHold,
                    ),
                  ),
                );
              },
              child: Text(
                'Commander',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class ArticleDetailPage extends StatefulWidget {
  final Kit kit;
  final String clientId;
  final String cleHold;
  final String payerHold;

  ArticleDetailPage(
      {required this.kit,
      required this.clientId,
      required this.cleHold,
      required this.payerHold});

  @override
  ArticleDetailPageState createState() => ArticleDetailPageState();
}

class ArticleDetailPageState extends State<ArticleDetailPage> {
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la Commande'),
        backgroundColor: Color.fromARGB(255, 54, 149, 244),
        actions: buildAppBarActions(context),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.kit.option_kit,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: CachedNetworkImage(
                        imageUrl: widget.kit.photo_kit,
                        placeholder: (context, url) => Center(
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nombre Jour Payé en Avance : ${_calculatePayerNew()}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text('Montant: ${widget.kit.montant} f'),
                    Text('Cout Journalier: ${widget.kit.cout_journal} f'),
                    Text('Total Produits: ${widget.kit.total_prod}'),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    iconColor: Color.fromARGB(255, 54, 149, 244),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () {
                          _checkout(widget.kit.id);
                        },
                  child: isSubmitting
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text('Procéder au paiement',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculatePayerNew() {
    double jourP =
        widget.kit.cout_journal; // Assurez-vous que c'est déjà un double
    double nap = double.parse(widget.payerHold) * 65;
    int nbrj = nap ~/ jourP;
    return nbrj;
  }

  void _checkout(String idKit) async {
    setState(() {
      isSubmitting = true; // Définir isSubmitting sur true avant la soumission
    });

    final provide = Provider.of<AuthProvider>(context, listen: false);
    final token = provide.token;
    final user = provide.user;
    String idPersonnel = user!['id_personnel'].toString();

    final requestData = {
      'clientId': widget.clientId,
      'cleHold': widget.cleHold,
      'personnelId': idPersonnel,
      'id_kit': idKit,
      'qte': 1,
    };

    try {
      final response = await http.post(
        Uri.parse(provide.getEndpoint('products/updateCommande.php')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );
      print(response.body);

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (_) => SuccessDialog(),
        ).then((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ClientDetailBoutiquePage(id: widget.clientId)),
          );
        });
      } else {
        _handleError(response);
      }
    } catch (error) {
      _handleError(error);
    } finally {
      setState(() {
        isSubmitting = false; // Réinitialiser isSubmitting après la soumission
      });
    }
  }

  void _handleError(dynamic error) {
    print('Erreur : $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Une erreur est survenue.'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class SuccessDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48.0,
          ),
          SizedBox(height: 16.0),
          Text(
            'Commande passée avec succès!',
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
  }
}
