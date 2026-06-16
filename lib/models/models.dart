part of '../main.dart';

// ==================== MODEL USER ====================
class User {
  final String id;
  final String username;
  final String password;
  final String role; // 'admin' or 'pelanggan'
  final String name;

  const User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'password': password,
    'role': role,
    'name': name,
  };

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      role: json['role']?.toString() ?? 'pelanggan',
      name: json['name']?.toString() ?? '',
    );
  }
}

List<User> users = [];

User? currentUser;

// ==================== MODEL PRODUK ====================
class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.category,
  });
}

// ==================== MODEL ORDER ====================
class Order {
  final String id;
  final String customerName;
  final String tableNumber;
  final String paymentMethod;
  final double totalAmount;
  final DateTime timestamp;
  final List<CartItem> items;
  final String userId;
  final String username;

  Order({
    required this.id,
    required this.customerName,
    required this.tableNumber,
    required this.paymentMethod,
    required this.totalAmount,
    required this.timestamp,
    required this.items,
    required this.userId,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerName': customerName,
    'tableNumber': tableNumber,
    'paymentMethod': paymentMethod,
    'totalAmount': totalAmount,
    'timestamp': timestamp.toIso8601String(),
    'userId': userId,
    'username': username,
    'items': items.map((e) => {
      'productId': e.product.id,
      'productName': e.product.name,
      'quantity': e.quantity,
      'price': e.product.price,
      'imageUrl': e.product.imageUrl,
      'description': e.product.description,
      'category': e.product.category,
      'total': e.totalPrice,
    }).toList(),
  };

  factory Order.fromJson(Map<String, dynamic> json) {
    final itemsData = (json['items'] as List<dynamic>?) ?? [];
    final items = itemsData.map((itemJson) {
      final productId = itemJson['productId']?.toString() ?? '';
      final product = Product(
        id: productId,
        name: itemJson['productName'] as String? ?? 'Produk Tidak Ditemukan',
        price: (itemJson['price'] as num?)?.toDouble() ?? 0,
        imageUrl: itemJson['imageUrl'] as String? ?? '',
        description: itemJson['description'] as String? ?? '',
        category: itemJson['category'] as String? ?? '',
      );
      return CartItem(
        product: product,
        quantity: itemJson['quantity'] as int? ?? 1,
      );
    }).toList();

    return Order(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      tableNumber: json['tableNumber'] as String,
      paymentMethod: json['paymentMethod'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      items: items,
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
    );
  }
}

// List untuk menyimpan riwayat pesanan
List<Order> orderHistory = [];

// ==================== MODEL CART ITEM ====================
class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

// ==================== ENUM METODE PEMBAYARAN ====================
enum PaymentMethod {
  cash,
  qris,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Tunai';
      case PaymentMethod.qris:
        return 'QRIS';
    }
  }
  
  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.qris:
        return Icons.qr_code_scanner;
    }
  }
}

