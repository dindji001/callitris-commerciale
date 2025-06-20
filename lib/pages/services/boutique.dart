import 'dart:convert';
import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../auth_provider.dart';
import '../clients/user_page_boutique.dart';

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
  final String cout_journal;
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

class BoutiquePage extends StatefulWidget {
  final String id;

  BoutiquePage({required this.id});

  @override
  _BoutiquePageState createState() => _BoutiquePageState();
}

class _BoutiquePageState extends State<BoutiquePage> {
  Option? selectedOption1;
  Option? selectedOption2;
  List<Option> _dureeOptions = [];
  List<Option> _livretOptions = [];
  List<Kit> kits = [];
  bool isLivretAvailable = true;

  Future<void> _fetchDureeOptions() async {
    final provide = Provider.of<AuthProvider>(context, listen: false);
    final token = provide.token;

    try {
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
      } else {
        _handleError(response);
      }
    } catch (error) {
      _handleError(error);
    }
  }

  Future<void> _fetchLivretOptions(String dureeId) async {
    final provide = Provider.of<AuthProvider>(context, listen: false);
    final token = provide.token;
    final user = provide.user;

    String localId = user!['local_id'].toString();
    print(user);
    try {
      final response = await http.get(
        Uri.parse(provide.getEndpoint(
            'products/getLivret.php?duree_id=$dureeId&local_id=$localId&personnelId=${user['id_personnel']}')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Option> options = data.map((item) {
          return Option(
              item['id_livret'].toString(), item['code_livret'].toString());
        }).toList();
        setState(() {
          _livretOptions = options;
          isLivretAvailable = _livretOptions.isNotEmpty;
        });

        if (!isLivretAvailable) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Aucun carnet lié à cette durée.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }
      } else {
        _handleError(response);
      }
    } catch (error) {
      _handleError(error);
    }
  }

  Future<void> _fetchKit(String idLivret) async {
    final provide = Provider.of<AuthProvider>(context, listen: false);
    final token = provide.token;

    try {
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
        print(responseData);
        List<Kit> fetchedKits = responseData.map((kitData) {
          return Kit(
            id: kitData['id_kit'].toString(),
            livret: kitData['livret_id'].toString(),
            option_kit: kitData['option_kit'].toString(),
            montant: kitData['montant_total_kit'].toString(),
            total_prod: kitData['total_prod_kit'].toString(),
            photo_kit: loadImg2(kitData['photo_kit'].toString()),
            cout_journal: kitData['cout_journalier_kit'].toString(),
          );
        }).toList();

        setState(() {
          kits = fetchedKits;
          print(kits);
        });
      } else {
        _handleError(response);
      }
    } catch (error) {
      _handleError(error);
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDureeOptions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Espace Boutique'),
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
          if (_livretOptions.isEmpty && !isLivretAvailable)
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
                      clientId: widget.id,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
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

  FillImageCard(
      {required this.width,
      required this.photo,
      required this.title,
      required this.kit,
      required this.clientId});

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
                backgroundColor: Color.fromARGB(
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

  ArticleDetailPage({required this.kit, required this.clientId});

  @override
  ArticleDetailPageState createState() => ArticleDetailPageState();
}

class ArticleDetailPageState extends State<ArticleDetailPage> {
  bool isSubmitting = false; // Ajoutez cette variable d'état

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
                    backgroundColor: Color.fromARGB(255, 54, 149, 244),
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
                      : Text('Valider la commande',
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      'personnelId': idPersonnel,
      'id_kit': idKit,
      'qte': 1,
    };

    try {
      final response = await http.post(
        Uri.parse(provide.getEndpoint('products/addCom.php')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
        body: jsonEncode(requestData),
      );

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
