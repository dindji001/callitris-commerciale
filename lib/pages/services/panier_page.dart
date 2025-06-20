//import 'dart:convert';
//import 'package:http/http.dart' as http;
import 'package:callitris/pages/menu.dart';
import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import '../auth_provider.dart';
import 'boutique.dart';

class PanierPage extends StatefulWidget {
  final List<String> panierItems;
  final List<Kit> kits;

  PanierPage({Key? key, required this.panierItems, required this.kits})
      : super(key: key);

  @override
  _PanierPageState createState() => _PanierPageState();
}

class _PanierPageState extends State<PanierPage> {
  List<PanierItem> _panierItems = [];

  @override
  void initState() {
    super.initState();
    _loadPanierItems();
  }

  void _loadPanierItems() {
    for (String id in widget.panierItems) {
      // Trouver le kit correspondant à l'ID dans la liste de kits
      Kit? kit;
      for (Kit item in widget.kits) {
        if (item.id == id) {
          kit = item;
          break;
        }
      }
      if (kit != null) {
        _panierItems.add(
          PanierItem(
            name: kit.option_kit,
            price: double.parse(kit.montant),
            quantity: 1,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panier'),
        actions: buildAppBarActions(context),
      ),
      body: _panierItems.isNotEmpty
          ? ListView.builder(
              itemCount: _panierItems.length,
              itemBuilder: (context, index) {
                final panierItem = _panierItems[index];
                return ListTile(
                  title: Text(panierItem.name),
                  subtitle: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (panierItem.quantity > 1) {
                              panierItem.quantity--;
                            }
                          });
                        },
                      ),
                      Text('${panierItem.quantity}'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            panierItem.quantity++;
                          });
                        },
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _panierItems.removeAt(index);
                      });
                    },
                  ),
                );
              },
            )
          : Center(
              child: Text('Le panier est vide.'),
            ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Total: ${_calculateTotal()}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {
                  // Ajoutez ici la logique pour finaliser l'achat
                  _checkout();
                },
                child: Text('Passer la commande'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _checkout() {
    // Ajoutez ici la logique pour finaliser l'achat
    // Par exemple, naviguez vers une page de paiement
  }

  double _calculateTotal() {
    double total = 0;
    for (var item in _panierItems) {
      total += item.price * item.quantity;
    }
    return total;
  }
}

class PanierItem {
  final String name;
  final double price;
  int quantity;

  PanierItem({
    required this.name,
    required this.price,
    this.quantity = 1,
  });
}
