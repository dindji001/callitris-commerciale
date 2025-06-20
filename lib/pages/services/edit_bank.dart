import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class EditBankPage extends StatefulWidget {
  @override
  _EditBankPageState createState() => _EditBankPageState();
}

class _EditBankPageState extends State<EditBankPage> {
  XFile? _selectedImage;
  TextEditingController _libelleController = TextEditingController();
  TextEditingController _montantController = TextEditingController();
  bool _isSubmitting = false; // Variable pour suivre l'état de soumission

  String formattedDate = '';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) {
      DateTime now = DateTime.now();
      _libelleController.text =
          DateFormat('EEEE d MMMM y', 'fr_FR').format(now).toUpperCase();
      setState(() {});
    });
  }

  Future<void> _sendVersementToBank(int montant) async {
    if (_isSubmitting) return; // Empêche la soumission si déjà en cours

    setState(() {
      _isSubmitting = true; // Désactiver le bouton
    });

    try {
      if (_libelleController.text.isEmpty || _montantController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez remplir tous les champs avec (*).'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final libelle = _libelleController.text;

      final provide = Provider.of<AuthProvider>(context, listen: false);
      final user = provide.user;
      final token = provide.token;
      String personnelId = user!['id_personnel'].toString();
      if (_selectedImage != null) {
        List<int> imageBytes = await _selectedImage!.readAsBytes();
        String imageData = base64Encode(imageBytes);

        final response = await http.post(
          Uri.parse(provide.getEndpoint('products/addVersBanque.php')),
          body: jsonEncode({
            'personnelId': personnelId,
            'libelle': libelle,
            'montant': montant,
            'image': imageData,
          }),
          headers: {
            'Authorization': '$token',
            'Content-Type': 'application/json',
          },
        );
        print(response.body);
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Enregistrement réussi.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/banque');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Erreur lors de l\'enregistrement.',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Veuillez prendre une photo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Une erreur s\'est produite. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false; // Réactiver le bouton
      });
    }
  }

  final NumberFormat _numberFormat = NumberFormat("#,###", "fr_FR");

  String _formatNumber(String s) {
    // Remplace les points par des espaces avant de formater
    return _numberFormat.format(int.parse(
        s.replaceAll('.', '').replaceAll(' ', '').replaceAll('\u202F', '')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Versement - Banque'),
        backgroundColor: Color.fromARGB(255, 249, 221, 175),
        actions: buildAppBarActions(context),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Entrez les détails du versement :',
                style: TextStyle(fontSize: 18.0),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _libelleController,
                keyboardType: TextInputType.text,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Libellé',
                  prefixIcon: Icon(Icons.edit),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              TextFormField(
                controller: _montantController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction(
                    (oldValue, newValue) {
                      String newText = _formatNumber(newValue.text);
                      return TextEditingValue(
                        text: newText,
                        selection:
                            TextSelection.collapsed(offset: newText.length),
                      );
                    },
                  ),
                ],
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    try {
                      String amount = _montantController.text
                          .replaceAll('.', '')
                          .replaceAll(' ', '')
                          .replaceAll('\u202F', '');
                      var montant = int.parse(amount);
                      print('vaaleur : $montant');
                    } catch (e) {
                      print(
                          'Erreur lors de la conversion de la valeur saisie en double: $e');
                    }
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Montant (FCFA)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              TextButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                      await picker.pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    setState(() {
                      _selectedImage = pickedFile;
                    });
                  }
                },
                icon: Icon(Icons.camera_alt),
                label: Text('Prendre une photo'),
                style: TextButton.styleFrom(
                  iconColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              if (_selectedImage != null)
                Text(
                  'Image sélectionnée : ${_selectedImage!.name}',
                  style: TextStyle(fontSize: 16.0, color: Colors.green),
                ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        if (!_isSubmitting) {
                          try {
                            String amount = _montantController.text
                                .replaceAll('.', '')
                                .replaceAll(' ', '')
                                .replaceAll('\u202F', '');
                            int montant =
                                int.parse(amount); // Conversion en entier
                            _sendVersementToBank(montant); // Envoi du montant
                          } catch (e) {
                            print(
                                'Erreur lors de la conversion du montant : $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Montant invalide.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: _isSubmitting
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        'Enregistrer le versement',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSubmitting ? Colors.grey : Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
