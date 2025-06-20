import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:callitris/pages/auth_provider.dart';

class VersementPage extends StatefulWidget {
  @override
  _VersementPageState createState() => _VersementPageState();
}

class _VersementPageState extends State<VersementPage> {
  List<PaymentInfo> _payments = [];
  List<PaymentInfo> _filteredPayments = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    fetchPayments();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredPayments = _payments.where((payment) {
        final searchValue = _searchController.text.toLowerCase();
        return payment.amount.toString().contains(searchValue) ||
            payment.date.toString().contains(searchValue) ||
            payment.pack.toString().contains(searchValue) ||
            payment.carnet.toString().contains(searchValue) ||
            payment.journalier.toString().contains(searchValue) ||
            payment.libelle!.toLowerCase().contains(searchValue);
      }).toList();
    });
  }

  void _filterByDate(DateTime date) {
    setState(() {
      _filteredPayments = _payments.where((payment) {
        return payment.date == date.toString().substring(0, 10);
      }).toList();
    });
  }

  Future<void> fetchPayments() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final provide = Provider.of<AuthProvider>(context, listen: false);
      final token = provide.token;
      final user = provide.user;

      final response = await http.get(
        Uri.parse(provide.getEndpoint(
            'products/getVersement.php?personnel_id=${user?['id_personnel']}')),
        headers: {'Authorization': token!, 'Content-Type': 'application/json'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        List<PaymentInfo> payments = [];

        for (var paymentData in responseData) {
          PaymentInfo payment = PaymentInfo.fromMap(paymentData);
          //print(payment);
          payments.add(payment);
        }

        setState(() {
          _payments = payments;
          _filteredPayments = List.from(_payments);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      locale: const Locale('fr', 'FR'),
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
        _filterByDate(picked);
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi des Encaissements'),
        backgroundColor: Color.fromARGB(255, 249, 221, 175),
        actions: buildAppBarActions(context),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            labelText: 'Rechercher compte, montant, etc.',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.date_range),
                        onPressed: () => _selectDate(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: buildPaymentList(_filteredPayments),
                ),
              ],
            ),
    );
  }

  Widget buildPaymentList(List<PaymentInfo> payments) {
    return ListView.builder(
      itemCount: payments.length,
      itemBuilder: (context, index) {
        return buildPaymentCard(payments[index]);
      },
    );
  }

  Widget buildPaymentCard(PaymentInfo payment) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Encaissement : ${payment.nomCompte}',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SvgPicture.asset(
                  'assets/icons/sack.svg',
                  color: Colors.blue,
                  height: 40,
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Divider(color: Colors.black),
            SizedBox(height: 8.0),
            Text(
              'Nom : ${payment.client} ',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            SizedBox(height: 8.0),
            Text(
              'Contact : ${payment.contact_client} ',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            SizedBox(height: 8.0),
            if (payment.nomCompte == 'BOUTIQUE') ...[
              SizedBox(height: 8.0),
              Text(
                'N° Pack: ${payment.pack ?? 'N/A'}',
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
              SizedBox(height: 8.0),
              Text(
                'Carnet: ${payment.carnet ?? 'N/A'}',
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
              SizedBox(height: 8.0),
              Text(
                'Journalier: ${payment.journalier}',
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ],
            if (payment.nomCompte == 'TONTINE') ...[
              SizedBox(height: 8.0),
              Text(
                'Journalier: ${payment.journalier}',
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
              SizedBox(height: 8.0),
              Text(
                'Libellé du compte: ${payment.libelle}',
                style: TextStyle(fontSize: 16.0, color: Colors.black),
              ),
            ],
            SizedBox(height: 8.0),
            Text(
              'Montant : ${payment.amount} ',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
            SizedBox(height: 8.0),
            Text(
              'Date: ${payment.date} ',
              style: TextStyle(fontSize: 16.0, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentInfo {
  final double amount;
  final String date;
  final String nomCompte;
  final String? pack;
  final String? carnet;
  final String? journalier;
  final String? libelle;
  final String? client;
  final String? contact_client;

  PaymentInfo(
    this.amount,
    this.date,
    this.nomCompte,
    this.pack,
    this.carnet,
    this.journalier,
    this.libelle,
    this.client,
    this.contact_client,
  );

  factory PaymentInfo.fromMap(Map<String, dynamic> map) {
    return PaymentInfo(
      double.parse(map['montant'].toString()),
      map['date'].toString(),
      map['compte'].toString(),
      map['pack']?.toString(),
      map['carnet']?.toString(),
      map['journalier']?.toString(),
      map['libelle']?.toString(),
      map['client']?.toString(),
      map['contact_client']?.toString(),
    );
  }
}
