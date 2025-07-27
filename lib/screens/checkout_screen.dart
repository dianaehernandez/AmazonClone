import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'cash_on_delivery';

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Store the total amount before clearing the cart
    final orderTotal = cartProvider.totalAmount;

    // Create fake order
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: List.from(cartProvider.selectedItems), // Use selectedItems for checkout
      total: orderTotal,
      date: DateTime.now(),
      status: 'Processing',
    );

    // Add order to user
    if (authProvider.currentUser != null) {
      final updatedUser = authProvider.currentUser!.copyWith(
        orders: [...authProvider.currentUser!.orders, order],
      );
      authProvider.updateUser(updatedUser);
    }

    // Clear only selected items from cart
    await cartProvider.clearSelectedItems();

    setState(() {
      _isProcessing = false;
    });

    if (mounted) {
      String paymentMethodText = '';
      switch (_selectedPaymentMethod) {
        case 'cash_on_delivery':
          paymentMethodText = 'Cash on Delivery';
          break;
        case 'debit_card':
          paymentMethodText = 'Debit Card';
          break;
        case 'bank_account':
          paymentMethodText = 'Bank Account';
          break;
        case 'credit_card':
          paymentMethodText = 'Credit Card';
          break;
        case 'digital_wallet':
          paymentMethodText = 'Digital Wallet';
          break;
      }
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Order Placed!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Your order has been placed successfully. Thank you for shopping with Amazon!'),
              const SizedBox(height: 16),
              Text('Payment Method: $paymentMethodText'),
              Text('Total Amount: ₱${orderTotal.toStringAsFixed(2)}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF232F3E),
        title: const Text(
          'Checkout',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer2<CartProvider, AuthProvider>(
        builder: (context, cartProvider, authProvider, child) {
          if (cartProvider.selectedItems.isEmpty) {
            return const Center(
              child: Text(
                'No items selected for checkout',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Delivery Address
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Delivery Address',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF232F3E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            authProvider.currentUser?.name ?? 'Guest User',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '123 Main Street\nQuezon City, Metro Manila\nPhilippines 1100',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Address change feature not implemented'),
                                ),
                              );
                            },
                            child: const Text('Change Address'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Order Summary
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Order Summary',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF232F3E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...cartProvider.selectedItems.map((cartItem) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    cartItem.product.imageUrl,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey[200],
                                      child: const Icon(Icons.image_not_supported),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cartItem.product.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Qty: ${cartItem.quantity}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₱${cartItem.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '₱${cartProvider.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Shipping:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                'FREE',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF232F3E),
                                ),
                              ),
                              Text(
                                '₱${cartProvider.totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF232F3E),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Method
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF232F3E),
                            ),
                          ),
                          const SizedBox(height: 12),
                          
                          // Cash on Delivery
                          ListTile(
                            leading: const Icon(Icons.money, color: Color(0xFF232F3E)),
                            title: const Text('Cash on Delivery'),
                            subtitle: const Text('Pay when your order arrives'),
                            trailing: Radio<String>(
                              value: 'cash_on_delivery',
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              },
                              activeColor: const Color(0xFF50E3C2),
                            ),
                          ),
                          
                          // Debit Card
                          ListTile(
                            leading: const Icon(Icons.credit_card, color: Color(0xFF232F3E)),
                            title: const Text('Debit Card'),
                            subtitle: const Text('Pay with your debit card'),
                            trailing: Radio<String>(
                              value: 'debit_card',
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              },
                              activeColor: const Color(0xFF50E3C2),
                            ),
                          ),
                          
                          // Bank Account
                          ListTile(
                            leading: const Icon(Icons.account_balance, color: Color(0xFF232F3E)),
                            title: const Text('Bank Account'),
                            subtitle: const Text('Direct bank transfer'),
                              trailing: Radio<String>(
                              value: 'bank_account',
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              },
                              activeColor: const Color(0xFF50E3C2),
                            ),
                          ),
                          
                          // Credit Card
                          ListTile(
                            leading: const Icon(Icons.credit_card_outlined, color: Color(0xFF232F3E)),
                            title: const Text('Credit Card'),
                            subtitle: const Text('Pay with your credit card'),
                            trailing: Radio<String>(
                              value: 'credit_card',
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              },
                              activeColor: const Color(0xFF50E3C2),
                            ),
                          ),
                          
                          // Digital Wallet
                          ListTile(
                            leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF232F3E)),
                            title: const Text('Digital Wallet'),
                            subtitle: const Text('GCash, PayMaya, etc.'),
                            trailing: Radio<String>(
                              value: 'digital_wallet',
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              },
                              activeColor: const Color(0xFF50E3C2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Place Order Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF50E3C2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isProcessing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Place Order - ₱${cartProvider.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Order Info
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF232F3E),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '• Free shipping on all orders\n• Estimated delivery: 2-3 business days\n• 30-day return policy\n• Customer support: 24/7',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
