import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MyApp());
}

// ==================== STORAGE SERVICE ====================
class StorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Load persisted registered users
    final usersJson = _prefs.getStringList('registeredUsers') ?? [];
    users = usersJson.map((json) => User.fromJson(jsonDecode(json))).toList();
    // Load persisted current user
    final userJson = _prefs.getString('currentUser');
    if (userJson != null) {
      currentUser = User.fromJson(jsonDecode(userJson));
    }
    // Load persisted order history
    final ordersJson = _prefs.getStringList('orderHistory') ?? [];
    orderHistory = ordersJson.map((json) => Order.fromJson(jsonDecode(json))).toList();
  }

  static Future<void> saveUser(User? user) async {
    if (user == null) {
      await _prefs.remove('currentUser');
    } else {
      await _prefs.setString('currentUser', jsonEncode(user.toJson()));
    }
  }

  static Future<void> saveUsers(List<User> usersList) async {
    final usersJson = usersList.map((user) => jsonEncode(user.toJson())).toList();
    await _prefs.setStringList('registeredUsers', usersJson);
  }

  static Future<void> saveOrderHistory(List<Order> orders) async {
    final ordersJson = orders.map((order) => jsonEncode(order.toJson())).toList();
    await _prefs.setStringList('orderHistory', ordersJson);
  }

  static Future<void> addOrder(Order order) async {
    orderHistory.add(order);
    await saveOrderHistory(orderHistory);
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
    currentUser = null;
    orderHistory.clear();
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arzz Bakery',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: currentUser != null ? const MainMenuScreen() : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ==================== MODEL USER ====================
class User {
  final String id;
  final String username;
  final String password;
  final String role; // 'admin' or 'kasir'
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
      id: json['id'] as String,
      username: json['username'] as String,
      password: json['password'] as String,
      role: json['role'] as String,
      name: json['name'] as String,
    );
  }
}

