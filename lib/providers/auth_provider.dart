import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AppUser? _user;
  AppUser? get user => _user;

  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.userStream.listen((AppUser? newUser) {
      _user = newUser;
      notifyListeners();
    });
  }

  Future<AppUser?> signUp(String email, String password) async {
    final newUser = await _authService.signUp(email, password);
    if (newUser != null) {
      _user = newUser;
      notifyListeners();
    }
    return newUser;
  }

  Future<AppUser?> signIn(String email, String password) async {
    final loggedInUser = await _authService.signIn(email, password);
    if (loggedInUser != null) {
      _user = loggedInUser;
      notifyListeners();
    }
    return loggedInUser;
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}