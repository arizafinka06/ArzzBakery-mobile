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
    // Items bisa berupa List<dynamic> (dari response JSON)
    // atau String JSON (jika dibaca langsung dari spreadsheet tanpa parsing)
    List<dynamic> rawItems = [];
    final itemsField = json['items'];
    if (itemsField is List) {
      rawItems = itemsField;
    } else if (itemsField is String && itemsField.isNotEmpty) {
      try {
        rawItems = jsonDecode(itemsField) as List<dynamic>;
      } catch (_) {
        rawItems = [];
      }
    }

    final items = rawItems.map((itemJson) {
      final map = itemJson as Map<String, dynamic>;
      // Support kedua format key: productId/productName (lama) dan
      // product_id/product_name (baru dari Apps Script v2)
      final productId = map['productId']?.toString() ??
          map['product_id']?.toString() ??
          '';
      final product = Product(
        id: productId,
        name: map['productName']?.toString() ??
            map['product_name']?.toString() ??
            'Produk',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        imageUrl: map['imageUrl']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        category: map['category']?.toString() ?? '',
      );
      return CartItem(
        product: product,
        quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      );
    }).toList();

    // Parse timestamp dengan fallback aman
    DateTime parsedTimestamp;
    try {
      final rawTs = json['timestamp']?.toString() ?? '';
      parsedTimestamp =
          rawTs.isNotEmpty ? DateTime.parse(rawTs).toLocal() : DateTime.now();
    } catch (_) {
      parsedTimestamp = DateTime.now();
    }

    return Order(
      id: json['id']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      tableNumber: json['tableNumber']?.toString() ?? '',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      timestamp: parsedTimestamp,
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

// ==================== MODEL LAPORAN PELANGGAN ====================
class CustomerReport {
  final String id;
  final String userId;
  final String username;
  final String customerName;
  final String category;
  final String title;
  final String description;
  final DateTime timestamp;
  final String status; // 'Baru', 'Diproses', 'Selesai'

  CustomerReport({
    required this.id,
    required this.userId,
    required this.username,
    required this.customerName,
    required this.category,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.status,
  });

  factory CustomerReport.fromJson(Map<String, dynamic> json) {
    DateTime parsedTimestamp;
    try {
      final rawTs = json['timestamp']?.toString() ?? '';
      parsedTimestamp = rawTs.isNotEmpty ? DateTime.parse(rawTs) : DateTime.now();
    } catch (_) {
      parsedTimestamp = DateTime.now();
    }

    return CustomerReport(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      timestamp: parsedTimestamp,
      status: json['status']?.toString() ?? 'Baru',
    );
  }
}
