import 'package:flutter/material.dart';

class PaymentMethod {
  final String id;
  final String type; // 'card', 'bank', 'wallet'
  final String name;
  final String details;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    required this.details,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'details': details,
      'isDefault': isDefault,
    };
  }

  static PaymentMethod fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      details: json['details'],
      isDefault: json['isDefault'] ?? false,
    );
  }
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      id: '1',
      type: 'card',
      name: 'Visa Card',
      details: '**** **** **** 1234',
      isDefault: true,
    ),
    PaymentMethod(
      id: '2',
      type: 'wallet',
      name: 'GCash',
      details: '+63 917 123 4567',
    ),
  ];

  void _addPaymentMethod() {
    _showPaymentMethodDialog();
  }

  void _editPaymentMethod(PaymentMethod method) {
    _showPaymentMethodDialog(method: method);
  }

  void _deletePaymentMethod(String methodId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Payment Method'),
        content: const Text('Are you sure you want to delete this payment method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _paymentMethods.removeWhere((method) => method.id == methodId);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment method deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodDialog({PaymentMethod? method}) {
    String selectedType = method?.type ?? 'card';
    final nameController = TextEditingController(text: method?.name ?? '');
    final detailsController = TextEditingController(text: method?.details ?? '');
    bool isDefault = method?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(method == null ? 'Add Payment Method' : 'Edit Payment Method'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Payment Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'card', child: Text('Credit/Debit Card')),
                    DropdownMenuItem(value: 'bank', child: Text('Bank Account')),
                    DropdownMenuItem(value: 'wallet', child: Text('Digital Wallet')),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedType = value!;
                      // Clear details when type changes
                      detailsController.clear();
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: _getNameLabel(selectedType),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: detailsController,
                  decoration: InputDecoration(
                    labelText: _getDetailsLabel(selectedType),
                    border: const OutlineInputBorder(),
                    hintText: _getDetailsHint(selectedType),
                  ),
                  keyboardType: selectedType == 'card' 
                      ? TextInputType.number 
                      : TextInputType.text,
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Set as default payment method'),
                  value: isDefault,
                  onChanged: (value) {
                    setDialogState(() {
                      isDefault = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFF50E3C2),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    detailsController.text.isNotEmpty) {
                  
                  final newMethod = PaymentMethod(
                    id: method?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    type: selectedType,
                    name: nameController.text,
                    details: detailsController.text,
                    isDefault: isDefault,
                  );

                  setState(() {
                    if (method == null) {
                      // Adding new method
                      if (isDefault) {
                        // Remove default from other methods
                        _paymentMethods = _paymentMethods.map((m) => PaymentMethod(
                          id: m.id,
                          type: m.type,
                          name: m.name,
                          details: m.details,
                          isDefault: false,
                        )).toList();
                      }
                      _paymentMethods.add(newMethod);
                    } else {
                      // Editing existing method
                      final index = _paymentMethods.indexWhere((m) => m.id == method.id);
                      if (index != -1) {
                        if (isDefault) {
                          // Remove default from other methods
                          _paymentMethods = _paymentMethods.map((m) => PaymentMethod(
                            id: m.id,
                            type: m.type,
                            name: m.name,
                            details: m.details,
                            isDefault: m.id == method.id,
                          )).toList();
                        }
                        _paymentMethods[index] = newMethod;
                      }
                    }
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(method == null 
                          ? 'Payment method added successfully' 
                          : 'Payment method updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF50E3C2),
              ),
              child: Text(method == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  String _getNameLabel(String type) {
    switch (type) {
      case 'card':
        return 'Card Name (e.g., Visa, Mastercard)';
      case 'bank':
        return 'Bank Name';
      case 'wallet':
        return 'Wallet Name (e.g., GCash, PayMaya)';
      default:
        return 'Payment Name';
    }
  }

  String _getDetailsLabel(String type) {
    switch (type) {
      case 'card':
        return 'Card Number';
      case 'bank':
        return 'Account Number';
      case 'wallet':
        return 'Phone Number';
      default:
        return 'Details';
    }
  }

  String _getDetailsHint(String type) {
    switch (type) {
      case 'card':
        return '1234 5678 9012 3456';
      case 'bank':
        return '1234567890';
      case 'wallet':
        return '+63 917 123 4567';
      default:
        return '';
    }
  }

  IconData _getPaymentIcon(String type) {
    switch (type) {
      case 'card':
        return Icons.credit_card;
      case 'bank':
        return Icons.account_balance;
      case 'wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF50E3C2), // Mint green
                Color(0xFF4DD0E1), // Light blue
              ],
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              'Payment Methods',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _paymentMethods.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payment,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No payment methods added yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _paymentMethods.length,
                    itemBuilder: (context, index) {
                      final method = _paymentMethods[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF50E3C2),
                            child: Icon(
                              _getPaymentIcon(method.type),
                              color: Colors.white,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                method.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (method.isDefault) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF50E3C2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Default',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(method.details),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onTap: () => _editPaymentMethod(method),
                              ),
                              PopupMenuItem(
                                child: const ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('Delete'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onTap: () => _deletePaymentMethod(method.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _addPaymentMethod,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF50E3C2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add Payment Method',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
