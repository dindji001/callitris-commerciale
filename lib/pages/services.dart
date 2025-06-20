import 'package:flutter/material.dart';
import 'package:callitris/pages/app_bar_navigation.dart';
import 'package:flutter_svg/svg.dart';

class ServicesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MyAppBarNavigation(
      currentIndex: 2,
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/client');
            break;
          case 3:
            Navigator.pushNamed(context, '/profile');
            break;
        }
      },
      body: Scaffold(
        body: GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(10),
          mainAxisSpacing: 30,
          crossAxisSpacing: 20,
          children: [
            buildServiceItem(
              context,
              'Boutique',
              'assets/icons/cart-minus.svg',
              Colors.orange,
              '/client_boutique',
            ),
            buildServiceItem(
              context,
              'Tontine',
              'assets/icons/wallet.svg',
              Colors.green,
              '/client_tontine',
            ),
            buildServiceItem(
              context,
              'Livraison',
              'assets/icons/truck-check.svg',
              Colors.blue,
              '/livraison',
            ),
            buildServiceItem(
              context,
              'Encaissement',
              'assets/icons/sack.svg',
              Colors.red,
              '/versement',
            ),
            buildServiceItem(
              context,
              'Banque',
              'assets/icons/banque.svg',
              Colors.pink,
              '/banque',
            ),
            buildServiceItem(
              context,
              'Client à 80%',
              'assets/icons/review.svg',
              Colors.purple,
              '/client_as',
            )
          ],
        ),
      ),
    );
  }

  GestureDetector buildServiceItem(BuildContext context, String title,
      String iconPath, Color color, String routeName) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, routeName);
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: color,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              iconPath,
              color: color,
              width: 60,
              height: 60,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
