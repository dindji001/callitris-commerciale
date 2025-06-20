import 'package:flutter/material.dart';

List<Widget> buildAppBarActions(BuildContext context) {
  return [
    PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'Accueil') {
          Navigator.pushNamed(context, '/home');
        } else if (value == 'Clients') {
          Navigator.pushNamed(context, '/client');
        } else if (value == 'Services') {
          Navigator.pushNamed(context, '/services');
        } else if (value == 'Profiles') {
          Navigator.pushNamed(context, '/profile');
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem(
            value: 'Accueil',
            child: ListTile(
              leading: Icon(Icons.home, color: Colors.blue),
              title: Text(
                'Accueil',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          PopupMenuItem(
            value: 'Clients',
            child: ListTile(
              leading: Icon(Icons.people, color: Colors.green),
              title: Text(
                'Clients',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          PopupMenuItem(
            value: 'Services',
            child: ListTile(
              leading: Icon(Icons.build, color: Colors.orange),
              title: Text(
                'Services',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          PopupMenuItem(
            value: 'Profiles',
            child: ListTile(
              leading: Icon(Icons.person, color: Colors.purple),
              title: Text(
                'Profiles',
                style: TextStyle(
                  color: Colors.purple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ];
      },
      icon: Icon(
        Icons.more_vert,
      ), // Icône du bouton de menu
      color: Colors.white, // Couleur de fond du menu
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Bord arrondi pour le menu
      ),
    ),
  ];
}
