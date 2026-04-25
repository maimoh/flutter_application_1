import 'package:flutter/material.dart';
import '../data/app_state.dart';
import 'home_shell.dart';

class MyTripPage extends StatelessWidget {
  const MyTripPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = CartProvider.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: ListenableBuilder(
        listenable: cart,
        builder: (_, __) {
          final items = cart.items;
          final count = cart.count;

          return Column(
            children: [
              // ── Header ─────────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1B2A6B), Color(0xFFB8720A)],
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
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1B2A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color(0xFFD4941A).withOpacity(0.4)),
                          ),
                          child: const Center(
                            child: Text('𓂀',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFFD4941A))),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('My Trips',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontFamily: 'Georgia',
                                      fontWeight: FontWeight.bold)),
                              Text(
                                'Add up to 6 attractions, then generate your AI trip',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    fontFamily: 'Georgia'),
                              ),
                            ],
                          ),
                        ),
                        Text('𓂀',
                            style: TextStyle(
                                fontSize: 28,
                                color: Colors.white.withOpacity(0.2))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Generate without picking
                    GestureDetector(
                      onTap: () => _showGenerateSheet(context, withCart: false),
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF2A3A8B), Color(0xFFD4941A)]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.auto_awesome,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Generate Trip Without Picking',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontFamily: 'Georgia',
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Body ───────────────────────────────────────────────
              Expanded(
                child: count == 0
                    ? _EmptyCart()
                    : Column(
                        children: [
                          // Cart header
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 20,
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFD4941A),
                                          borderRadius:
                                              BorderRadius.circular(2)),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Trip Cart ($count/6)',
                                      style: const TextStyle(
                                          color: Color(0xFF1A0E08),
                                          fontSize: 18,
                                          fontFamily: 'Georgia',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => cart.clear(),
                                  child: const Text('Clear all',
                                      style: TextStyle(
                                          color: Color(0xFFCC3300),
                                          fontSize: 14,
                                          fontFamily: 'Georgia',
                                          fontWeight: FontWeight.w600)),
                                ),
                              ],
                            ),
                          ),

                          // Cart items
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16),
                              itemCount: items.length,
                              itemBuilder: (_, i) => _CartItem(
                                attraction: items[i],
                                onRemove: () => cart.remove(items[i].id),
                              ),
                            ),
                          ),

                          // Generate My Trip button
                          Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            child: GestureDetector(
                              onTap: () => _showGenerateSheet(context,
                                  withCart: true),
                              child: Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD4941A),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFD4941A)
                                          .withOpacity(0.4),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.auto_awesome,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 10),
                                    Text('Generate My Trip',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontFamily: 'Georgia',
                                            fontWeight: FontWeight.bold)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_ios,
                                        color: Colors.white, size: 14),
                                  ],
                                ),
                              ),
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

  void _showGenerateSheet(BuildContext context, {required bool withCart}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _GenerateSheet(withCart: withCart),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Cart Item
// ══════════════════════════════════════════════════════════════════════
class _CartItem extends StatelessWidget {
  final Attraction attraction;
  final VoidCallback onRemove;

  const _CartItem({required this.attraction, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              attraction.imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 60,
                color: const Color(0xFFD4941A).withOpacity(0.3),
                child: const Icon(Icons.image, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(attraction.name,
                    style: const TextStyle(
                        color: Color(0xFF1A0E08),
                        fontSize: 15,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${attraction.location} · ${attraction.category}',
                    style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                        fontFamily: 'Georgia')),
              ],
            ),
          ),
          // ✅ Remove X button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8)),
              child: Icon(Icons.close,
                  size: 16, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Empty Cart
// ══════════════════════════════════════════════════════════════════════
class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('𓂀',
              style: TextStyle(
                  fontSize: 48,
                  color: const Color(0xFFD4941A).withOpacity(0.3))),
          const SizedBox(height: 16),
          Text('Your trip cart is empty',
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                  fontFamily: 'Georgia')),
          const SizedBox(height: 8),
          Text('Add attractions from Home to get started',
              style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 13,
                  fontFamily: 'Georgia')),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Generate Sheet
// ══════════════════════════════════════════════════════════════════════
class _GenerateSheet extends StatelessWidget {
  final bool withCart;
  const _GenerateSheet({required this.withCart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(
          color: Color(0xFFFAF7F2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          const Icon(Icons.auto_awesome,
              color: Color(0xFFD4941A), size: 40),
          const SizedBox(height: 12),
          Text(
            withCart
                ? 'Generate Trip from Cart'
                : 'Generate Trip Without Picking',
            style: const TextStyle(
                color: Color(0xFF1A0E08),
                fontSize: 18,
                fontFamily: 'Georgia',
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            withCart
                ? 'Our AI will build a personalised itinerary based on your selected attractions.'
                : 'Our AI will suggest the best attractions and build a full trip for you.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                fontFamily: 'Georgia'),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFD4941A).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFFD4941A).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: Color(0xFFD4941A), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI trip generation will be live once the model is connected.',
                    style: TextStyle(
                        color:
                            const Color(0xFFD4941A).withOpacity(0.9),
                        fontSize: 12,
                        fontFamily: 'Georgia'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFE8A020), Color(0xFFB8720A)]),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                  child: Text('Got it',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.bold))),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}