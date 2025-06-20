import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';

class TontinePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tontine - Page de Collecte'),
        actions: buildAppBarActions(context),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Entrez le montant à collecter :',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 10.0),
            TextFormField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Montant (FCFA)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                // Logique pour collecter le montant
                // Cette fonction sera appelée lorsque le bouton est pressé
              },
              child: Text('Collecter'),
            ),
          ],
        ),
      ),
    );
  }
}
