import 'dart:convert';
import 'package:callitris/pages/auth_provider.dart';
import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class NewClientRegisterPage extends StatefulWidget {
  const NewClientRegisterPage({Key? key}) : super(key: key);

  @override
  _NewClientRegisterPageState createState() => _NewClientRegisterPageState();
}

class Option {
  final String id;
  final String value;

  Option(this.id, this.value);
}

class _NewClientRegisterPageState extends State<NewClientRegisterPage> {
  Option? _selectedGender;
  Option? _selectedAccountType;
  Option? _selectedZoneType;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _phoneController1 = TextEditingController();
  final TextEditingController _phoneController2 = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _functionController = TextEditingController();

  final List<Option> _genderOptions = [
    Option('F', 'Femme'),
    Option('H', 'Homme')
  ];
  List<Option> _zoneOptions = [];
  List<Option> _accountTypeOptions = [];

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enregistrement Client'),
        backgroundColor: Color.fromARGB(255, 249, 221, 175),
        actions: buildAppBarActions(context),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextFieldWithIcon(
              labelText: 'Nom du Client *',
              controller: _nameController,
              svgPath: 'assets/icons/profile.svg',
            ),
            _buildTextFieldWithIcon(
              labelText: 'Prénoms *',
              controller: _surnameController,
              svgPath: 'assets/icons/profile.svg',
            ),
            _buildDropDownField(
              'Genre *',
              _genderOptions,
              _selectedGender,
              (Option? value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              'assets/icons/venus.svg',
            ),
            _buildTextFieldNumWithIcon(
              labelText: 'Téléphone principal *',
              controller: _phoneController1,
              svgPath: 'assets/icons/phone.svg',
            ),
            _buildTextFieldNumWithIcon(
              labelText: 'Téléphone d\'un proche',
              controller: _phoneController2,
              svgPath: 'assets/icons/phone.svg',
            ),
            _buildTextFieldWithIcon(
              labelText: 'Quartier *',
              controller: _addressController,
              svgPath: 'assets/icons/house.svg',
            ),
            _buildTextFieldWithIcon(
              labelText: 'Fonction *',
              controller: _functionController,
              svgPath: 'assets/icons/tool.svg',
            ),
            _buildDropDownField(
              'Choix de Zone *',
              _zoneOptions,
              _selectedZoneType,
              (Option? value) {
                setState(() {
                  _selectedZoneType = value;
                });
              },
              'assets/icons/region.svg',
            ),
            _buildDropDownField(
              'Type de Compte *',
              _accountTypeOptions,
              _selectedAccountType,
              (Option? value) {
                setState(() {
                  _selectedAccountType = value;
                });
              },
              'assets/icons/supplier.svg',
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _registerClient,
              child: _isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Enregistrer',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldWithIcon({
    required String labelText,
    required TextEditingController controller,
    required String svgPath,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              svgPath,
              width: 24,
              height: 24,
              color: Colors.blue,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldNumWithIcon({
    required String labelText,
    required TextEditingController controller,
    required String svgPath,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              svgPath,
              width: 24,
              height: 24,
              color: Colors.blue,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchZoneOptions();
      _fetchAccountTypeOptions();
    });
  }

  Widget _buildDropDownField(String labelText, List<Option> options,
      Option? selectedValue, Function(Option?) onChanged, String svgPath) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<Option>(
        value: selectedValue,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.blue),
          ),
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.0),
            child: SvgPicture.asset(
              svgPath,
              width: 24,
              height: 24,
              color: Colors.blue,
            ),
          ),
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

  Future<void> _fetchAccountTypeOptions() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final provide = Provider.of<AuthProvider>(context, listen: false);

    final response = await http.get(
      Uri.parse(provide.getEndpoint('client/getCompte.php')),
      headers: {'Authorization': token!, 'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Option> options = data.map((item) {
        return Option(item['id_type_compte'].toString(),
            item['nom_type_compte'].toString());
      }).toList();
      setState(() {
        _accountTypeOptions = options;
      });
    }
  }

  Future<void> _fetchZoneOptions() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final provide = Provider.of<AuthProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user;

    final response = await http.get(
      Uri.parse(provide
          .getEndpoint('client/getZone.php?local_id=${user!['local_id']}')),
      headers: {'Authorization': token!, 'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      final List<Option> zones = data.map((item) {
        return Option(item['id_zone'].toString(), item['nom_zone'].toString());
      }).toList();
      setState(() {
        _zoneOptions = zones;
      });
    }
  }

  Future<void> _registerClient() async {
    setState(() {
      _isSubmitting = true;
    });
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      String personnel_id = user!['id_personnel'].toString();
      String local_id = user['local_id'].toString();
      //print('nom : ${_nameController.text}');
      if (_nameController.text.isEmpty ||
          _surnameController.text.isEmpty ||
          _selectedGender == null ||
          _phoneController1.text.isEmpty ||
          _addressController.text.isEmpty ||
          _functionController.text.isEmpty ||
          _selectedAccountType == null ||
          _selectedZoneType == null) {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 48.0,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Veuillez remplir tous les champs avec (*).',
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
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Veuillez remplir tous les champs avec (*).',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final Map<String, dynamic> requestBody = {
        'personnel_id': personnel_id,
        'local_id': local_id,
        'nom_client': _nameController.text,
        'prenom_client': _surnameController.text,
        'sexe_client': _selectedGender!.id,
        'telephone_client': _phoneController1.text,
        'telephone2_client': _phoneController2.text,
        'domicile_client': _addressController.text,
        'fonction_client': _functionController.text,
        'type_compte_id': _selectedAccountType!.id,
        'zone_id': _selectedZoneType!.id,
      };

      final response = await http.post(
        Uri.parse(provide.getEndpoint('client/addClient.php')),
        body: json.encode(requestBody),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      print('reponse :  ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
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
              content: Text(
                responseData['message'],
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushNamed(context, '/client');
        }
      } else {
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 48.0,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Erreur lors de l\'enregistrement.',
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
          },
        );

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
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}
