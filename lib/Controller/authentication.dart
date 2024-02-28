import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authenticate extends ChangeNotifier {
  bool _userLoggedIn = false;
  bool _adminLoggedIn = false;

  bool get userLoggedIn => _userLoggedIn;
  bool get adminLoggedIn => _adminLoggedIn;

  Future<void> loginAsUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('userLoggedIn', true);
    await prefs.setBool('adminLoggedIn', false);
    _userLoggedIn = true;
    _adminLoggedIn = false;
    notifyListeners();
  }

  Future<void> loginAsAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('userLoggedIn', false);
    await prefs.setBool('adminLoggedIn', true);
    _userLoggedIn = false;
    _adminLoggedIn = true;
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _userLoggedIn = prefs.getBool('userLoggedIn') ?? false;
    _adminLoggedIn = prefs.getBool('adminLoggedIn') ?? false;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('userLoggedIn', false);
    await prefs.setBool('adminLoggedIn', false);
    _userLoggedIn = false;
    _adminLoggedIn = false;
    notifyListeners();
  }
}
