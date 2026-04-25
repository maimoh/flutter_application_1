import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingSlide {
  final String backgroundGradient;
  final Color bgColor1;
  final Color bgColor2;
  final Color bgColor3;
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool isLast;

  const OnboardingSlide({
    required this.backgroundGradient,
    required this.bgColor1,
    required this.bgColor2,
    required this.bgColor3,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    this.isLast = false,
  });
}

const List<OnboardingSlide> slides = [
  OnboardingSlide(
    backgroundGradient: 'pyramids',
    bgColor1: Color(0xFFD4761A),
    bgColor2: Color(0xFF8B4513),
    bgColor3: Color(0xFF1A0A00),
    icon: Icons.explore_outlined,
    iconBg: Color(0xFFD4881A),
    title: 'Discover Egypt',
    subtitle: 'Your personal gateway to 5,000 years of wonder',
  ),
  OnboardingSlide(
    backgroundGradient: 'columns',
    bgColor1: Color(0xFFB8860B),
    bgColor2: Color(0xFF6B4226),
    bgColor3: Color(0xFF0D0500),
    icon: Icons.auto_awesome,
    iconBg: Color(0xFF3A5BA0),
    title: 'AI-Powered Trips',
    subtitle: 'Let our AI craft the perfect itinerary tailored just for you',
  ),
  OnboardingSlide(
    backgroundGradient: 'mosque',
    bgColor1: Color(0xFFCC7700),
    bgColor2: Color(0xFF7A3B1E),
    bgColor3: Color(0xFF0A0200),
    icon: Icons.map_outlined,
    iconBg: Color(0xFF2E8B57),
    title: 'Explore Culture',
    subtitle: 'From pharaonic temples to Islamic masterpieces — all in one place',
  ),
  OnboardingSlide(
    backgroundGradient: 'nile',
    bgColor1: Color(0xFFE8900A),
    bgColor2: Color(0xFF5C3317),
    bgColor3: Color(0xFF080300),
    icon: Icons.group_outlined,
    iconBg: Color(0xFFD4881A),
    title: 'Travel Together',
    subtitle: 'Share experiences, discover trips from fellow travelers',
    isLast: true,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Page View ──────────────────────────────────────────────
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
              _animController.reset();
              _animController.forward();
            },
            itemCount: slides.length,
            itemBuilder: (context, index) {
              return _SlideBackground(slide: slides[index]);
            },
          ),

          // ── KEMET Logo top center ──────────────────────────────────
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1B2A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFD4941A).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '𓂀',
                      style: TextStyle(
                        fontSize: 32,
                        color: const Color(0xFFD4941A),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'KEMET',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontFamily: 'Georgia',
                    letterSpacing: 4,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom content: icon + text + dots + button ───────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 56),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon badge
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: slides[_currentPage].iconBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          slides[_currentPage].icon,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Text(
                        slides[_currentPage].title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        slides[_currentPage].subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 15,
                          fontFamily: 'Georgia',
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Dots + Next button row
                      Row(
                        children: [
                          // Dots
                          Row(
                            children: List.generate(slides.length, (i) {
                              final isActive = i == _currentPage;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 6),
                                width: isActive ? 28 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFFD4941A)
                                      : Colors.white.withOpacity(0.35),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              );
                            }),
                          ),
                          const Spacer(),

                          // Next / Get Started button
                          GestureDetector(
                            onTap: _nextPage,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE8A020),
                                    Color(0xFFB8720A),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFD4941A).withOpacity(0.4),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    slides[_currentPage].isLast
                                        ? 'Get Started'
                                        : 'Next',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Georgia',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                    size: 16,
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Slide Background with gradient ────────────────────────────────────
class _SlideBackground extends StatelessWidget {
  final OnboardingSlide slide;
  const _SlideBackground({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            slide.bgColor1,
            slide.bgColor2,
            slide.bgColor3,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Overlay gradient for readability at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 380,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Decorative Egyptian pattern overlay
          Positioned.fill(
            child: CustomPaint(painter: _EgyptianPatternPainter()),
          ),
        ],
      ),
    );
  }
}

// ── Subtle Egyptian geometric pattern ─────────────────────────────────
class _EgyptianPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Subtle diagonal grid
    for (double x = 0; x < size.width + size.height; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x - size.height, size.height), paint);
    }
    for (double x = -size.height; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
