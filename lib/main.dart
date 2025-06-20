import 'package:callitris/pages/services/banque.dart';
import 'package:callitris/pages/services/client_boutique.dart';
import 'package:callitris/pages/services/client_tontine.dart';
import 'package:callitris/pages/services/commandes.dart';
import 'package:callitris/pages/services/edit_bank.dart';
import 'package:callitris/pages/services/graph.dart';
import 'package:callitris/pages/services/client_as.dart';
import 'package:callitris/pages/services/help.dart';
import 'package:callitris/pages/services/mission.dart';
import 'package:callitris/pages/services/indicateur.dart';
import 'package:callitris/pages/services/salaire.dart';
import 'package:callitris/pages/services/statistic.dart';
import 'package:flutter/material.dart';
import 'package:callitris/pages/services/livraison.dart';
import 'package:callitris/pages/services/versement.dart';
import 'package:callitris/pages/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:callitris/pages/clients/add_client.dart';
import 'package:callitris/pages/services/tontine.dart';
import 'package:callitris/pages/home.dart';
import 'package:callitris/pages/login.dart';
import 'package:callitris/pages/services.dart';
import 'package:callitris/pages/client.dart';
import 'package:callitris/pages/logo_animation.dart';
import 'package:callitris/pages/profile.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) =>
          AuthProvider(), // fournisseur pour gérer l'authentification
      child: const MainApp(),
    ),
  );
}

class MonTheme {
  static final ThemeData themeData = ThemeData(
    fontFamily: GoogleFonts.ubuntu(fontWeight: FontWeight.w400).fontFamily,
    primaryColor: Colors.blue,
    // Autres propriétés de thème peuvent être ajoutées ici
  );
}

bool isAuthenticated(BuildContext context) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false).token;
  return authProvider != null; // Vérifie si le token est présent
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: MonTheme.themeData,
        // Commentez temporairement ces lignes si elles causent des problèmes
        /*
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('fr', 'FR'), // Français
          const Locale('en', 'US'), // Anglais
        ],
        */
        initialRoute: '/',
        onGenerateRoute: (settings) {
          if (isAuthenticated(context)) {
            switch (settings.name) {
              case '/':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      LogoAnimationPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/login':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      LoginPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/home':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      HomePage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              /* case '/test':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MyApp(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ); */
              case '/indicateur':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      IndicateurPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/statistic':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      StatisticPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/banque':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      BanquePage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/salaire':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      SalairePage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/graph':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      LineDefault(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/help':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      HelpPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/mission':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MissionPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/client_as':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ClientSatisfairePage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );

              case '/carnet':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      CommandePage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/edit_bank':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      EditBankPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/services':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ServicesPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/client':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ClientPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/profile':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ProfilePage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/add_client':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      NewClientRegisterPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/tontine':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      TontinePage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/client_boutique':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ClientBoutiquePage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/client_tontine':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      ClientTontinePage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/livraison':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      LivraisonPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              case '/versement':
                return PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      VersementPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                );
              default:
                return null;
            }
          } else {
            return MaterialPageRoute(builder: (_) => LoginPage());
          }
        });
  }
}
