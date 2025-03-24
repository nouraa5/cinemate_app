import 'package:flutter/material.dart';
import '../database/user_dao.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  final UserDAO _userDao = UserDAO();
  User? _currentUser;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    User? user = await _userDao.getUser(email, password);
    if (user != null) {
      _currentUser = user;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(User user) async {
    // Hash the password before storing it
    User secureUser = user.copyWith(password: User.hashPassword(user.password));

    int userId = await _userDao.insertUser(secureUser);
    if (userId > 0) {
      _currentUser = secureUser.copyWith(id: userId);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> updateUser(User updatedUser) async {
    final result = await _userDao.updateUser(updatedUser);
    if (result > 0) {
      _currentUser = updatedUser;
      notifyListeners();
      return true;
    }
    return false;
  }
}
