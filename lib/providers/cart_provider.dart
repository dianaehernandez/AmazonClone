import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/data_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  final DataService _dataService = DataService();

  List<CartItem> get items => _items;
  
  List<CartItem> get selectedItems => _items.where((item) => item.isSelected).toList();
  
  int get itemCount => _items.fold(0, (total, item) => total + item.quantity);
  
  int get selectedItemCount => selectedItems.fold(0, (total, item) => total + item.quantity);
  
  double get totalAmount => selectedItems.fold(0.0, (total, item) => total + item.totalPrice);

  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    _items = await _dataService.loadCart();
    notifyListeners();
  }

  Future<void> _saveCart() async {
    await _dataService.saveCart(_items);
  }

  Future<void> addItem(Product product) async {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItem(product: product, quantity: 1, isSelected: true));
    }
    
    await _saveCart();
    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    await _saveCart();
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> toggleSelection(String productId) async {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].isSelected = !_items[index].isSelected;
      await _saveCart();
      notifyListeners();
    }
  }

  Future<void> selectAll(bool isSelected) async {
    for (var item in _items) {
      item.isSelected = isSelected;
    }
    await _saveCart();
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    await _saveCart();
    notifyListeners();
  }

  Future<void> clearSelectedItems() async {
    _items.removeWhere((item) => item.isSelected);
    await _saveCart();
    notifyListeners();
  }

  bool isInCart(String productId) {
    return _items.any((item) => item.product.id == productId);
  }

  int getQuantity(String productId) {
    final item = _items.where((item) => item.product.id == productId);
    return item.isNotEmpty ? item.first.quantity : 0;
  }
}
