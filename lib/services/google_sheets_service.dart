part of '../main.dart';

// ==================== GOOGLE SHEETS SERVICE ====================
class GoogleSheetsService {
  static const String scriptUrl =
      'https://script.google.com/macros/s/AKfycbw-b4Y1scTJ5RBMW8wZTNVW4uBphBXtH1C3VMIrgeQN5eAfThWKGgMejkaZv9ebIpES/exec';

  static Future<Map<String, dynamic>> _post(Map<String, dynamic> data) async {
    final formData = data.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );

    final response = await http
        .post(
          Uri.parse(scriptUrl),
          body: formData,
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception('Server error ${response.statusCode}');
    }

    return jsonDecode(response.body.trim()) as Map<String, dynamic>;
  }

  static Future<User?> register({
    required String name,
    required String username,
    required String password,
  }) async {
    final result = await _post({
      'action': 'register',
      'name': name,
      'username': username,
      'password': password,
    });

    if (result['status'] != 'success') {
      throw Exception(result['message'] ?? 'Gagal membuat akun');
    }

    return User.fromJson(result['user'] as Map<String, dynamic>);
  }

  static Future<User?> login(String username, String password) async {
    final result = await _post({
      'action': 'login',
      'username': username,
      'password': password,
    });

    if (result['status'] != 'success') {
      throw Exception(result['message'] ?? 'Username atau password salah');
    }

    return User.fromJson(result['user'] as Map<String, dynamic>);
  }

  static Future<bool> sendOrderToSheet(
    List<CartItem> items,
    double total,
    String customerName,
    String tableNumber,
    PaymentMethod paymentMethod,
  ) async {
    try {
      final itemsData = items.map((item) => {
        'product_id': item.product.id,
        'product_name': item.product.name,
        'quantity': item.quantity,
        'price': item.product.price,
        'total': item.totalPrice,
      }).toList();

      final result = await _post({
        'action': 'create_order',
        'user_id': currentUser?.id ?? '',
        'username': currentUser?.username ?? '',
        'customer_name': customerName,
        'table_number': tableNumber,
        'total_amount': total,
        'payment_method': paymentMethod.displayName,
        'items': Uri.encodeComponent(jsonEncode(itemsData)),
      });

      return result['status'] == 'success';
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  static Future<List<Order>> fetchOrders({String? userId}) async {
    final result = await _post({
      'action': 'orders',
      if (userId != null) 'user_id': userId,
    });

    if (result['status'] != 'success') {
      throw Exception(result['message'] ?? 'Gagal mengambil pesanan');
    }

    final data = (result['orders'] as List<dynamic>? ?? []);
    return data
        .map((json) => Order.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  static Future<List<User>> fetchUsers() async {
    final result = await _post({'action': 'users'});

    if (result['status'] != 'success') {
      throw Exception(result['message'] ?? 'Gagal mengambil user');
    }

    final data = (result['users'] as List<dynamic>? ?? []);
    return data
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
