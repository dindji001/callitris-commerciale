import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:callitris/pages/auth_provider.dart';
import 'package:callitris/pages/app_bar_navigation.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key});

  @override
  Widget build(BuildContext context) {
    final userDetail = Provider.of<AuthProvider>(context, listen: false).user;
    return MyAppBarNavigation(
      currentIndex: 3,
      onDestinationSelected: (int index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            Navigator.pushNamed(context, '/client');
            break;
          case 2:
            Navigator.pushNamed(context, '/services');
            break;
          case 3:
            break;
        }
      },
      body: Scaffold(
        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/profile.svg',
                    color: Colors.blue,
                    height: 40,
                  ),
                  SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${userDetail?['nom_pers']} ${userDetail?['prenom_pers']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '${userDetail?['email_pers']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Membre depuis ${userDetail?['date_ajout']}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            buildListTile(
              context,
              'Indicateurs',
              'assets/icons/perf.svg',
              Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/indicateur');
              },
            ),
            buildListTile(
              context,
              'Sécurité',
              'assets/icons/user-lock.svg',
              Colors.orange,
              onTap: () {
                _showChangePasswordBottomSheet(context);
              },
            ),
            buildListTile(
              context,
              'Se déconnecter',
              'assets/icons/exit.svg',
              Colors.red,
              onTap: () {
                _confirmLogout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  ListTile buildListTile(
      BuildContext context, String title, String iconPath, Color color,
      {required void Function() onTap}) {
    return ListTile(
      leading: SvgPicture.asset(
        iconPath,
        color: color,
      ),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _showChangePasswordBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Pour afficher la feuille en plein écran
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Modifier le mot de passe',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Ancien mot de passe',
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                  ),
                ),
                SizedBox(height: 10),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le nouveau mot de passe',
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Fermer la feuille modale
                      },
                      child: Text('Annuler'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Ajoutez ici la logique pour modifier le mot de passe
                        Navigator.of(context).pop(); // Fermer la feuille modale
                      },
                      child: Text('Enregistrer'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                // Déconnectez l'utilisateur
                Provider.of<AuthProvider>(context, listen: false).logout();
                // Naviguer vers la page de connexion ou la page d'accueil
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }
}
