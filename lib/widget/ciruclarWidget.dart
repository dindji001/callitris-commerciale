import 'package:flutter/material.dart';

class ShowLoadingDialog extends StatelessWidget {
  const ShowLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white, // Remplace avec ta couleur personnalisée
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: CircularProgressIndicator(
              color: Colors.purple, // Remplace avec ta couleur personnalisée
            ),
          ),
        ),
      ),
    );
  }

  // Fonction pour afficher le dialog
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Empêche la fermeture en cliquant en dehors
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent, // Transparent pour voir le fond
          child: ShowLoadingDialog(),
        );
      },
    );
  }

  // Fonction pour fermer le dialog
  static void hide(BuildContext context) {
    Navigator.pop(context);
  }
}
