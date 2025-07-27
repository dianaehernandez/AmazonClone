import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class DataService {
  static const String _usersFileName = 'users.json';
  static const String _cartFileName = 'cart.json';
  static const String _productsFileName = 'products.json';
  static const String _reviewsFileName = 'reviews.json';

  // Get application documents directory
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Users JSON operations
  Future<File> get _usersFile async {
    final path = await _localPath;
    return File('$path/$_usersFileName');
  }

  Future<List<User>> loadUsers() async {
    try {
      final file = await _usersFile;
      if (!await file.exists()) {
        return [];
      }
      
      final contents = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(contents);
      
      return jsonData.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      print('Error loading users: $e');
      return [];
    }
  }

  Future<void> saveUsers(List<User> users) async {
    try {
      final file = await _usersFile;
      final jsonData = users.map((user) => user.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      print('Error saving users: $e');
    }
  }

  // Cart JSON operations
  Future<File> get _cartFile async {
    final path = await _localPath;
    return File('$path/$_cartFileName');
  }

  Future<List<CartItem>> loadCart() async {
    try {
      final file = await _cartFile;
      if (!await file.exists()) {
        return [];
      }
      
      final contents = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(contents);
      
      return jsonData.map((json) => CartItem.fromJson(json)).toList();
    } catch (e) {
      print('Error loading cart: $e');
      return [];
    }
  }

  Future<void> saveCart(List<CartItem> cartItems) async {
    try {
      final file = await _cartFile;
      final jsonData = cartItems.map((item) => item.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      print('Error saving cart: $e');
    }
  }

  // Products JSON operations (for reviews)
  Future<File> get _productsFile async {
    final path = await _localPath;
    return File('$path/$_productsFileName');
  }

  Future<List<Product>> loadProducts() async {
    try {
      final file = await _productsFile;
      if (!await file.exists()) {
        return [];
      }
      
      final contents = await file.readAsString();
      final List<dynamic> jsonData = jsonDecode(contents);
      
      return jsonData.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print('Error loading products: $e');
      return [];
    }
  }

  Future<void> saveProducts(List<Product> products) async {
    try {
      final file = await _productsFile;
      final jsonData = products.map((product) => product.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonData));
    } catch (e) {
      print('Error saving products: $e');
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      final usersFile = await _usersFile;
      final cartFile = await _cartFile;
      final productsFile = await _productsFile;
      final reviewsFile = await _reviewsFile;
      
      if (await usersFile.exists()) await usersFile.delete();
      if (await cartFile.exists()) await cartFile.delete();
      if (await productsFile.exists()) await productsFile.delete();
      if (await reviewsFile.exists()) await reviewsFile.delete();
    } catch (e) {
      print('Error clearing data: $e');
    }
  }

  // Reviews JSON operations
  Future<File> get _reviewsFile async {
    final path = await _localPath;
    return File('$path/$_reviewsFileName');
  }

  Future<Map<String, List<dynamic>>> loadReviews() async {
    try {
      final file = await _reviewsFile;
      if (!await file.exists()) {
        return {};
      }
      
      final contents = await file.readAsString();
      final Map<String, dynamic> jsonData = jsonDecode(contents);
      
      return jsonData.map((key, value) => MapEntry(key, value as List<dynamic>));
    } catch (e) {
      print('Error loading reviews: $e');
      return {};
    }
  }

  Future<void> saveReviews(Map<String, List<dynamic>> reviews) async {
    try {
      final file = await _reviewsFile;
      await file.writeAsString(jsonEncode(reviews));
    } catch (e) {
      print('Error saving reviews: $e');
    }
  }

  Future<void> addReview(String productId, Map<String, dynamic> review) async {
    try {
      final reviews = await loadReviews();
      if (!reviews.containsKey(productId)) {
        reviews[productId] = [];
      }
      reviews[productId]!.add(review);
      await saveReviews(reviews);
    } catch (e) {
      print('Error adding review: $e');
    }
  }
}
