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

// 30 Data produk kue
List<Product> products = [
  const Product(
    id: '1',
    name: 'Danish Blueberry',
    price: 25000,
    imageUrl: 'https://simplerecipesnow.com/wp-content/uploads/2025/11/puff-pastry-blueberry-danish.jpg',
    description: 'Danish dengan buah blueberry yang lezat',
    category: 'Pastry',
  ),
  const Product(
    id: '2',
    name: 'Kouign-Amann',
    price: 30000,
    imageUrl: 'https://therecipecritic.com/wp-content/uploads/2023/03/kouign-amman-667x1000.jpg',
    description: 'Kue Prancis dengan lapisan yang renyah',
    category: 'Pastry',
  ),
  const Product(
    id: '3',
    name: 'Pain Suisse',
    price: 27000,
    imageUrl: 'https://res.cloudinary.com/hv9ssmzrz/image/fetch/c_fill,f_auto,h_976,q_auto,w_1300/https://s3-eu-west-1.amazonaws.com/images-ca-1-0-1-eu/recipe_photos/original/246798/pain_suisse_coco_choco_story1.jpg',
    description: 'Kue Prancis dengan tekstur lembut dan rasa manis',
    category: 'Pastry',
  ),
  const Product(
    id: '4',
    name: 'Chocolate Ganache Tart',
    price: 35000,
    imageUrl: 'https://cdn.mos.cms.futurecdn.net/YBLGDEGizjEQWksN8jzPKb.jpg',
    description: 'Tart dengan ganache cokelat yang lezat',
    category: 'Pastry',
  ),
  const Product(
    id: '5',
    name: 'Financier',
    price: 20000,
    imageUrl: 'https://hips.hearstapps.com/hmg-prod/images/financiers3-1663882860.jpg?crop=1.00xw:0.737xh;0,0&resize=980:*',
    description: 'Kue cokelat lembut dengan rasa khas',
    category: 'Pastry',
  ),
  const Product(
    id: '6',
    name: 'Sfogliatella',
    price: 36000,
    imageUrl: 'https://media.istockphoto.com/id/490639574/id/foto/neapolitan-sfogliatella-riccia-wikipedia.jpg?s=612x612&w=0&k=20&c=EdYMPqRaxssMjBxgdwcNwwUKTp1BLIzPEX7Z3iv7ghY=',
    description: 'Kue Italia dengan tekstur renyah dan rasa manis',
    category: 'Pastry',
  ),
  const Product(
    id: '7',
    name: 'Viennoiserie',
    price: 25000,
    imageUrl: 'https://media.istockphoto.com/id/1202979235/id/foto/viennoiserie-perancis-karya-seni-dari-koki-kue.jpg?s=170667a&w=0&k=20&c=NZPkyjOjBBK-veRhDB_b1D-yJq0VxmgqPMKl9Es2OrU=',
    description: 'Kue Prancis dengan tekstur lembut dan rasa manis',
    category: 'Pastry',
  ),
  const Product(
    id: '8',
    name: 'Almond Croissant',
    price: 28000,
    imageUrl: 'https://insanelygoodrecipes.com/wp-content/uploads/2024/12/Almond-Filled-Croissant-Cut-in-Half-on-a-Plate.jpg',
    description: 'Croissant dengan isian almond yang renyah',
    category: 'Pastry',
  ),
  const Product(
    id: '9',
    name: 'French Toast with Honey',
    price: 22000,
    imageUrl: 'https://cooksimpley.com/wp-content/uploads/2025/10/3.png',
    description: 'French toast dengan sirup madu yang lezat',
    category: 'Pastry',
  ),
  const Product(
    id: '10',
    name: 'Cinnamon Roll',
    price: 22000,
    imageUrl: 'https://cdn.pixabay.com/photo/2022/12/06/04/05/cinnamon-rolls-7638242_1280.jpg',
    description: 'Cinnamon roll dengan rasa manis dan karamel',
    category: 'Pastry',
  ),
  const Product(
    id: '11',
    name: 'Banana Bread',
    price: 18000,
    imageUrl: 'https://gimmethatflavor.com/wp-content/uploads/2019/10/Banana-Bread-19.jpg',
    description: 'Roti pisang lembut dengan rasa manis',
    category: 'Pastry',
  ),
  const Product(
    id: '12',
    name: 'Cheddar Cheese Scone',
    price: 22000,
    imageUrl: 'https://mealshine.com/wp-content/uploads/2025/08/18-Easy-Cheddar-Cheese-Scones-4.png',
    description: 'Scone dengan keju cheddar yang lezat',
    category: 'Pastry',
  ),
  const Product(
    id: '13',
    name: 'Chicken Mayo Sandwich',
    price: 30000,
    imageUrl: 'https://www.spicebangla.com/wp-content/uploads/2024/06/chicken-mayo-sandwich-grill.jpg',
    description: 'Sandwich ayam dengan mayones yang lezat',
    category: 'Makanan',
  ),
  const Product(
    id: '14',
    name: 'Double Chocolate Cookies',
    price: 15000,
    imageUrl: 'https://www.bunsenburnerbakery.com/wp-content/uploads/2024/12/Double-Chocolate-Chunk-Cookies-IMG_6879-1097x1536.jpg',
    description: 'Kue cokelat ganda yang lezat',
    category: 'Pastry',
  ),
  const Product(
    id: '15',
    name: 'Blueberry Muffin',
    price: 35000,
    imageUrl: 'https://simplyhomecooked.com/wp-content/uploads/2021/07/blueberry-muffins-10.jpg',
    description: 'Muffin blueberry yang lezat',
    category: 'Pastry',
  ),
  const Product(
    id: '16',
    name: 'Orange Cake',
    price: 20000,
    imageUrl: 'https://marysplate.com/wp-content/uploads/2025/10/flourless-orange-cake.png',
    description: 'Kue jeruk yang lezat dan lembut',
    category: 'Cake',
  ),
  const Product(
    id: '17',
    name: 'Taro Cake',
    price: 25000,
    imageUrl: 'https://teakandthyme.com/wp-content/uploads/2023/10/ube-roll-cake-DSC_5910-1600.jpg',
    description: 'Kue taro yang lezat dan lembut',
    category: 'Cake',
  ),
  const Product(
    id: '18',
    name: 'Rainbow Cake',
    price: 25000,
    imageUrl: 'https://sugargeekshow.com/wp-content/uploads/2020/03/rainbow-cake-featured-scaled.jpg',
    description: 'Kue berlapis dengan warna-warna cerah',
    category: 'Cake',
  ),
  const Product(
    id: '19',
    name: 'New York Cheesecake',
    price: 55000,
    imageUrl: 'https://4recipe.com/wp-content/uploads/2025/10/creamy-new-york-cheesecake_0_20251008_000618.jpg',
    description: 'Cheesecake khas New York yang lezat',
    category: 'Cake',
  ),
  const Product(
    id: '20',
    name: 'Carrot Cake',
    price: 25000,
    imageUrl: 'https://tyberrymuch.com/wp-content/uploads/2025/04/vegan-carrot-cake-feature.jpg',
    description: 'Kue wortel yang lezat dan lembut',
    category: 'Cake',
  ),
  const Product(
    id: '21',
    name: 'Chocolate Indulgence',
    price: 30000,
    imageUrl: 'https://4.bp.blogspot.com/-JIPoeKYLf4Y/WovUR--cI-I/AAAAAAAAJQY/63JG0iup2ysgCUt79DXpcoX6WHpV-vHZACLcBGAs/s1600/chocolate-indulgence.jpg',
    description: 'Kue cokelat yang lezat dan lembut',
    category: 'Cake',
  ),
  const Product(
    id: '22',
    name: 'Japanese Cotton Cheesecake',
    price: 35000,
    imageUrl: 'https://twoplaidaprons.com/wp-content/uploads/2020/07/Japanese-cotton-cheesecake-a-slice-of-cheesecake-half-pulled-out.jpg',
    description: 'Cheesecake khas Jepang dengan tekstur lembut',
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
    description: 'Kue berlapis dengan rasa stroberi',
    category: 'Cake',
  ),
  const Product(
    id: '25',
    name: 'Marble Cake',
    price: 20000,
    imageUrl: 'https://cakeshungry.com/wp-content/uploads/2024/06/Moist-Marble-Cake.png',
    description: 'Kue berlapis dengan pola marble',
    category: 'Cake',
  ),
  const Product(
    id: '26',
    name: 'Oreo Cheesecake',
    price: 45000,
    imageUrl: 'https://pl.vihaad.com/wp-content/uploads/2025/10/oreo-cheesecake-recipe.jpg',
    description: 'Cheesecake dengan rasa Oreo',
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
    description: 'Cheesecake dengan rasa blueberry segar',
    category: 'Cake',
  ),
  const Product(
    id: '30',
    name: 'Cherry Cake',
    price: 25000,
    imageUrl: 'https://cakeshungry.com/wp-content/uploads/2024/05/Serving-Cherry-Cake-683x1024.png',
    description: 'Kue dengan rasa ceri manis',
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
  // GANTI DENGAN URL BARU ANDA!!!
  static const String scriptUrl = 'https://script.google.com/macros/s/AKfycbzRnMBufbB-7HufAVHgf1o-7OXrjNeE_4X5ZYa_0h5-QVT7zJAEuoP7ugWZPZfx17Il/exec';
  
  static Future<bool> sendOrderToSheet(
    List<CartItem> items,
    double total,
    String customerName,
    String tableNumber,
    PaymentMethod paymentMethod,
  ) async {
    try {
      // Persiapkan data items
      final List<Map<String, dynamic>> itemsData = [];
      for (var item in items) {
        itemsData.add({
          'product_name': item.product.name,
          'quantity': item.quantity,
          'price': item.product.price,
          'total': item.totalPrice,
        });
      }
      
      // Buat data pesanan
      final Map<String, dynamic> orderData = {
        'timestamp': DateTime.now().toIso8601String(),
        'customer_name': customerName,
        'table_number': tableNumber,
        'total_amount': total,
        'payment_method': paymentMethod.displayName,
        'items': itemsData,
      };
      
      print('📤 Mengirim data: ${jsonEncode(orderData)}');
      
      // Kirim POST request
      final response = await http.post(
        Uri.parse(scriptUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(orderData),
      ).timeout(const Duration(seconds: 30));
      
      print('✅ Response status: ${response.statusCode}');
      print('📨 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> result = jsonDecode(response.body);
        return result['status'] == 'success';
      }
      
      return false;
      
    } catch (e) {
      print('❌ Error: $e');
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
class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

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
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
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
    return Container(
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
                    // METODE PEMBAYARAN
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
                              return Expanded(
                                child: RadioListTile<PaymentMethod>(
                                  title: Row(
                                    children: [
                                      Icon(method.icon, size: 20),
                                      const SizedBox(width: 8),
                                      Text(method.displayName),
                                    ],
                                  ),
                                  value: method,
                                  groupValue: _selectedPaymentMethod,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPaymentMethod = value!;
                                    });
                                  },
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
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
    
    setState(() => _isProcessing = true);
    
    bool success = await GoogleSheetsService.sendOrderToSheet(
      cart.cartItems,
      cart.totalAmount,
      _nameController.text,
      _tableController.text,
      _selectedPaymentMethod,
    );
    
    setState(() => _isProcessing = false);
    
    if (success) {
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('🎉 Pesanan Berhasil!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Terima kasih ${_nameController.text}'),
              const SizedBox(height: 8),
              Text('Meja No. ${_tableController.text}'),
              const SizedBox(height: 8),
              Text('Metode Pembayaran: ${_selectedPaymentMethod.displayName}'),
              const SizedBox(height: 8),
              const Text('Pesanan Anda telah tercatat:'),
              const SizedBox(height: 8),
                           Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: cart.cartItems.map((item) {
                    return Text('• ${item.product.name} x${item.quantity} = Rp${item.totalPrice.toStringAsFixed(0)}');
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Total: Rp${cart.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Pesanan akan segera diproses',
                style: TextStyle(fontSize: 12, color: Colors.brown.shade700),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                cart.clearCart();
                _nameController.clear();
                _tableController.clear();
                Navigator.pop(dialogContext);
                if (mounted) Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim pesanan. Coba lagi.'),
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