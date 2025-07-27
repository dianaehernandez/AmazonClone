import 'package:flutter/material.dart';

class Address {
  final String id;
  final String title;
  final String fullAddress;
  final String city;
  final String postalCode;
  final bool isDefault;

  Address({
    required this.id,
    required this.title,
    required this.fullAddress,
    required this.city,
    required this.postalCode,
    this.isDefault = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fullAddress': fullAddress,
      'city': city,
      'postalCode': postalCode,
      'isDefault': isDefault,
    };
  }

  static Address fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'],
      title: json['title'],
      fullAddress: json['fullAddress'],
      city: json['city'],
      postalCode: json['postalCode'],
      isDefault: json['isDefault'] ?? false,
    );
  }
}

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Address> _addresses = [
    Address(
      id: '1',
      title: 'Home',
      fullAddress: '123 Main Street, Barangay Sample',
      city: 'Manila',
      postalCode: '1000',
      isDefault: true,
    ),
    Address(
      id: '2',
      title: 'Office',
      fullAddress: '456 Business Ave, Makati CBD',
      city: 'Makati',
      postalCode: '1200',
    ),
  ];

  void _addAddress() {
    _showAddressDialog();
  }

  void _editAddress(Address address) {
    _showAddressDialog(address: address);
  }

  void _deleteAddress(String addressId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _addresses.removeWhere((addr) => addr.id == addressId);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Address deleted successfully'),
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

  void _showAddressDialog({Address? address}) {
    final titleController = TextEditingController(text: address?.title ?? '');
    final addressController = TextEditingController(text: address?.fullAddress ?? '');
    final cityController = TextEditingController(text: address?.city ?? '');
    final postalController = TextEditingController(text: address?.postalCode ?? '');
    bool isDefault = address?.isDefault ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(address == null ? 'Add Address' : 'Edit Address'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Address Title (e.g., Home, Office)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Full Address',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cityController,
                  decoration: const InputDecoration(
                    labelText: 'City',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: postalController,
                  decoration: const InputDecoration(
                    labelText: 'Postal Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                CheckboxListTile(
                  title: const Text('Set as default address'),
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
                if (titleController.text.isNotEmpty &&
                    addressController.text.isNotEmpty &&
                    cityController.text.isNotEmpty &&
                    postalController.text.isNotEmpty) {
                  
                  final newAddress = Address(
                    id: address?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text,
                    fullAddress: addressController.text,
                    city: cityController.text,
                    postalCode: postalController.text,
                    isDefault: isDefault,
                  );

                  setState(() {
                    if (address == null) {
                      // Adding new address
                      if (isDefault) {
                        // Remove default from other addresses
                        _addresses = _addresses.map((addr) => Address(
                          id: addr.id,
                          title: addr.title,
                          fullAddress: addr.fullAddress,
                          city: addr.city,
                          postalCode: addr.postalCode,
                          isDefault: false,
                        )).toList();
                      }
                      _addresses.add(newAddress);
                    } else {
                      // Editing existing address
                      final index = _addresses.indexWhere((addr) => addr.id == address.id);
                      if (index != -1) {
                        if (isDefault) {
                          // Remove default from other addresses
                          _addresses = _addresses.map((addr) => Address(
                            id: addr.id,
                            title: addr.title,
                            fullAddress: addr.fullAddress,
                            city: addr.city,
                            postalCode: addr.postalCode,
                            isDefault: addr.id == address.id,
                          )).toList();
                        }
                        _addresses[index] = newAddress;
                      }
                    }
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(address == null 
                          ? 'Address added successfully' 
                          : 'Address updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF50E3C2),
              ),
              child: Text(address == null ? 'Add' : 'Update'),
            ),
          ],
        ),
      ),
    );
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
              'My Addresses',
              style: TextStyle(color: Colors.white),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Search addresses feature not implemented')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Camera search not implemented')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.mic, color: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voice search not implemented')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _addresses.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No addresses added yet',
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
                    itemCount: _addresses.length,
                    itemBuilder: (context, index) {
                      final address = _addresses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF50E3C2),
                            child: Icon(
                              address.isDefault ? Icons.home : Icons.location_on,
                              color: Colors.white,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                address.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (address.isDefault) ...[
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
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(address.fullAddress),
                              Text('${address.city}, ${address.postalCode}'),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onTap: () => _editAddress(address),
                              ),
                              PopupMenuItem(
                                child: const ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('Delete'),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                onTap: () => _deleteAddress(address.id),
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
                onPressed: _addAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF50E3C2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Add New Address',
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
