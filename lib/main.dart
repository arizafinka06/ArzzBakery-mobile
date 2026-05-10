import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
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
      ),
      home: const ProductListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

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

// Daftar kategori unik
List<String> getCategories() {
  final Set<String> categories = {};
  for (var product in products) {
    categories.add(product.category);
  }
  return categories.toList();
}

// 30 Data produk kue
List<Product> products = [
  const Product(
    id: '1',
    name: 'Danish Blueberry',
    price: 25000,
    imageUrl: 'https://simplerecipesnow.com/wp-content/uploads/2025/11/puff-pastry-blueberry-danish.jpg',
    description: 'Danish dengan buah blueberry segar yang lezat. Tekstur pastry yang renyah di luar dan lembut di dalam, dipadukan dengan blueberry manis alami. Cocok untuk teman minum teh di pagi hari.',
    category: 'Pastry',
  ),
  const Product(
    id: '2',
    name: 'Kouign-Amann',
    price: 30000,
    imageUrl: 'https://therecipecritic.com/wp-content/uploads/2023/03/kouign-amman-667x1000.jpg',
    description: 'Kue pastry asal Prancis dengan lapisan karamel yang renyah dan legit. Terbuat dari adonan berlapis mentega dan gula yang dipanggang hingga karamelisasi sempurna.',
    category: 'Pastry',
  ),
  const Product(
    id: '3',
    name: 'Pain Suisse',
    price: 27000,
    imageUrl: 'https://res.cloudinary.com/hv9ssmzrz/image/fetch/c_fill,f_auto,h_976,q_auto,w_1300/https://s3-eu-west-1.amazonaws.com/images-ca-1-0-1-eu/recipe_photos/original/246798/pain_suisse_coco_choco_story1.jpg',
    description: 'Kue pastry khas Swiss dengan isian custard dan chocolate chip. Tekstur lembut dan rasa manis yang pas, cocok untuk sarapan atau camilan sore.',
    category: 'Pastry',
  ),
  const Product(
    id: '4',
    name: 'Chocolate Ganache Tart',
    price: 35000,
    imageUrl: 'https://cdn.mos.cms.futurecdn.net/YBLGDEGizjEQWksN8jzPKb.jpg',
    description: 'Tart dengan ganache cokelat premium yang meleleh di mulut. Basis tart yang renyah berpadu sempurna dengan ganache cokelat hitam yang kaya rasa.',
    category: 'Pastry',
  ),
  const Product(
    id: '5',
    name: 'Financier',
    price: 20000,
    imageUrl: 'https://hips.hearstapps.com/hmg-prod/images/financiers3-1663882860.jpg?crop=1.00xw:0.737xh;0,0&resize=980:*',
    description: 'Kue mini khas Prancis dengan rasa almond yang khas dan tekstur lembut. Dibuat dengan tepung almond, mentega brown butter, dan putih telur.',
    category: 'Pastry',
  ),
  const Product(
    id: '6',
    name: 'Sfogliatella',
    price: 36000,
    imageUrl: 'https://media.istockphoto.com/id/490639574/id/foto/neapolitan-sfogliatella-riccia-wikipedia.jpg?s=612x612&w=0&k=20&c=EdYMPqRaxssMjBxgdwcNwwUKTp1BLIzPEX7Z3iv7ghY=',
    description: 'Kue tradisional Italia dengan bentuk kerang dan lapisan renyah berlapis-lapis. Isiannya terbuat dari ricotta, semolina, dan manisan buah.',
    category: 'Pastry',
  ),
  const Product(
    id: '7',
    name: 'Viennoiserie',
    price: 25000,
    imageUrl: 'https://media.istockphoto.com/id/1202979235/id/foto/viennoiserie-perancis-karya-seni-dari-koki-kue.jpg?s=170667a&w=0&k=20&c=NZPkyjOjBBK-veRhDB_b1D-yJq0VxmgqPMKl9Es2OrU=',
    description: 'Kue pastry ala Wina dengan tekstur berlapis mentega yang lembut. Perpaduan sempurna antara croissant dan brioche.',
    category: 'Pastry',
  ),
  const Product(
    id: '8',
    name: 'Almond Croissant',
    price: 28000,
    imageUrl: 'https://insanelygoodrecipes.com/wp-content/uploads/2024/12/Almond-Filled-Croissant-Cut-in-Half-on-a-Plate.jpg',
    description: 'Croissant dengan isian almond cream yang kaya rasa, ditaburi irisan almond panggang. Renyah di luar, lembut di dalam.',
    category: 'Pastry',
  ),
  const Product(
    id: '9',
    name: 'French Toast with Honey',
    price: 22000,
    imageUrl: 'https://cooksimpley.com/wp-content/uploads/2025/10/3.png',
    description: 'Roti panggang ala Prancis yang disiram madu asli. Tekstur lembut dengan rasa manis alami madu, cocok untuk sarapan istimewa.',
    category: 'Pastry',
  ),
  const Product(
    id: '10',
    name: 'Cinnamon Roll',
    price: 22000,
    imageUrl: 'https://cdn.pixabay.com/photo/2022/12/06/04/05/cinnamon-rolls-7638242_1280.jpg',
    description: 'Gulungan kayu manis dengan cream cheese frosting yang creamy. Aroma kayu manis yang harum berpadu dengan rasa manis yang pas.',
    category: 'Pastry',
  ),
  const Product(
    id: '11',
    name: 'Banana Bread',
    price: 18000,
    imageUrl: 'https://gimmethatflavor.com/wp-content/uploads/2019/10/Banana-Bread-19.jpg',
    description: 'Roti pisang lembut dengan rasa manis alami pisang. Tekstur moist dan cocok dinikmati kapan saja.',
    category: 'Pastry',
  ),
  const Product(
    id: '12',
    name: 'Cheddar Cheese Scone',
    price: 22000,
    imageUrl: 'https://mealshine.com/wp-content/uploads/2025/08/18-Easy-Cheddar-Cheese-Scones-4.png',
    description: 'Scone gurih dengan keju cheddar berkualitas. Tekstur renyah di luar dan lembut di dalam, cocok untuk camilan sore.',
    category: 'Pastry',
  ),
  const Product(
    id: '13',
    name: 'Chicken Mayo Sandwich',
    price: 30000,
    imageUrl: 'https://www.spicebangla.com/wp-content/uploads/2024/06/chicken-mayo-sandwich-grill.jpg',
    description: 'Sandwich dengan isian ayam suwir dan mayones creamy. Dilengkapi dengan selada segar dan roti gandum yang lembut.',
    category: 'Makanan',
  ),
  const Product(
    id: '14',
    name: 'Double Chocolate Cookies',
    price: 15000,
    imageUrl: 'https://www.bunsenburnerbakery.com/wp-content/uploads/2024/12/Double-Chocolate-Chunk-Cookies-IMG_6879-1097x1536.jpg',
    description: 'Kue cokelat dengan double cokelat chunk yang meleleh. Renyah di pinggir, lembut di tengah.',
    category: 'Pastry',
  ),
  const Product(
    id: '15',
    name: 'Blueberry Muffin',
    price: 35000,
    imageUrl: 'https://simplyhomecooked.com/wp-content/uploads/2021/07/blueberry-muffins-10.jpg',
    description: 'Muffin lembut dengan potongan blueberry segar. Topping streusel yang renyah menambah kenikmatan.',
    category: 'Pastry',
  ),
  const Product(
    id: '16',
    name: 'Orange Cake',
    price: 20000,
    imageUrl: 'https://marysplate.com/wp-content/uploads/2025/10/flourless-orange-cake.png',
    description: 'Kue jeruk dengan rasa citrus segar. Tekstur lembut dan moist, dibuat dengan jus jeruk asli dan parutan kulit jeruk.',
    category: 'Cake',
  ),
  const Product(
    id: '17',
    name: 'Taro Cake',
    price: 25000,
    imageUrl: 'https://teakandthyme.com/wp-content/uploads/2023/10/ube-roll-cake-DSC_5910-1600.jpg',
    description: 'Kue taro ungu dengan rasa manis alami dan aroma khas. Lembut dan creamy, cocok untuk pecinta ube.',
    category: 'Cake',
  ),
  const Product(
    id: '18',
    name: 'Rainbow Cake',
    price: 25000,
    imageUrl: 'https://sugargeekshow.com/wp-content/uploads/2020/03/rainbow-cake-featured-scaled.jpg',
    description: 'Kue berlapis warna-warni cerah yang cantik. Setiap lapisan memiliki rasa vanilla yang lembut dengan buttercream yang creamy.',
    category: 'Cake',
  ),
  const Product(
    id: '19',
    name: 'New York Cheesecake',
    price: 55000,
    imageUrl: 'https://4recipe.com/wp-content/uploads/2025/10/creamy-new-york-cheesecake_0_20251008_000618.jpg',
    description: 'Cheesecake khas New York dengan tekstur super creamy dan padat. Topping sour cream memberikan rasa asam segar yang khas.',
    category: 'Cake',
  ),
  const Product(
    id: '20',
    name: 'Carrot Cake',
    price: 25000,
    imageUrl: 'https://tyberrymuch.com/wp-content/uploads/2025/04/vegan-carrot-cake-feature.jpg',
    description: 'Kue wortel dengan kacang kenari dan cream cheese frosting. Manis alami dari wortel berpadu dengan rempah kayu manis.',
    category: 'Cake',
  ),
  const Product(
    id: '21',
    name: 'Chocolate Indulgence',
    price: 30000,
    imageUrl: 'https://4.bp.blogspot.com/-JIPoeKYLf4Y/WovUR--cI-I/AAAAAAAAJQY/63JG0iup2ysgCUt79DXpcoX6WHpV-vHZACLcBGAs/s1600/chocolate-indulgence.jpg',
    description: 'Kue cokelat dengan lapisan ganache yang mewah. Untuk pecinta cokelat sejati, setiap gigitan adalah kenikmatan.',
    category: 'Cake',
  ),
  const Product(
    id: '22',
    name: 'Japanese Cotton Cheesecake',
    price: 35000,
    imageUrl: 'https://twoplaidaprons.com/wp-content/uploads/2020/07/Japanese-cotton-cheesecake-a-slice-of-cheesecake-half-pulled-out.jpg',
    description: 'Cheesecake ala Jepang dengan tekstur selembut kapas. Ringan, lembut, dan tidak terlalu manis.',
    category: 'Cake',
  ),
  const Product(
    id: '23',
    name: 'Mango Cheesecake',
    price: 35000,
    imageUrl: 'https://cakeshungry.com/wp-content/uploads/2024/08/Mango-Cheesecake-683x1024.jpg',
    description: 'Cheesecake tanpa panggang dengan lapisan base biskuit renyah, cream cheese premium yang creamy, dan topping jelly mangga segar serta potongan mangga asli. Perpaduan sempurna antara creamy, manis, dan segar',
    category: 'Cake',
  ),
  const Product(
    id: '24',
    name: 'Strawberry Sponge Cake',
    price: 25000,
    imageUrl: 'https://cakeshungry.com/wp-content/uploads/2024/08/Japanese-Strawberry-Sponge-Cake-Recipes-750x1125.jpg',
    description: 'Kue bolu lembut dengan lapisan krim stroberi dan potongan stroberi segar. Ringan dan menyegarkan.',
    category: 'Cake',
  ),
  const Product(
    id: '25',
    name: 'Marble Cake',
    price: 20000,
    imageUrl: 'https://cakeshungry.com/wp-content/uploads/2024/06/Moist-Marble-Cake.png',
    description: 'Kue dengan pola marble dari perpaduan adonan vanilla dan cokelat. Tekstur moist dengan rasa yang seimbang.',
    category: 'Cake',
  ),
  const Product(
    id: '26',
    name: 'Oreo Cheesecake',
    price: 45000,
    imageUrl: 'https://pl.vihaad.com/wp-content/uploads/2025/10/oreo-cheesecake-recipe.jpg',
    description: 'Cheesecake dengan base Oreo dan potongan Oreo di dalamnya. Cocok untuk penggemar Oreo dan cheesecake.',
    category: 'Cake',
  ),
  const Product(
    id: '27',
    name: 'Matcha Pudding',
    price: 18000,
    imageUrl: 'https://platesbynat.com/wp-content/uploads/2023/06/matcha_pudding_recipe-1024x1024.jpg',
    description: 'Pudding matcha premium dengan tekstur super lembut dan creamy. Perpaduan pahit matcha autentik dengan manisnya susu.',
    category: 'Dessert',
  ),
  const Product(
    id: '28',
    name: 'Red Velvet Cake',
    price: 25000,
    imageUrl: 'https://cdn.pixabay.com/photo/2020/03/10/03/49/red-velvet-cake-4917734_1280.jpg',
    description: 'Kue lembut berwarna merah dengan cream cheese frosting yang creamy. Perpaduan sempurna antara manis dan sedikit asam',
    category: 'Cake',
  ),
  const Product(
    id: '29',
    name: 'Blueberry Cheesecake',
    price: 35000,
    imageUrl: 'https://wilingga.com/wp-content/uploads/2025/06/Blueberry-Cheesecake.jpg',
    description: 'Cheesecake dengan topping blueberry segar dan saus blueberry. Rasa asam segar blueberry berpadu dengan creamy cheesecake.',
    category: 'Cake',
  ),
  const Product(
    id: '30',
    name: 'Cherry Cake',
    price: 25000,
    imageUrl: 'https://cakeshungry.com/wp-content/uploads/2024/05/Serving-Cherry-Cake-683x1024.png',
    description: 'Kue dengan potongan ceri manis di setiap gigitan. Lembut dan harum dengan rasa buah ceri yang autentik.',
    category: 'Cake',
  ),
];

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

      debugPrint('📤 Mengirim ke: $uri');

      final response = await http.get(uri).timeout(const Duration(seconds: 30));

      debugPrint('✅ Status: ${response.statusCode}');
      debugPrint('📨 Body: ${response.body}');

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
      debugPrint('❌ Error mengirim pesanan: $e');
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

