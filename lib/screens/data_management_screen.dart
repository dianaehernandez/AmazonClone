import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../services/data_service.dart';

class DataManagementScreen extends StatelessWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Management'),
        backgroundColor: const Color(0xFF50E3C2),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'JSON Data Storage',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your app now uses JSON files to store:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('• User accounts and order history'),
            const Text('• Shopping cart items'),
            const Text('• Product reviews and ratings'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _showStorageInfo(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF50E3C2),
                foregroundColor: Colors.white,
              ),
              child: const Text('View Storage Info'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _clearAllData(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All Data'),
            ),
          ],
        ),
      ),
    );
  }

  void _showStorageInfo(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current User: ${authProvider.currentUser?.name ?? 'None'}'),
              Text('Cart Items: ${cartProvider.itemCount}'),
              Text('Available Products: ${productProvider.products.length}'),
              const SizedBox(height: 16),
              const Text(
                'Data is automatically saved to JSON files in the app\'s document directory.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('Are you sure you want to clear all stored data? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // Clear all data
              final dataService = DataService();
              await dataService.clearAllData();
              
              // Reset providers
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final cartProvider = Provider.of<CartProvider>(context, listen: false);
              
              authProvider.logout();
              await cartProvider.clear();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data has been cleared!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
