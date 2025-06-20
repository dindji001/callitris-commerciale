import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _loginFailed = false;
  bool _isPasswordVisible = false; // Ajoutez cette ligne

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _loginFailed = false;
      });
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final String username = _usernameController.text;
      final String password = _passwordController.text;
      try {
        final response = await http.post(
          Uri.parse(provide.getEndpoint('auth/auth.php')),
          body: jsonEncode({'password': password, 'email': username}),
          headers: {'Content-Type': 'application/json'},
        );
        //print(response.body);
        final List<dynamic> responseData = jsonDecode(response.body);
        if (response.statusCode == 200) {
          final Map<String, dynamic> responsData = responseData[0];
          final String token = responsData['token'];

          Provider.of<AuthProvider>(context, listen: false).setToken(token);
          Provider.of<AuthProvider>(context, listen: false)
              .setUser(responsData);
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            _isLoading = false;
            _loginFailed = true;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Une erreur s\'est produite. Veuillez réessayer.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text( '${error}'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
          _loginFailed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 248, 242, 227),
                  Color.fromARGB(255, 252, 229, 155)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 40.0),
                    Image.asset(
                      'assets/logo.png',
                      width: 150,
                      height: 150,
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      'Espace Commercial',
                      style: TextStyle(color: Colors.black, fontSize: 26),
                    ),
                    SizedBox(height: 40.0),
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: '  Email',
                        hintText: '  Ex : free@callistris-distribution.com',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/icons/email-2.svg',
                            width: 20.0,
                            color: Colors.blue,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: '  Mot de passe',
                        hintText: 'Entrez votre mot de passe',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SvgPicture.asset(
                            'assets/icons/lock.svg',
                            width: 20.0,
                            color: Colors.blue,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible =
                                  !_isPasswordVisible; // Inverser la visibilité du mot de passe
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      obscureText:
                          !_isPasswordVisible, // Affiche/masque le texte
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre mot de passe';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 40.0),
                    SizedBox(
                      width: double.infinity, // Bouton prend toute la largeur
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0), // Ajuster le padding
                          backgroundColor:
                              Colors.orange, // Couleur de fond du bouton
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10.0), // Bord arrondi
                          ),
                        ),
                        // Désactiver le bouton pendant le chargement
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : Text('Se connecter',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 24)),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    if (_loginFailed)
                      Text(
                        'Échec de la connexion. Veuillez vérifier vos identifiants.',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
