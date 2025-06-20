import 'package:callitris/pages/auth_provider.dart';
import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SalairePage extends StatefulWidget {
  @override
  _SalairePageState createState() => _SalairePageState();
}

class Salaire {
  final String boutique;
  final String tontine;
  final String brut;
  final String total;

  Salaire({
    required this.boutique,
    required this.tontine,
    required this.brut,
    required this.total,
  });
}

class _SalairePageState extends State<SalairePage> {
  Salaire? salaires;

  @override
  void initState() {
    super.initState();
    fetchSalaires();
  }

  Future<void> fetchSalaires() async {
    try {
      final provide = Provider.of<AuthProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      final token = Provider.of<AuthProvider>(context, listen: false).token;

      String idPersonnel = user!['id_personnel'].toString();

      final response = await http.get(
        Uri.parse(provide
            .getEndpoint('/products/getSalaire.php?personnel_id=$idPersonnel')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      //print(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> salaireData = jsonDecode(response.body);

        String boutique = salaireData['boutique'].toString();
        String tontine = salaireData['tontine'].toString();
        String brut = salaireData['brut'].toString();
        String total = salaireData['total'].toString();

        setState(() {
          salaires = Salaire(
            boutique: boutique,
            tontine: tontine,
            brut: brut,
            total: total,
          );
        });
      } else {
        print('Erreur : ${response.statusCode}');
      }
    } catch (error) {
      print('Erreur lors de la récupération des salaires: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 249, 221, 175),
        title: Text('Bilan du Salaire'),
        actions: buildAppBarActions(context),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SalaryCard(
                    title: 'Boutique',
                    amount: '${salaires?.boutique}',
                    icon: Icons.shopping_bag,
                    gradient: [Colors.blue.shade400, Colors.blue.shade700],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: SalaryCard(
                    title: 'Tontine',
                    amount: '${salaires?.tontine}',
                    icon: Icons.account_balance_wallet,
                    gradient: [Colors.green.shade400, Colors.green.shade700],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SalaryCard(
                    title: 'Salaire Brut',
                    amount: '${salaires?.brut}',
                    icon: Icons.attach_money,
                    gradient: [Colors.orange.shade400, Colors.orange.shade700],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: SalaryCard(
                    title: 'Salaire Net',
                    amount: '${salaires?.total}',
                    icon: Icons.credit_card,
                    gradient: [Colors.purple.shade400, Colors.purple.shade700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SalaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final List<Color> gradient;

  const SalaryCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5),
            Text(
              amount,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 2,
                    color: Colors.black,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
