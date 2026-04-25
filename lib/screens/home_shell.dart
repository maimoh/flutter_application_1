import 'package:flutter/material.dart';
import '../data/app_state.dart';
import 'home_page.dart';
import 'my_trip_page.dart';

// ══════════════════════════════════════════════════════════════════════
// CartProvider — InheritedWidget يشيل الـ cart state وبيعدّيه
// لكل الـ pages من غير ما كل صفحة تعمل instance جديدة
// ══════════════════════════════════════════════════════════════════════
class CartProvider extends InheritedNotifier<CartNotifier> {
  const CartProvider({
    super.key,
    required CartNotifier super.notifier,
    required super.child,
  });

  static CartNotifier of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CartProvider>()!
        .notifier!;
  }
}

class CartNotifier extends ChangeNotifier {
  final List<Attraction> _items = [];
  static const int maxItems = 6;

  List<Attraction> get items => List.unmodifiable(_items);
  int get count => _items.length;
  bool get isFull => _items.length >= maxItems;

  bool contains(String id) => _items.any((a) => a.id == id);

  void add(Attraction a) {
    if (!contains(a.id) && !isFull) {
      _items.add(a);
      notifyListeners();
    }
  }

  void remove(String id) {
    _items.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

// ══════════════════════════════════════════════════════════════════════
// HomeShell
// ══════════════════════════════════════════════════════════════════════
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;
  final _cartNotifier = CartNotifier();

  @override
  void dispose() {
    _cartNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CartProvider(
      notifier: _cartNotifier,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F0E8),
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomePage(),
            MyTripPage(),
            _CommunityPage(),
            _ProfilePage(),
          ],
        ),
        bottomNavigationBar: _BottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          cartNotifier: _cartNotifier,
        ),
      ),
    );
  }
}

// ── Bottom Nav ─────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;
  final CartNotifier cartNotifier;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.cartNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
            top: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              // My Trip with badge
              ListenableBuilder(
                listenable: cartNotifier,
                builder: (_, __) => _NavItemBadge(
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map,
                  label: 'My Trip',
                  isActive: currentIndex == 1,
                  badge: cartNotifier.count,
                  onTap: () => onTap(1),
                ),
              ),
              _NavItem(
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'Community',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 28 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFD4941A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? const Color(0xFFD4941A)
                  : Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFFD4941A)
                    : Colors.grey.shade500,
                fontSize: 11,
                fontFamily: 'Georgia',
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItemBadge extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final int badge;
  final VoidCallback onTap;

  const _NavItemBadge({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 28 : 0,
              height: 3,
              margin: const EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFD4941A),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  color: isActive
                      ? const Color(0xFFD4941A)
                      : Colors.grey.shade500,
                  size: 24,
                ),
                if (badge > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFD4941A),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive
                    ? const Color(0xFFD4941A)
                    : Colors.grey.shade500,
                fontSize: 11,
                fontFamily: 'Georgia',
                fontWeight:
                    isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Placeholder pages ──────────────────────────────────────────────────
class _CommunityPage extends StatelessWidget {
  const _CommunityPage();
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Color(0xFFF5F0E8),
        body: Center(
          child: Text('Community — Coming Soon',
              style: TextStyle(
                  color: Color(0xFF8B7355),
                  fontFamily: 'Georgia',
                  fontSize: 18)),
        ),
      );
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();
  @override
  Widget build(BuildContext context) => const Scaffold(
        backgroundColor: Color(0xFFF5F0E8),
        body: Center(
          child: Text('Profile — Coming Soon',
              style: TextStyle(
                  color: Color(0xFF8B7355),
                  fontFamily: 'Georgia',
                  fontSize: 18)),
        ),
      );
}