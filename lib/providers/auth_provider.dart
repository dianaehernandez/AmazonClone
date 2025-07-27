import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/data_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoggedIn = false;
  final DataService _dataService = DataService();
  List<User> _users = [];

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  AuthProvider() {
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    _users = await _dataService.loadUsers();
  }

  Future<void> _saveUsers() async {
    await _dataService.saveUsers(_users);
  }

  Future<bool> login(String email, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.isNotEmpty && password.isNotEmpty) {
      // Try to find existing user
      User? existingUser;
      try {
        existingUser = _users.firstWhere((user) => user.email == email);
      } catch (e) {
        existingUser = null;
      }

      if (existingUser != null) {
        // Check password (in a real app, passwords should be hashed)
        if (existingUser.password == password) {
          _currentUser = existingUser;
          _isLoggedIn = true;
          notifyListeners();
          return true;
        } else {
          return false; // Wrong password
        }
      } else {
        return false; // User not found
      }
    }
    return false; // Empty email or password
  }

  Future<bool> register(String name, String email, String password, {String? username}) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty) {
      // Check if user already exists
      bool userExists = _users.any((user) => user.email == email);
      if (userExists) {
        return false; // User already exists
      }

      // Check if username already exists (if provided)
      final finalUsername = username ?? name.toLowerCase().replaceAll(' ', '');
      bool usernameExists = _users.any((user) => user.username == finalUsername);
      if (usernameExists) {
        return false; // Username already exists
      }

      final newUser = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        username: finalUsername,
        email: email,
        password: password,
        orders: [],
      );
      
      _users.add(newUser);
      await _saveUsers();
      
      // Don't automatically log in - user needs to sign in manually
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<bool> updateUser(User updatedUser) async {
    try {
      print('AuthProvider: Updating user ${updatedUser.id}');
      print('AuthProvider: New name: ${updatedUser.name}');
      print('AuthProvider: New email: ${updatedUser.email}');
      
      _currentUser = updatedUser;
      
      // Update user in the users list
      final userIndex = _users.indexWhere((user) => user.id == updatedUser.id);
      print('AuthProvider: User index found: $userIndex');
      
      if (userIndex != -1) {
        _users[userIndex] = updatedUser;
        print('AuthProvider: About to save users to JSON...');
        await _saveUsers();
        print('AuthProvider: Users saved successfully');
        notifyListeners();
        return true;
      } else {
        print('AuthProvider: User not found in list');
        return false;
      }
    } catch (e) {
      print('AuthProvider: Error updating user: $e');
      return false;
    }
  }

  void updateCurrentUser(User updatedUser) {
    _currentUser = updatedUser;
    notifyListeners();
  }
}
