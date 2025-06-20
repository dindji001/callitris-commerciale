import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  // endpoint API ici
  //static const String _apiEndpoint = 'https://api.credpay.ci/';
  // static const String _apiEndpoint = 'https://api.callitris-distribution.com';
    static const String _apiEndpoint = 'https://api.dev-mani.io';

  String? _token;
  String? _code;
  Map<String, dynamic>? _userDetail;
  Map<String, dynamic>? _user;

  String? get token => _token;
  String? get code => _code;
  Map<String, dynamic>? get userDetail => _userDetail;
  Map<String, dynamic>? get user => _user;

  // Méthode pour obtenir l'endpoint complet pour une route donnée
  String getEndpoint(String route) {
    return '$_apiEndpoint/$route';
  }

  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }

  void setUserCode(String code) {
    _code = code;
    notifyListeners();
  }

  void setUserDetail(Map<String, dynamic>? userDetail) {
    _userDetail = userDetail;
    notifyListeners();
  }

  void setUser(Map<String, dynamic>? user) {
    _user = user;
    notifyListeners();
  }

  void logout() {
    _token = null;
    _code = null;
    _userDetail = null;
    notifyListeners();
  }
}
