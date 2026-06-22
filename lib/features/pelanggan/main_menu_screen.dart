part of '../../main.dart';

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
    if (currentUser?.role == 'admin') {
      _screens = [
        const ReportScreen(),
        const UserManagementScreen(),
      ];
    } else {
      _screens = [
        const ProductListScreen(),
        const CartScreen(),
        const OrderHistoryScreen(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<BottomNavigationBarItem> items;

    if (currentUser?.role == 'admin') {
      items = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          label: 'Laporan',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Users',
        ),
      ];
    } else {
      items = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Menu',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Keranjang',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: 'Riwayat',
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
                color: Colors.white.withValues(alpha: 0.2),
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
                if (!mounted) return;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
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