// ==================== GLOBAL PROVIDER INSTANCE ====================
final cartProvider = CartProvider();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Arzz Bakery',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CartScreen(),
                    ),
                  );
                },
              ),
              ListenableBuilder(
                listenable: cartProvider,
                builder: (context, _) {
                  if (cartProvider.itemCount > 0) {
                    return Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
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
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.brown.shade100,
            padding: const EdgeInsets.symmetric(vertical: 12),
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
                      return ProductCard(product: product);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showProductDetailDialog(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  product.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      color: Colors.brown.shade100,
                      child: Icon(
                        Icons.cake,
                        size: 60,
                        color: Colors.brown.shade300,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: double.infinity,
                      color: Colors.brown.shade100,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp${product.price.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown.shade700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showQuantityDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                      ),
                      child: const Text('Tambah'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductDetailDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.brown.shade600),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
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
                        child: Icon(Icons.cake, size: 60, color: Colors.brown.shade300),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.brown.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Kategori: ${product.category}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.brown.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  product.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Harga',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Rp${product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.brown.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.grey.shade400,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Tutup'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _showQuantityDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Pesan Sekarang'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
  
  void _showQuantityDialog(BuildContext context) {
    int quantity = 1;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (stateContext, setState) {
          return AlertDialog(
            title: const Text('Pilih Jumlah'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          quantity = quantity > 1 ? quantity - 1 : 1;
                        });
                      },
                    ),
                    Container(
                      width: 60,
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        '$quantity',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Total: Rp${(product.price * quantity).toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                ),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  cartProvider.addToCart(product, quantity: quantity);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${product.name} x$quantity ditambahkan'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tambahkan'),
              ),
            ],
          );
        }
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
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tableController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: cartProvider,
        builder: (context, _) {
          final cart = cartProvider;
          
          if (cart.cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Keranjang masih kosong',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                    ),
                    child: const Text('Belanja Sekarang'),
                  ),
                ],
              ),
            );
          }
          
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: cart.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cart.cartItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.brown.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.cake, color: Colors.brown.shade300);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Rp${item.product.price.toStringAsFixed(0)}',
                                    style: TextStyle(color: Colors.brown.shade600),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 20),
                                  onPressed: () {
                                    cart.updateQuantity(
                                      item.product.id,
                                      item.quantity - 1,
                                    );
                                  },
                                ),
                                Container(
                                  width: 35,
                                  alignment: Alignment.center,
                                  child: Text('${item.quantity}'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  onPressed: () {
                                    cart.updateQuantity(
                                      item.product.id,
                                      item.quantity + 1,
                                    );
                                  },
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                cart.removeFromCart(item.product.id);
                              },
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
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 8,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Nama Pemesan',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tableController,
                      decoration: InputDecoration(
                        hintText: 'Nomor Meja',
                        prefixIcon: const Icon(Icons.table_restaurant),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Metode Pembayaran',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: PaymentMethod.values.map((method) {
                              final bool selected = _selectedPaymentMethod == method;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedPaymentMethod = method;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: selected ? Colors.brown.shade50 : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: selected ? Colors.brown : Colors.transparent,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          margin: const EdgeInsets.only(right: 6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: selected ? Colors.brown : Colors.grey,
                                              width: 2,
                                            ),
                                          ),
                                          child: selected
                                              ? Center(
                                                  child: Container(
                                                    width: 10,
                                                    height: 10,
                                                    decoration: const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: Colors.brown,
                                                    ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                        Icon(method.icon, size: 16,
                                          color: selected ? Colors.brown : Colors.grey.shade700),
                                        const SizedBox(width: 4),
                                        Text(
                                          method.displayName,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: selected ? Colors.brown : Colors.grey.shade700,
                                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          if (_selectedPaymentMethod == PaymentMethod.qris) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Scan QRIS code pada saat pembayaran',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Pesanan',
                              style: TextStyle(color: Colors.grey),
                            ),
                            Text(
                              'Rp${cart.totalAmount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: _isProcessing ? null : () => _processCheckout(context, cart),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: _isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Pesan Sekarang'),
                        ),
                      ],
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
  
  Future<void> _processCheckout(BuildContext context, CartProvider cart) async {
    if (_nameController.text.isEmpty || _tableController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon isi nama pemesan dan nomor meja'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() => _isProcessing = true);

    final customerName = _nameController.text;
    final tableNumber = _tableController.text;
    final paymentMethod = _selectedPaymentMethod;
    final cartItems = List<CartItem>.from(cart.cartItems);
    final totalAmount = cart.totalAmount;

    final bool success = await GoogleSheetsService.sendOrderToSheet(
      cartItems,
      totalAmount,
      customerName,
      tableNumber,
      paymentMethod,
    );

    setState(() => _isProcessing = false);

    _showResult(
      navigator: navigator,
      scaffoldMessenger: scaffoldMessenger,
      success: success,
      cart: cart,
      customerName: customerName,
      tableNumber: tableNumber,
      paymentMethod: paymentMethod,
      cartItems: cartItems,
      totalAmount: totalAmount,
    );
  }

  void _showResult({
    required NavigatorState navigator,
    required ScaffoldMessengerState scaffoldMessenger,
    required bool success,
    required CartProvider cart,
    required String customerName,
    required String tableNumber,
    required PaymentMethod paymentMethod,
    required List<CartItem> cartItems,
    required double totalAmount,
  }) {
    if (success) {
      navigator.push(
        MaterialPageRoute(
          builder: (_) => _OrderSuccessDialog(
            customerName: customerName,
            tableNumber: tableNumber,
            paymentMethod: paymentMethod,
            cartItems: cartItems,
            totalAmount: totalAmount,
            onConfirm: () {
              cart.clearCart();
              _nameController.clear();
              _tableController.clear();
              navigator.pop();
              navigator.pop();
            },
          ),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim pesanan. Periksa koneksi dan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _tableController.dispose();
    super.dispose();
  }
}

// ==================== SCREEN: ORDER SUCCESS ====================
class _OrderSuccessDialog extends StatelessWidget {
  final String customerName;
  final String tableNumber;
  final PaymentMethod paymentMethod;
  final List<CartItem> cartItems;
  final double totalAmount;
  final VoidCallback onConfirm;

  const _OrderSuccessDialog({
    required this.customerName,
    required this.tableNumber,
    required this.paymentMethod,
    required this.cartItems,
    required this.totalAmount,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_rounded,
                  size: 70, color: Colors.green.shade600),
              ),
              const SizedBox(height: 24),
              const Text(
                '🎉 Pesanan Berhasil!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Terima kasih, $customerName!',
                style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.brown.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.brown.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoRow(Icons.table_restaurant, 'Meja', tableNumber),
                    const SizedBox(height: 8),
                    _infoRow(Icons.payment, 'Pembayaran', paymentMethod.displayName),
                    const Divider(height: 20),
                    ...cartItems.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${item.product.name} x${item.quantity}')),
                          Text('Rp${item.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('Rp${totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold,
                            fontSize: 16, color: Colors.brown)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Kembali ke Menu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.brown.shade600),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: Colors.grey.shade600)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}