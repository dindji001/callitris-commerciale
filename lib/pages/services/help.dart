import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 249, 221, 175),
        title: Text('Aide'),
        actions: buildAppBarActions(context),
      ),
      body: Center(
        child: Text(
          'Page en maintenance',
          style: TextStyle(color: Colors.red, fontSize: 20),
        ),
      ),
    );
  }
}
