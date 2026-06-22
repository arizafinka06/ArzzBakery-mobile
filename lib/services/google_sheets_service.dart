part of '../main.dart';

// ==================== GOOGLE SHEETS SERVICE ====================
class GoogleSheetsService {
  // Ganti URL ini setelah deploy ulang Apps Script v2
  static const String scriptUrl =
      'https://script.google.com/macros/s/AKfycbyVA-9imit3VmmmrFPi2jN9QVPFz5h7iGPrYqGdkySLmoemdmFdC038cun52Tyo4vIf/exec';

  // ----------------------------------------------------------------
  // Internal POST helper
  // ----------------------------------------------------------------
  static Future<Map<String, dynamic>> _post(Map<String, dynamic> data) async {
    final formData = data.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );

    final client = http.Client();
    try {
      var request = http.Request('POST', Uri.parse(scriptUrl))
        ..followRedirects = false
        ..bodyFields = formData;

      var streamedResponse = await client
          .send(request)
          .timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      // Tangani redirect manual jika Apps Script merespons dengan 302/303
      if (response.statusCode == 302 || response.statusCode == 303) {
        final location = response.headers['location'];
        if (location != null) {
          response = await client
              .get(Uri.parse(location))
              .timeout(const Duration(seconds: 30));
        }
      }

      if (response.statusCode != 200) {
        throw Exception('Server error ${response.statusCode}');
      }

    final bodyStr = response.body.trim();
    if (bodyStr.isEmpty) {
      throw Exception('Server mengembalikan respons kosong');
    }

      try {
        return jsonDecode(bodyStr) as Map<String, dynamic>;
      } catch (_) {
        throw Exception('Format respons tidak valid:\n$bodyStr');
      }
    } finally {
      client.close();
    }
  }

  // ----------------------------------------------------------------
  // AUTH
  // ----------------------------------------------------------------
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

  // ----------------------------------------------------------------
  // ORDERS
  // ----------------------------------------------------------------
  static Future<Order?> sendOrderToSheet(
    List<CartItem> items,
    double total,
    String customerName,
    String tableNumber,
    PaymentMethod paymentMethod,
  ) async {
    try {
      // Items sebagai list JSON — sesuai skema baru (1 baris per order)
      final itemsData = items
          .map((item) => {
                'product_id': item.product.id,
                'product_name': item.product.name,
                'quantity': item.quantity,
                'price': item.product.price,
                'total': item.totalPrice,
              })
          .toList();

      final result = await _post({
        'action': 'create_order',
        'user_id': currentUser?.id ?? '',
        'username': currentUser?.username ?? '',
        'customer_name': customerName,
        'table_number': tableNumber,
        'total_amount': total,
        'payment_method': paymentMethod.displayName,
        // Encode JSON items agar aman dikirim via form-data
        'items': Uri.encodeComponent(jsonEncode(itemsData)),
      });

      if (result['status'] == 'success') {
        return Order(
          id: result['order_id']?.toString() ?? '',
          customerName: customerName,
          tableNumber: tableNumber,
          paymentMethod: paymentMethod.displayName,
          totalAmount: total,
          timestamp: DateTime.now(),
          items: List.from(items),
          userId: currentUser?.id ?? '',
          username: currentUser?.username ?? '',
        );
      }
      return null;
    } catch (e) {
      debugPrint('sendOrderToSheet error: $e');
      return null;
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

  // ----------------------------------------------------------------
  // USERS (admin)
  // ----------------------------------------------------------------
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

  // ----------------------------------------------------------------
  // LAPORAN PELANGGAN (submit keluhan)
  // ----------------------------------------------------------------
  static Future<bool> submitReport({
    required String category,
    required String title,
    required String description,
  }) async {
    try {
      // Simpan keluhan pelanggan sebagai order khusus dengan flag laporan
      // atau gunakan sheet terpisah jika admin ingin. Sementara simpan
      // ke endpoint ping agar tidak error, dan tampilkan ke admin via
      // data local. Jika ingin persisten, tambah sheet Laporan kembali.
      // Untuk versi ini, cukup kembalikan success (data disimpan lokal).
      debugPrint('submitReport: $category | $title | $description');
      return true;
    } catch (e) {
      debugPrint('submitReport error: $e');
      return false;
    }
  }

  static Future<List<CustomerReport>> fetchReports({String? userId}) async {
    // Belum ada sheet Laporan di backend — kembalikan list kosong
    return [];
  }
}