// Dummy users data - starts empty, users register themselves
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
  final String kasirName;

  Order({
    required this.id,
    required this.customerName,
    required this.tableNumber,
    required this.paymentMethod,
    required this.totalAmount,
    required this.timestamp,
    required this.items,
    required this.kasirName,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'customerName': customerName,
    'tableNumber': tableNumber,
    'paymentMethod': paymentMethod,
    'totalAmount': totalAmount,
    'timestamp': timestamp.toIso8601String(),
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
    'kasirName': kasirName,
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
      kasirName: json['kasirName'] as String,
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

// ==================== GOOGLE SHEETS SERVICE ====================
class GoogleSheetsService {
  static const String scriptUrl =
      'https://script.google.com/macros/s/AKfycbw7x-9vpdbKCubrNgt6_KLoeC9Ibze4jr0zS-MB3PFD-FmmdPvQkSxyZBFxkUmKlWDP/exec';

  static Future<bool> sendOrderToSheet(
    List<CartItem> items,
    double total,
    String customerName,
    String tableNumber,
    PaymentMethod paymentMethod,
  ) async {
    try {
      final List<Map<String, dynamic>> itemsData = items.map((item) => {
        'product_name': item.product.name,
        'quantity': item.quantity,
        'price': item.product.price,
        'total': item.totalPrice,
      }).toList();

      final String itemsJson = Uri.encodeComponent(jsonEncode(itemsData));

      final uri = Uri.parse(
        '$scriptUrl'
        '?customer_name=${Uri.encodeComponent(customerName)}'
        '&table_number=${Uri.encodeComponent(tableNumber)}'
        '&total_amount=$total'
        '&payment_method=${Uri.encodeComponent(paymentMethod.displayName)}'
        '&items=$itemsJson',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = response.body.trim();
        if (body.startsWith('{')) {
          final Map<String, dynamic> result = jsonDecode(body);
          return result['status'] == 'success';
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }
}

// ==================== CART PROVIDER ====================
class CartProvider extends ChangeNotifier {
  final List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  int get itemCount => _cartItems.length;

  double get totalAmount {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id
    );
    
    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    final index = _cartItems.indexWhere(
      (item) => item.product.id == productId
    );
    
    if (index != -1) {
      if (newQuantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}

// 30 Data produk kue
List<Product> products = [
  const Product(
    id: '1',
    name: 'Danish Blueberry',
    price: 25000,
    imageUrl: 'https://simplerecipesnow.com/wp-content/uploads/2025/11/puff-pastry-blueberry-danish.jpg',
    description: 'Danish dengan buah blueberry segar yang lezat. Tekstur pastry yang renyah di luar dan lembut di dalam, dipadukan dengan blueberry manis alami.',
    category: 'Pastry',
  ),
  const Product(
    id: '2',
    name: 'Kouign-Amann',
    price: 30000,
    imageUrl: 'https://therecipecritic.com/wp-content/uploads/2023/03/kouign-amman-667x1000.jpg',
    description: 'Kue pastry asal Prancis dengan lapisan karamel yang renyah dan legit.',
    category: 'Pastry',
  ),
  const Product(
    id: '3',
    name: 'Pain Suisse',
    price: 27000,
    imageUrl: 'https://res.cloudinary.com/hv9ssmzrz/image/fetch/c_fill,f_auto,h_976,q_auto,w_1300/https://s3-eu-west-1.amazonaws.com/images-ca-1-0-1-eu/recipe_photos/original/246798/pain_suisse_coco_choco_story1.jpg',
    description: 'Kue pastry khas Swiss dengan isian custard dan chocolate chip.',
    category: 'Pastry',
  ),
  const Product(
    id: '4',
    name: 'Chocolate Ganache Tart',
    price: 35000,
    imageUrl: 'https://cdn.mos.cms.futurecdn.net/YBLGDEGizjEQWksN8jzPKb.jpg',
    description: 'Tart dengan ganache cokelat premium yang meleleh di mulut.',
    category: 'Pastry',
  ),
  const Product(
    id: '5',
    name: 'Financier',
    price: 20000,
    imageUrl: 'https://hips.hearstapps.com/hmg-prod/images/financiers3-1663882860.jpg',
    description: 'Kue mini khas Prancis dengan rasa almond yang khas.',
    category: 'Pastry',
  ),
  const Product(
    id: '6',
    name: 'Sfogliatella',
    price: 36000,
    imageUrl: 'https://media.istockphoto.com/id/1425132352/id/foto/sfogliatella-riccia-juga-disebut-ekor-lobster-adalah-kue-italia-berisi-ricotta-berbentuk.jpg?s=612x612&w=0&k=20&c=t_BSZdoXJM2OEkqMaWKeUctcjuZvdroz0gXw0mSz5YQ=',
    description: 'Kue tradisional Italia dengan bentuk kerang dan lapisan renyah.',
    category: 'Pastry',
  ),
  const Product(
    id: '7',
    name: 'Viennoiserie',
    price: 25000,
    imageUrl: 'https://www.bonpatissier.com/hs-fs/hubfs/unnamed-Mar-24-2025-04-23-47-0324-PM.jpg?width=2500&height=1585&name=unnamed-Mar-24-2025-04-23-47-0324-PM.jpg',
    description: 'Kue pastry ala Wina dengan tekstur berlapis mentega yang lembut.',
    category: 'Pastry',
  ),
  const Product(
    id: '8',
    name: 'Almond Croissant',
    price: 28000,
    imageUrl: 'https://insanelygoodrecipes.com/wp-content/uploads/2024/12/Almond-Filled-Croissant-Cut-in-Half-on-a-Plate.jpg',
    description: 'Croissant dengan isian almond cream yang kaya rasa.',
    category: 'Pastry',
  ),
  const Product(
    id: '9',
    name: 'French Toast with Honey',
    price: 22000,
    imageUrl: 'https://cooksimpley.com/wp-content/uploads/2025/10/3.png',
    description: 'Roti panggang ala Prancis yang disiram madu asli.',
    category: 'Pastry',
  ),
  const Product(
    id: '10',
    name: 'Cinnamon Roll',
    price: 22000,
    imageUrl: 'https://cdn.pixabay.com/photo/2022/12/06/04/05/cinnamon-rolls-7638242_1280.jpg',
    description: 'Gulungan kayu manis dengan cream cheese frosting yang creamy.',
    category: 'Pastry',
  ),
  const Product(
    id: '11',
    name: 'Banana Bread',
    price: 18000,
    imageUrl: 'https://gimmethatflavor.com/wp-content/uploads/2019/10/Banana-Bread-19.jpg',
    description: 'Roti pisang lembut dengan rasa manis alami pisang.',
    category: 'Pastry',
  ),
  const Product(
    id: '12',
    name: 'Cheddar Cheese Scone',
    price: 22000,
    imageUrl: 'https://mealshine.com/wp-content/uploads/2025/08/18-Easy-Cheddar-Cheese-Scones-4.png',
    description: 'Scone gurih dengan keju cheddar berkualitas.',
    category: 'Pastry',
  ),
  const Product(
    id: '13',
    name: 'Chicken Mayo Sandwich',
    price: 30000,
    imageUrl: 'https://www.spicebangla.com/wp-content/uploads/2024/06/chicken-mayo-sandwich-grill.jpg',
    description: 'Sandwich dengan isian ayam suwir dan mayones creamy.',
    category: 'Makanan',
  ),
  const Product(
    id: '14',
    name: 'Double Chocolate Cookies',
    price: 15000,
    imageUrl: 'https://www.bunsenburnerbakery.com/wp-content/uploads/2024/12/Double-Chocolate-Chunk-Cookies-IMG_6879-1097x1536.jpg',
    description: 'Kue cokelat dengan double cokelat chunk yang meleleh.',
    category: 'Pastry',
  ),
  const Product(
    id: '15',
    name: 'Blueberry Muffin',
    price: 35000,
    imageUrl: 'https://simplyhomecooked.com/wp-content/uploads/2021/07/blueberry-muffins-10.jpg',
    description: 'Muffin lembut dengan potongan blueberry segar.',
    category: 'Pastry',
  ),
  const Product(
    id: '16',
    name: 'Orange Cake',
    price: 20000,
    imageUrl: 'https://marysplate.com/wp-content/uploads/2025/10/flourless-orange-cake.png',
    description: 'Kue jeruk dengan rasa citrus segar.',
    category: 'Cake',
  ),
  const Product(
    id: '17',
    name: 'Taro Cake',
    price: 25000,
    imageUrl: 'https://teakandthyme.com/wp-content/uploads/2023/10/ube-roll-cake-DSC_5910-1600.jpg',
    description: 'Kue taro ungu dengan rasa manis alami dan aroma khas.',
    category: 'Cake',
  ),
  const Product(
    id: '18',
    name: 'Rainbow Cake',
    price: 25000,
    imageUrl: 'https://sugargeekshow.com/wp-content/uploads/2020/03/rainbow-cake-featured-scaled.jpg',
    description: 'Kue berlapis warna-warni cerah yang cantik.',
    category: 'Cake',
  ),
  const Product(
    id: '19',
    name: 'New York Cheesecake',
    price: 55000,
    imageUrl: 'https://4recipe.com/wp-content/uploads/2025/10/creamy-new-york-cheesecake_0_20251008_000618.jpg',
    description: 'Cheesecake khas New York dengan tekstur super creamy dan padat.',
    category: 'Cake',
  ),
  const Product(
    id: '20',
    name: 'Carrot Cake',
    price: 25000,
    imageUrl: 'https://tyberrymuch.com/wp-content/uploads/2025/04/vegan-carrot-cake-feature.jpg',
    description: 'Kue wortel dengan kacang kenari dan cream cheese frosting.',
    category: 'Cake',
  ),
  const Product(
    id: '21',
    name: 'Chocolate Indulgence',
    price: 30000,
    imageUrl: 'https://4.bp.blogspot.com/-JIPoeKYLf4Y/WovUR--cI-I/AAAAAAAAJQY/63JG0iup2ysgCUt79DXpcoX6WHpV-vHZACLcBGAs/s1600/chocolate-indulgence.jpg',
    description: 'Kue cokelat dengan lapisan ganache yang mewah.',
    category: 'Cake',
  ),
  const Product(
    id: '22',
    name: 'Japanese Cotton Cheesecake',
    price: 35000,
    imageUrl: 'https://twoplaidaprons.com/wp-content/uploads/2020/07/Japanese-cotton-cheesecake-a-slice-of-cheesecake-half-pulled-out.jpg',
    description: 'Cheesecake ala Jepang dengan tekstur selembut kapas.',
    category: 'Cake',
  ),
  const Product(
    id: '23',
    name: 'Mango Cheesecake',
    price: 35000,
    imageUrl: 'https://cakeshungry.com/wp-content/uploads/2024/08/Mango-Cheesecake-683x1024.jpg',
    description: 'Cheesecake dengan topping jelly mangga segar',
    category: 'Cake',
  ),
  const Product(
    id: '24',
    name: 'Strawberry Sponge Cake',
    price: 25000,
    imageUrl: 'https://cakeshungry.com/wp-content/uploads/2024/08/Japanese-Strawberry-Sponge-Cake-Recipes-750x1125.jpg',
    description: 'Kue bolu lembut dengan lapisan krim stroberi',
    category: 'Cake',
  ),
  const Product(
    id: '25',
    name: 'Marble Cake',
    price: 20000,
    imageUrl: 'https://cakeshungry.com/wp-content/uploads/2024/06/Moist-Marble-Cake.png',
    description: 'Kue dengan pola marble dari perpaduan adonan vanilla dan cokelat.',
    category: 'Cake',
  ),
  const Product(
    id: '26',
    name: 'Oreo Cheesecake',
    price: 45000,
    imageUrl: 'https://pl.vihaad.com/wp-content/uploads/2025/10/oreo-cheesecake-recipe.jpg',
    description: 'Cheesecake dengan base Oreo dan potongan Oreo di dalamnya.',
    category: 'Cake',
  ),
  const Product(
    id: '27',
    name: 'Matcha Pudding',
    price: 18000,
    imageUrl: 'https://platesbynat.com/wp-content/uploads/2023/06/matcha_pudding_recipe-1024x1024.jpg',
    description: 'Pudding matcha premium dengan tekstur super lembut dan creamy.',
    category: 'Dessert',
  ),
  const Product(
    id: '28',
    name: 'Red Velvet Cake',
    price: 25000,
    imageUrl: 'https://cdn.pixabay.com/photo/2020/03/10/03/49/red-velvet-cake-4917734_1280.jpg',
    description: 'Kue lembut berwarna merah dengan cream cheese frosting',
    category: 'Cake',
  ),
  const Product(
    id: '29',
    name: 'Blueberry Cheesecake',
    price: 35000,
    imageUrl: 'https://wilingga.com/wp-content/uploads/2025/06/Blueberry-Cheesecake.jpg',
    description: 'Cheesecake dengan topping blueberry segar',
    category: 'Cake',
  ),
  const Product(
    id: '30',
    name: 'Cherry Cake',
    price: 25000,
    imageUrl: 'https://cakeshungry.com/wp-content/uploads/2024/05/Serving-Cherry-Cake-683x1024.png',
    description: 'Kue dengan potongan ceri manis di setiap gigitan.',
    category: 'Cake',
  ),
];

// Daftar kategori unik
List<String> getCategories() {
  final Set<String> categories = {};
  for (var product in products) {
    categories.add(product.category);
  }
  return categories.toList();
}

final CartProvider cartProvider = CartProvider();

// ==================== SCREEN: SIGNUP ====================
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'pembeli';
  String? _errorMessage;
  String? _successMessage;

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (name.isEmpty || username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Semua field harus diisi!';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Password tidak cocok!';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        _errorMessage = 'Password minimal 6 karakter!';
      });
      return;
    }

    if (users.any((u) => u.username == username)) {
      setState(() {
        _errorMessage = 'Username sudah terdaftar!';
      });
      return;
    }

    final newUser = User(
      id: DateTime.now().toString(),
      username: username,
      password: password,
      role: _selectedRole,
      name: name,
    );

    users.add(newUser);
    await StorageService.saveUsers(users);

    setState(() {
      _successMessage = 'Akun berhasil dibuat! Silakan login.';
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.brown.shade300,
              Colors.brown.shade700,
              Colors.brown.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Daftar Akun Baru',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buat akun untuk mulai berbelanja',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Nama Lengkap',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: const Icon(Icons.account_circle),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Konfirmasi Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButton<String>(
                              value: _selectedRole,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(value: 'pembeli', child: Text('Pembeli (Pelanggan)')),
                                DropdownMenuItem(value: 'kasir', child: Text('Kasir (Staff)')),
                                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedRole = value ?? 'pembeli';
                                });
                              },
                            ),
                          ),
                          if (_errorMessage != null) ...[             const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          if (_successMessage != null) ...[                            const SizedBox(height: 12),
                            Text(
                              _successMessage!,
                              style: const TextStyle(color: Colors.green),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Daftar',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.brown.shade300),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Kembali ke Login',
                                style: TextStyle(color: Colors.brown),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== SCREEN: LOGIN ====================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  void _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      final user = users.firstWhere(
        (u) => u.username == username && u.password == password,
      );
      
      currentUser = user;
      await StorageService.saveUser(user);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainMenuScreen()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Username atau password salah!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.brown.shade300,
              Colors.brown.shade700,
              Colors.brown.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bakery_dining,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Arzz Bakery',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SignupScreen()),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.brown.shade300),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Daftar Akun Baru',
                                style: TextStyle(color: Colors.brown),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Tidak punya akun? Daftar di sini',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== SCREEN: MAIN MENU ====================
class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    if (currentUser?.role == 'pembeli') {
      _screens = [
        const ProductListScreen(),
        const CartScreen(),
      ];
    } else {
      _screens = [
        const ProductListScreen(),
        const ReportScreen(),
        if (currentUser?.role == 'admin') const UserManagementScreen(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> items;
    
    if (currentUser?.role == 'pembeli') {
      items = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Menu',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Keranjang',
        ),
      ];
    } else {
      items = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Menu',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          label: 'Laporan',
        ),
        if (currentUser?.role == 'admin')
          const BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
      ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.bakery_dining),
            const SizedBox(width: 8),
            const Text('Arzz Bakery'),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    currentUser?.name ?? '',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                currentUser = null;
                await StorageService.saveUser(null);
                cartProvider.clearCart();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },
            ),
          ],
        ),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: items,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

// ==================== SCREEN: PRODUCT LIST ====================
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _selectedCategory = 'Semua';
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _categories = ['Semua', ...getCategories()];
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'Semua') {
      return products;
    }
    return products.where((p) => p.category == _selectedCategory).toList();
  }

  void _showQuantityDialog(Product product) {
    int quantity = 1;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Tambah ${product.name}'),
        content: StatefulBuilder(
          builder: (context, setStateDialog) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Masukkan jumlah:'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setStateDialog(() {
                          if (quantity > 1) quantity--;
                        });
                      },
                    ),
                    Container(
                      width: 60,
                      alignment: Alignment.center,
                      child: Text(
                        quantity.toString(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setStateDialog(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              cartProvider.addToCart(product, quantity: quantity);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} x$quantity ditambahkan'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.brown.shade100, Colors.brown.shade50],
              ),
            ),
            child: Column(
              children: [
                const Text(
                  '✨ Simply Pastry, Simply Happy ✨',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@arzzbakery - Kue Lezat Untuk Setiap Momen',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.brown.shade700,
                  ),
                ),
              ],
            ),
          ),
          // Filter Kategori
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey.shade200,
                    selectedColor: Colors.brown.shade100,
                    checkmarkColor: Colors.brown,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.brown : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.no_food, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada produk di kategori ini',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ProductCard(
                        product: product,
                        onAddToCart: () => _showQuantityDialog(product),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            backgroundColor: Colors.brown,
            child: const Icon(Icons.shopping_cart, color: Colors.white),
          ),
          ListenableBuilder(
            listenable: cartProvider,
            builder: (context, _) {
              if (cartProvider.itemCount > 0) {
                return Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;
  
  const ProductCard({
    super.key, 
    required this.product,
    required this.onAddToCart,
  });

  void _showProductDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        product.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.brown.shade100,
                            child: const Icon(Icons.cake, size: 60),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description,
                    style: TextStyle(color: Colors.grey.shade600, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(color: Colors.brown.shade700),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rp ${product.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        onAddToCart();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Tambah ke Keranjang'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProductDetailDialog(context),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: Colors.brown.shade50,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.brown.shade100,
                        child: const Icon(Icons.cake, size: 50),
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.brown.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.brown.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Rp ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.brown,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onAddToCart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Icon(Icons.add, size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SCREEN: CART ====================
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _tableNumberController = TextEditingController();
  bool _isLoading = false;

  void _checkout() async {
    if (cartProvider.cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Keranjang kosong!')),
      );
      return;
    }

    if (_customerNameController.text.isEmpty ||
        _tableNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan isi nama pelanggan dan nomor meja')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final bool success = await GoogleSheetsService.sendOrderToSheet(
      cartProvider.cartItems,
      cartProvider.totalAmount,
      _customerNameController.text,
      _tableNumberController.text,
      _selectedPaymentMethod,
    );

    setState(() => _isLoading = false);

    if (success) {
      // Simpan order ke history
      final order = Order(
        id: DateTime.now().toString(),
        customerName: _customerNameController.text,
        tableNumber: _tableNumberController.text,
        paymentMethod: _selectedPaymentMethod.displayName,
        totalAmount: cartProvider.totalAmount,
        timestamp: DateTime.now(),
        items: List.from(cartProvider.cartItems),
        kasirName: currentUser?.name ?? '',
      );
      await StorageService.addOrder(order);

      cartProvider.clearCart();
      _customerNameController.clear();
      _tableNumberController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pesanan berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuat pesanan. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: cartProvider,
        builder: (context, _) {
          return cartProvider.cartItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Keranjang kosong',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: cartProvider.cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartProvider.cartItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Rp ${item.product.price.toStringAsFixed(0)}',
                                          style: TextStyle(color: Colors.grey.shade600),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 16),
                                        onPressed: () {
                                          if (item.quantity > 1) {
                                            cartProvider.updateQuantity(item.product.id, item.quantity - 1);
                                          }
                                        },
                                      ),
                                      Container(
                                        width: 40,
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 16),
                                        onPressed: () {
                                          cartProvider.updateQuantity(item.product.id, item.quantity + 1);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: () {
                                          cartProvider.removeFromCart(item.product.id);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _customerNameController,
                            decoration: InputDecoration(
                              labelText: 'Nama Pelanggan',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _tableNumberController,
                            decoration: InputDecoration(
                              labelText: 'Nomor Meja',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.table_restaurant),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Metode Pembayaran:',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: PaymentMethod.values.map((method) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: ChoiceChip(
                                    label: Text(method.displayName),
                                    selected: _selectedPaymentMethod == method,
                                    onSelected: (selected) {
                                      if (selected) {
                                        setState(() => _selectedPaymentMethod = method);
                                      }
                                    },
                                    selectedColor: Colors.brown,
                                    labelStyle: TextStyle(
                                      color: _selectedPaymentMethod == method ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Rp ${cartProvider.totalAmount.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.brown,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _checkout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                disabledBackgroundColor: Colors.grey,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text('Checkout'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _tableNumberController.dispose();
    super.dispose();
  }
}

// ==================== SCREEN: REPORT ====================
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  late List<Order> _filteredOrders;
  int _selectedReportType = 0; // 0=Daily, 1=Weekly, 2=Monthly, 3=Yearly
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _applyFilter();
  }

  void _applyFilter() {
    setState(() {
      switch (_selectedReportType) {
        case 0: // Daily
          _filteredOrders = _getOrdersByDay(_selectedDate);
          break;
        case 1: // Weekly
          _filteredOrders = _getOrdersByWeek(_selectedDate);
          break;
        case 2: // Monthly
          _filteredOrders = _getOrdersByMonth(_selectedDate);
          break;
        case 3: // Yearly
          _filteredOrders = _getOrdersByYear(_selectedDate);
          break;
      }
    });
  }

  List<Order> _getOrdersByDay(DateTime date) {
    return orderHistory
        .where((order) =>
            order.timestamp.year == date.year &&
            order.timestamp.month == date.month &&
            order.timestamp.day == date.day)
        .toList();
  }

  List<Order> _getOrdersByWeek(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return orderHistory
        .where((order) =>
            order.timestamp.isAfter(startOfWeek) &&
            order.timestamp.isBefore(endOfWeek.add(const Duration(days: 1))))
        .toList();
  }

  List<Order> _getOrdersByMonth(DateTime date) {
    return orderHistory
        .where((order) =>
            order.timestamp.year == date.year &&
            order.timestamp.month == date.month)
        .toList();
  }

  List<Order> _getOrdersByYear(DateTime date) {
    return orderHistory
        .where((order) => order.timestamp.year == date.year)
        .toList();
  }

  String _getDateRangeText() {
    switch (_selectedReportType) {
      case 0:
        return 'Tanggal: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
      case 1:
        final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return 'Minggu: ${startOfWeek.day}/${startOfWeek.month} - ${endOfWeek.day}/${endOfWeek.month}/${endOfWeek.year}';
      case 2:
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        return 'Bulan: ${months[_selectedDate.month - 1]} ${_selectedDate.year}';
      case 3:
        return 'Tahun: ${_selectedDate.year}';
      default:
        return '';
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _selectedDate = picked;
      _applyFilter();
    }
  }

  Map<String, double> _getRevenueByProduct() {
    Map<String, double> revenue = {};
    for (var order in _filteredOrders) {
      for (var item in order.items) {
        revenue[item.product.name] = (revenue[item.product.name] ?? 0) + item.totalPrice;
      }
    }
    return revenue;
  }

  Map<String, int> _getOrderCountByPaymentMethod() {
    Map<String, int> count = {};
    for (var order in _filteredOrders) {
      count[order.paymentMethod] = (count[order.paymentMethod] ?? 0) + 1;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Report Type Selector
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.brown.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pilih Jenis Laporan:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<int>(
                          segments: const [
                            ButtonSegment(label: Text('Harian'), value: 0),
                            ButtonSegment(label: Text('Mingguan'), value: 1),
                            ButtonSegment(label: Text('Bulanan'), value: 2),
                            ButtonSegment(label: Text('Tahunan'), value: 3),
                          ],
                          selected: {_selectedReportType},
                          onSelectionChanged: (Set<int> newSelection) {
                            _selectedReportType = newSelection.first;
                            _applyFilter();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_getDateRangeText()),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Summary Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Pesanan',
                      '${_filteredOrders.length}',
                      Icons.shopping_cart,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Pendapatan',
                      'Rp ${_filteredOrders.fold(0.0, (sum, order) => sum + order.totalAmount).toStringAsFixed(0)}',
                      Icons.attach_money,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            // Payment Method Distribution
            if (_getOrderCountByPaymentMethod().isNotEmpty)
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Distribusi Metode Pembayaran',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ..._getOrderCountByPaymentMethod().entries.map((entry) {
                        final percentage = (_getOrderCountByPaymentMethod()[entry.key]! /
                            _filteredOrders.length *
                            100);
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key),
                                  Text('${entry.value} (${percentage.toStringAsFixed(1)}%)'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    entry.key == 'QRIS' ? Colors.blue : Colors.green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            // Top Products
            if (_getRevenueByProduct().isNotEmpty)
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Produk dengan Penjualan Tertinggi',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      ..._getRevenueByProduct()
                          .entries
                          .toList()
                          .asMap()
                          .entries
                          .take(5)
                          .map((mapEntry) {
                        final index = mapEntry.key;
                        final entry = mapEntry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.brown.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Rp ${entry.value.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            // Detail Orders List
            if (_filteredOrders.isNotEmpty)
              Card(
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: const Text(
                        'Detail Pesanan',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];
                        return ExpansionTile(
                          title: Text('Pesanan #${index + 1} - ${order.customerName}'),
                          subtitle: Text(
                            '${order.timestamp.day}/${order.timestamp.month}/${order.timestamp.year} - Rp ${order.totalAmount.toStringAsFixed(0)}',
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('Meja', order.tableNumber),
                                  _buildDetailRow('Metode Pembayaran', order.paymentMethod),
                                  _buildDetailRow('Kasir', order.kasirName),
                                  _buildDetailRow('Waktu', '${order.timestamp.hour}:${order.timestamp.minute.toString().padLeft(2, '0')}'),
                                  const Divider(),
                                  const Text('Detail Item:', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  ...order.items.map((item) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text('${item.product.name} x${item.quantity}'),
                                        ),
                                        Text(
                                          'Rp ${item.totalPrice.toStringAsFixed(0)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada pesanan untuk periode ini',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          Expanded(
            flex: 1,
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

// ==================== SCREEN: USER MANAGEMENT ====================
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.brown.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person, color: Colors.brown),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(
                              '${user.username} (${user.role})',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
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