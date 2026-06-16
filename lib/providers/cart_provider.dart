part of '../main.dart';

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

