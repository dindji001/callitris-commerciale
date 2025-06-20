import 'package:flutter/material.dart';
import 'package:callitris/pages/login.dart';

class LogoAnimationPage extends StatefulWidget {
  const LogoAnimationPage({super.key});

  @override
  _LogoAnimationPageState createState() => _LogoAnimationPageState();
}

class _LogoAnimationPageState extends State<LogoAnimationPage> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    // Ajoutez un délai pour déclencher l'animation après un certain temps
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _opacity = 1.0;
      });
      // Redirigez l'utilisateur vers la page de connexion après l'animation
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => LoginPage(),
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(seconds: 1),
          child: Container(
            width: 200,
            height: 200,
            child: Image.asset('assets/logo.jpeg'),
          ),
        ),
      ),
    );
  }
}
