import 'cart_item.dart';

class User {
  final String id;
  final String name;
  final String username;
  final String email;
  final String password;
  final String? phone;
  final String? address;
  final String? profileImagePath;
  final List<Order> orders;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    this.phone,
    this.address,
    this.profileImagePath,
    this.orders = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  User copyWith({
    String? name,
    String? username,
    String? email,
    String? password,
    String? phone,
    String? address,
    String? profileImagePath,
    List<Order>? orders,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      orders: orders ?? this.orders,
      createdAt: createdAt,
    );
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'profileImagePath': profileImagePath,
      'orders': orders.map((order) => order.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      username: json['username'] ?? json['name'], // Fallback to name if username doesn't exist
      email: json['email'],
      password: json['password'],
      phone: json['phone'],
      address: json['address'],
      profileImagePath: json['profileImagePath'],
      orders: (json['orders'] as List<dynamic>?)
          ?.map((orderJson) => Order.fromJson(orderJson))
          .toList() ?? [],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime date;
  final String status;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
    this.status = 'Delivered',
  });

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'date': date.toIso8601String(),
      'status': status,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      items: (json['items'] as List<dynamic>)
          .map((itemJson) => CartItem.fromJson(itemJson))
          .toList(),
      total: json['total'].toDouble(),
      date: DateTime.parse(json['date']),
      status: json['status'],
    );
  }
}
