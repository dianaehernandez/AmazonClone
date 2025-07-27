import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/data_service.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final DataService _dataService = DataService();

  List<Product> get products => _filteredProducts.isEmpty ? _products : _filteredProducts;
  List<Product> get discountedProducts => _products.where((p) => p.hasDiscount).toList();

  ProductProvider() {
    _initializeProducts();
  }

  Future<void> _initializeProducts() async {
    // Try to load products from JSON first
    final savedProducts = await _dataService.loadProducts();
    
    if (savedProducts.isNotEmpty) {
      _products = savedProducts;
    } else {
      // Initialize with default products if no saved data
    _products = [
      Product(
        id: '1',
        name: 'iPhone 15 Pro Max',
        description: 'The latest flagship smartphone from Apple with advanced camera system and A17 Pro chip.',
        price: 89990.00,
        originalPrice: 99990.00,
        imageUrl: 'https://images.unsplash.com/photo-1592899677977-9c10ca588bbd?w=400',
        weight: 0.221,
        category: 'Electronics',
        rating: 4.8,
        reviews: [
          Review(
            id: '1',
            userName: 'Maria Santos',
            rating: 5.0,
            comment: 'Amazing phone! Camera quality is outstanding.',
            date: DateTime.now().subtract(const Duration(days: 5)),
          ),
          Review(
            id: '2',
            userName: 'Juan Dela Cruz',
            rating: 4.5,
            comment: 'Great performance, battery life could be better.',
            date: DateTime.now().subtract(const Duration(days: 10)),
          ),
        ],
      ),
      Product(
        id: '2',
        name: 'Samsung Galaxy S24 Ultra',
        description: 'Premium Android smartphone with S Pen and incredible zoom capabilities.',
        price: 79990.00,
        originalPrice: 89990.00,
        imageUrl: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
        weight: 0.232,
        category: 'Electronics',
        rating: 4.7,
        reviews: [
          Review(
            id: '3',
            userName: 'Anna Reyes',
            rating: 5.0,
            comment: 'Love the S Pen functionality!',
            date: DateTime.now().subtract(const Duration(days: 3)),
          ),
        ],
      ),
      Product(
        id: '3',
        name: 'MacBook Air M3',
        description: 'Ultra-thin laptop with Apple M3 chip, perfect for productivity and creative work.',
        price: 69990.00,
        imageUrl: 'https://images.unsplash.com/photo-1541807084-5c52b6b3adef?w=400',
        weight: 1.24,
        category: 'Computers',
        rating: 4.9,
        reviews: [
          Review(
            id: '4',
            userName: 'Carlos Rodriguez',
            rating: 5.0,
            comment: 'Best laptop I\'ve ever owned. Silent and fast!',
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      Product(
        id: '4',
        name: 'Sony WH-1000XM5 Headphones',
        description: 'Industry-leading noise canceling wireless headphones with exceptional sound quality.',
        price: 15990.00,
        originalPrice: 19990.00,
        imageUrl: 'https://images.unsplash.com/photo-1583394838336-acd977736f90?w=400',
        weight: 0.25,
        category: 'Audio',
        rating: 4.6,
        reviews: [
          Review(
            id: '5',
            userName: 'Patricia Tan',
            rating: 4.5,
            comment: 'Excellent noise cancellation, very comfortable.',
            date: DateTime.now().subtract(const Duration(days: 7)),
          ),
        ],
      ),
      Product(
        id: '5',
        name: 'Nintendo Switch OLED',
        description: 'Gaming console with vibrant OLED screen, perfect for gaming on the go.',
        price: 18990.00,
        originalPrice: 21990.00,
        imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400',
        weight: 0.42,
        category: 'Gaming',
        rating: 4.8,
        reviews: [
          Review(
            id: '6',
            userName: 'Miguel Santos',
            rating: 5.0,
            comment: 'Perfect for family gaming sessions!',
            date: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      ),
      Product(
        id: '6',
        name: 'Apple Watch Series 9',
        description: 'Advanced smartwatch with health monitoring and fitness tracking capabilities.',
        price: 24990.00,
        imageUrl: 'https://images.unsplash.com/photo-1434493907317-a46b5bbe7834?w=400',
        weight: 0.051,
        category: 'Wearables',
        rating: 4.7,
        reviews: [
          Review(
            id: '7',
            userName: 'Lisa Garcia',
            rating: 4.5,
            comment: 'Great fitness tracker, love the health features.',
            date: DateTime.now().subtract(const Duration(days: 4)),
          ),
        ],
      ),
      Product(
        id: '7',
        name: 'iPad Pro 12.9"',
        description: 'Professional tablet with M2 chip, perfect for creative professionals and students.',
        price: 64990.00,
        originalPrice: 69990.00,
        imageUrl: 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400',
        weight: 0.682,
        category: 'Tablets',
        rating: 4.8,
        reviews: [
          Review(
            id: '8',
            userName: 'David Chen',
            rating: 5.0,
            comment: 'Replaced my laptop for most tasks. Amazing display!',
            date: DateTime.now().subtract(const Duration(days: 6)),
          ),
        ],
      ),
      Product(
        id: '8',
        name: 'Dyson V15 Detect',
        description: 'Powerful cordless vacuum cleaner with laser dust detection technology.',
        price: 34990.00,
        originalPrice: 39990.00,
        imageUrl: 'https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=400',
        weight: 3.2,
        category: 'Home Appliances',
        rating: 4.5,
        reviews: [
          Review(
            id: '9',
            userName: 'Sarah Lopez',
            rating: 4.0,
            comment: 'Great suction power, a bit heavy though.',
            date: DateTime.now().subtract(const Duration(days: 8)),
          ),
        ],
      ),
    ];
    
    // Save initial products to JSON
    await _saveProducts();
    }
    
    _filteredProducts = _products;
    notifyListeners();
  }

  Future<void> _saveProducts() async {
    await _dataService.saveProducts(_products);
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addReview(String productId, Review review) async {
    final productIndex = _products.indexWhere((p) => p.id == productId);
    if (productIndex != -1) {
      final product = _products[productIndex];
      final updatedReviews = [...product.reviews, review];
      final newRating = updatedReviews.fold(0.0, (sum, r) => sum + r.rating) / updatedReviews.length;
      
      _products[productIndex] = product.copyWith(
        reviews: updatedReviews,
        rating: newRating,
      );
      
      // Save to JSON
      await _saveProducts();
      notifyListeners();
    }
  }

  void searchProducts(String query) {
    if (query.isEmpty) {
      _filteredProducts = _products;
    } else {
      _filteredProducts = _products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void filterByCategory(String category) {
    if (category.isEmpty || category == 'All') {
      _filteredProducts = _products;
    } else {
      _filteredProducts = _products.where((p) => p.category == category).toList();
    }
    notifyListeners();
  }

  List<String> get categories {
    final cats = _products.map((p) => p.category).toSet().toList();
    cats.insert(0, 'All');
    return cats;
  }
}
