import 'package:flutter/material.dart';
import '../data/app_state.dart';
import 'home_shell.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  List<Attraction> get _trending => kAttractions.take(2).toList();

  List<Attraction> get _recommended {
    if (_searchQuery.isEmpty) return kAttractions;
    final q = _searchQuery.toLowerCase();
    return kAttractions.where((a) =>
        a.name.toLowerCase().contains(q) ||
        a.location.toLowerCase().contains(q) ||
        a.category.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Listen to cart changes — يعيد بناء الصفحة لما الـ cart يتغير
    final cart = CartProvider.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _Header(
              searchController: _searchController,
              onSearch: (q) => setState(() => _searchQuery = q),
            ),
          ),

          // ── Trending Now (hidden during search) ───────────────────
          if (_searchQuery.isEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _SectionTitle(label: 'Trending Now'),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('See all',
                          style: TextStyle(
                              color: Color(0xFF2B6CB0),
                              fontSize: 14,
                              fontFamily: 'Georgia')),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _trending.length,
                  itemBuilder: (_, i) =>
                      _TrendingCard(attraction: _trending[i]),
                ),
              ),
            ),
          ],

          // ── Section title ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: _SectionTitle(
                label: _searchQuery.isEmpty
                    ? 'Recommended for You'
                    : 'Search Results',
              ),
            ),
          ),

          // ── Recommended / Search results ──────────────────────────
          _recommended.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'No results for "$_searchQuery"',
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontFamily: 'Georgia',
                            fontSize: 15),
                      ),
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final a = _recommended[i];
                        return ListenableBuilder(
                          listenable: cart,
                          builder: (_, __) => _RecommendedCard(
                            attraction: a,
                            inCart: cart.contains(a.id),
                            isFull: cart.isFull && !cart.contains(a.id),
                            onToggle: () {
                              if (cart.contains(a.id)) {
                                cart.remove(a.id);
                              } else if (!cart.isFull) {
                                cart.add(a);
                              } else {
                                // Max reached
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Maximum 6 attractions per trip',
                                      style: TextStyle(fontFamily: 'Georgia'),
                                    ),
                                    backgroundColor: const Color(0xFFD4941A),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            },
                          ),
                        );
                      },
                      childCount: _recommended.length,
                    ),
                  ),
                ),

          // ── Explore Egypt map (hidden during search) ──────────────
          if (_searchQuery.isEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: _SectionTitle(label: 'Explore Egypt'),
              ),
            ),
            SliverToBoxAdapter(
              child: _MapPlaceholder(attractions: kAttractions),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Header with working search
// ══════════════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  final TextEditingController searchController;
  final void Function(String) onSearch;

  const _Header({required this.searchController, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD4941A), Color(0xFFB8600A)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome back,',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                          fontFamily: 'Georgia')),
                  const Text('Traveler',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Text('𓂀',
                  style: TextStyle(
                      fontSize: 32,
                      color: Colors.white.withOpacity(0.7))),
            ],
          ),
          const SizedBox(height: 20),
          // ✅ Search bar شغّال
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: searchController,
              onChanged: onSearch,
              style: const TextStyle(
                  color: Color(0xFF2C1810),
                  fontFamily: 'Georgia',
                  fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search attractions...',
                hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontFamily: 'Georgia',
                    fontSize: 14),
                prefixIcon: Icon(Icons.search,
                    color: Colors.grey.shade500, size: 20),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close,
                            color: Colors.grey.shade500, size: 18),
                        onPressed: () {
                          searchController.clear();
                          onSearch('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Trending Card
// ══════════════════════════════════════════════════════════════════════
class _TrendingCard extends StatelessWidget {
  final Attraction attraction;
  const _TrendingCard({required this.attraction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                Image.network(
                  attraction.imageUrl,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      height: 130,
                      color: const Color(0xFFD4941A).withOpacity(0.3)),
                ),
                Positioned(
                    top: 10,
                    left: 10,
                    child: _CategoryBadge(
                        label: attraction.category,
                        colorHex: attraction.categoryColor)),
                Positioned(
                    top: 10,
                    right: 10,
                    child: _RatingBadge(rating: attraction.rating)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attraction.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Color(0xFF1A0E08),
                        fontSize: 13,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.location_on_outlined,
                      size: 12, color: Colors.grey.shade500),
                  const SizedBox(width: 3),
                  Text(attraction.location,
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          fontFamily: 'Georgia')),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Recommended Card
// ══════════════════════════════════════════════════════════════════════
class _RecommendedCard extends StatelessWidget {
  final Attraction attraction;
  final bool inCart;
  final bool isFull;
  final VoidCallback onToggle;

  const _RecommendedCard({
    required this.attraction,
    required this.inCart,
    required this.isFull,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                Image.network(
                  attraction.imageUrl,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      height: 190,
                      color: const Color(0xFFD4941A).withOpacity(0.3)),
                ),
                Positioned(
                    top: 12,
                    left: 12,
                    child: _CategoryBadge(
                        label: attraction.category,
                        colorHex: attraction.categoryColor)),
                Positioned(
                    top: 12,
                    right: 12,
                    child: _RatingBadge(rating: attraction.rating)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attraction.name,
                    style: const TextStyle(
                        color: Color(0xFF1A0E08),
                        fontSize: 18,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.location_on_outlined,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 3),
                  Text(attraction.location,
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          fontFamily: 'Georgia')),
                  const SizedBox(width: 14),
                  Icon(Icons.access_time_outlined,
                      size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 3),
                  Text(attraction.pace,
                      style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                          fontFamily: 'Georgia')),
                ]),
                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade200, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      attraction.price == 0
                          ? 'Free'
                          : '${attraction.price} EGP',
                      style: const TextStyle(
                          color: Color(0xFF1A0E08),
                          fontSize: 17,
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.bold),
                    ),
                    // ✅ Add/Added/Full button
                    GestureDetector(
                      onTap: onToggle,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: inCart
                              ? const Color(0xFF2E8B57)
                              : isFull
                                  ? Colors.grey.shade300
                                  : const Color(0xFFD4941A),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              inCart ? Icons.check : Icons.add,
                              color: isFull && !inCart
                                  ? Colors.grey.shade500
                                  : Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              inCart
                                  ? 'Added'
                                  : isFull
                                      ? 'Trip Full'
                                      : 'Add to Trip',
                              style: TextStyle(
                                  color: isFull && !inCart
                                      ? Colors.grey.shade500
                                      : Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Georgia',
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Map Placeholder
// ══════════════════════════════════════════════════════════════════════
class _MapPlaceholder extends StatelessWidget {
  final List<Attraction> attractions;
  const _MapPlaceholder({required this.attractions});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(18)),
              child: Container(
                height: 200,
                color: const Color(0xFFD4DDE8),
                child: Stack(
                  children: [
                    CustomPaint(
                        painter: _MapGridPainter(),
                        size: const Size(double.infinity, 200)),
                    Positioned(
                        left: 90,
                        top: 70,
                        child: _MapPin(color: const Color(0xFF1B3A6B))),
                    Positioned(
                        left: 70,
                        top: 85,
                        child: _MapPin(color: const Color(0xFF2E8B57))),
                    Positioned(
                        left: 220,
                        top: 110,
                        child: _MapPin(color: const Color(0xFF1B3A6B))),
                    Positioned(
                        left: 240,
                        top: 125,
                        child: _MapPin(color: const Color(0xFF2E8B57))),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Great Pyramids of Giza',
                          style: TextStyle(
                              color: Color(0xFF1A0E08),
                              fontSize: 15,
                              fontFamily: 'Georgia',
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text('Giza · 200 EGP',
                          style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontFamily: 'Georgia')),
                    ],
                  ),
                  const Row(children: [
                    Icon(Icons.star, color: Color(0xFFD4941A), size: 16),
                    SizedBox(width: 4),
                    Text('4.9',
                        style: TextStyle(
                            color: Color(0xFF1A0E08),
                            fontSize: 14,
                            fontFamily: 'Georgia',
                            fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                '${attractions.length} attractions across Egypt — tap a pin for details',
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontFamily: 'Georgia'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final Color color;
  const _MapPin({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ]),
      child: const Icon(Icons.location_on, color: Colors.white, size: 18),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40)
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += 40)
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Small shared widgets ───────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 4,
            height: 22,
            decoration: BoxDecoration(
                color: const Color(0xFFD4941A),
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(
                color: Color(0xFF1A0E08),
                fontSize: 20,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  final String colorHex;
  const _CategoryBadge({required this.label, required this.colorHex});

  Color _fromHex(String hex) =>
      Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: _fromHex(colorHex),
          borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.w600)),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ]),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Color(0xFFD4941A), size: 14),
          const SizedBox(width: 4),
          Text(rating.toString(),
              style: const TextStyle(
                  color: Color(0xFF1A0E08),
                  fontSize: 12,
                  fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}