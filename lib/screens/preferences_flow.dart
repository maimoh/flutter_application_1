import 'package:flutter/material.dart';
import 'home_shell.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ══════════════════════════════════════════════════════════════════════
// PREFERENCES FLOW — 3 steps after signup only
// Step 1: Interests (multi-select)
// Step 2: Pace (single select)
// Step 3: Companion (single select)
// ══════════════════════════════════════════════════════════════════════

class PreferencesFlow extends StatefulWidget {
  const PreferencesFlow({super.key});

  @override
  State<PreferencesFlow> createState() => _PreferencesFlowState();
}

class _PreferencesFlowState extends State<PreferencesFlow> {
  int _step = 0;

  final Set<String> _selectedInterests = {};
  String? _selectedPace;
  String? _selectedCompanion;

  void _next() async {
    if (_step < 2) {
      setState(() => _step++);
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'travel_style.interests': _selectedInterests.toList(),
        'travel_style.pace': _selectedPace,
        'travel_style.companion': _selectedCompanion,
        'preferences_completed': true,
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to save preferences',
            style: TextStyle(fontFamily: 'Georgia')),
        backgroundColor: Color(0xFFCC3300),
      ));
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeShell(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  bool get _canProceed {
    if (_step == 0) return _selectedInterests.isNotEmpty;
    if (_step == 1) return _selectedPace != null;
    if (_step == 2) return _selectedCompanion != null;
    return false;
  }

  // Step metadata
  static const _stepTitles = [
    'What fascinates\nyou most?',
    "What's your\npace?",
    'Who are you\ntraveling with?',
  ];

  static const _stepSubtitles = [
    'PERSONALIZE YOUR JOURNEY',
    'PERSONALIZE YOUR JOURNEY',
    'PERSONALIZE YOUR JOURNEY',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: Column(
        children: [
          // ── Dark teal header ─────────────────────────────────────
          Container(
            width: double.infinity,
            color: const Color(0xFF1B2E35),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress bar
                    Row(
                      children: List.generate(3, (i) {
                        Color barColor;
                        if (i < _step) {
                          barColor = const Color(0xFFD4941A); // completed
                        } else if (i == _step) {
                          barColor = const Color(0xFFD4941A); // current
                        } else {
                          barColor = const Color(0xFF3A5060); // upcoming
                        }
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                            height: 3,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 28),

                    // Subtitle label
                    Text(
                      _stepSubtitles[_step],
                      style: const TextStyle(
                        color: Color(0xFF8FAAB8),
                        fontSize: 11,
                        fontFamily: 'Georgia',
                        letterSpacing: 2.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Title with italic highlight
                    _AnimatedStepTitle(step: _step, titles: _stepTitles),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable card content ──────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.12, 0),
                  end: Offset.zero,
                ).animate(
                    CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: FadeTransition(opacity: anim, child: child),
              ),
              child: _step == 0
                  ? _InterestsStep(
                      key: const ValueKey(0),
                      selected: _selectedInterests,
                      onToggle: (val) => setState(() {
                        if (_selectedInterests.contains(val)) {
                          _selectedInterests.remove(val);
                        } else {
                          _selectedInterests.add(val);
                        }
                      }),
                    )
                  : _step == 1
                      ? _PaceStep(
                          key: const ValueKey(1),
                          selected: _selectedPace,
                          onSelect: (val) =>
                              setState(() => _selectedPace = val),
                        )
                      : _CompanionStep(
                          key: const ValueKey(2),
                          selected: _selectedCompanion,
                          onSelect: (val) =>
                              setState(() => _selectedCompanion = val),
                        ),
            ),
          ),

          // ── Continue button (bottom, floating style) ─────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            child: GestureDetector(
              onTap: _canProceed ? _next : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 180,
                height: 54,
                decoration: BoxDecoration(
                  color: _canProceed
                      ? const Color(0xFFC17B25)
                      : const Color(0xFFB0A090),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: _canProceed
                      ? [
                          BoxShadow(
                            color: const Color(0xFFD4941A).withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _step == 2 ? 'Start Exploring' : 'Continue',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Georgia',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated title with italic gold word ──────────────────────────────
class _AnimatedStepTitle extends StatelessWidget {
  final int step;
  final List<String> titles;

  const _AnimatedStepTitle({required this.step, required this.titles});

  @override
  Widget build(BuildContext context) {
    // For step 0: "What fascinates you most?" — italic the key word
    if (step == 0) {
      return RichText(
        text: const TextSpan(
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
          children: [
            TextSpan(text: 'What '),
            TextSpan(
              text: 'fascinates',
              style: TextStyle(
                color: Color(0xFFD4941A),
                fontStyle: FontStyle.italic,
              ),
            ),
            TextSpan(text: ' you most?'),
          ],
        ),
      );
    }
    if (step == 1) {
      return RichText(
        text: const TextSpan(
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            height: 1.25,
          ),
          children: [
            TextSpan(text: "What's your\n"),
            TextSpan(
              text: 'pace',
              style: TextStyle(
                color: Color(0xFFD4941A),
                fontStyle: FontStyle.italic,
              ),
            ),
            TextSpan(text: '?'),
          ],
        ),
      );
    }
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          color: Colors.white,
          fontSize: 32,
          fontFamily: 'Georgia',
          fontWeight: FontWeight.bold,
          height: 1.25,
        ),
        children: [
          TextSpan(text: 'Who are you\n'),
          TextSpan(
            text: 'traveling',
            style: TextStyle(
              color: Color(0xFFD4941A),
              fontStyle: FontStyle.italic,
            ),
          ),
          TextSpan(text: ' with?'),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Step 1 — Interests (MULTI-SELECT)
// ══════════════════════════════════════════════════════════════════════
class _InterestsStep extends StatelessWidget {
  final Set<String> selected;
  final void Function(String) onToggle;

  const _InterestsStep({
    super.key,
    required this.selected,
    required this.onToggle,
  });

  static const _options = [
    _PrefOption('🏛️', 'Pharaonic', 'pharaonic', 'Temples, pyramids & ancient tombs'),
    _PrefOption('🕌', 'Islamic', 'islamic', 'Mosques, citadels & medieval Cairo'),
    _PrefOption('⛪', 'Coptic', 'coptic', 'Churches, monasteries & early Christianity'),
    _PrefOption('🌿', 'Nature & Adventure', 'natural', 'Desert, diving & outdoor escapes'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Interests',
            style: TextStyle(
              color: Color(0xFF1A0E08),
              fontSize: 20,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select all that call to you',
            style: TextStyle(
              color: Color(0xFF8B7355),
              fontSize: 13,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 20),
          ..._options.map((opt) => _SelectCard(
                emoji: opt.emoji,
                label: opt.label,
                subtitle: opt.subtitle,
                isSelected: selected.contains(opt.value),
                isMulti: true,
                onTap: () => onToggle(opt.value),
              )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Step 2 — Pace (SINGLE SELECT)
// ══════════════════════════════════════════════════════════════════════
class _PaceStep extends StatelessWidget {
  final String? selected;
  final void Function(String) onSelect;

  const _PaceStep({super.key, required this.selected, required this.onSelect});

  static const _options = [
    _PrefOption('⚡', 'Quick Visit', 'quick', 'Hit the highlights efficiently'),
    _PrefOption('🚶', 'Medium Pace', 'medium', 'Balance sightseeing with downtime'),
    _PrefOption('🧘', 'Take It Slow', 'slow', 'Immerse deeply in every place'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Travel Pace',
            style: TextStyle(
              color: Color(0xFF1A0E08),
              fontSize: 20,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'How do you like to explore?',
            style: TextStyle(
              color: Color(0xFF8B7355),
              fontSize: 13,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 20),
          ..._options.map((opt) => _SelectCard(
                emoji: opt.emoji,
                label: opt.label,
                subtitle: opt.subtitle,
                isSelected: selected == opt.value,
                isMulti: false,
                onTap: () => onSelect(opt.value),
              )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Step 3 — Companion (SINGLE SELECT)
// ══════════════════════════════════════════════════════════════════════
class _CompanionStep extends StatelessWidget {
  final String? selected;
  final void Function(String) onSelect;

  const _CompanionStep(
      {super.key, required this.selected, required this.onSelect});

  static const _options = [
    _PrefOption('🧭', 'Solo', 'solo', 'Independent exploration at your own rhythm'),
    _PrefOption('👫', 'Partner', 'partner', 'Romantic adventure for two'),
    _PrefOption('👨‍👩‍👧', 'Family', 'family', 'Fun for all ages, kid-friendly picks'),
    _PrefOption('👯', 'Friends', 'friends', 'Group vibes and shared memories'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Travel Group',
            style: TextStyle(
              color: Color(0xFF1A0E08),
              fontSize: 20,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "We'll adjust recommendations for you",
            style: TextStyle(
              color: Color(0xFF8B7355),
              fontSize: 13,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 20),
          ..._options.map((opt) => _SelectCard(
                emoji: opt.emoji,
                label: opt.label,
                subtitle: opt.subtitle,
                isSelected: selected == opt.value,
                isMulti: false,
                onTap: () => onSelect(opt.value),
              )),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Shared — Selection Card (matches screenshot style)
// ══════════════════════════════════════════════════════════════════════
class _SelectCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String subtitle;
  final bool isSelected;
  final bool isMulti;
  final VoidCallback onTap;

  const _SelectCard({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.isMulti,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD4941A)
                : const Color(0xFFE8E0D0),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji icon badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            // Label + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: const Color(0xFF1A0E08),
                      fontSize: 15,
                      fontFamily: 'Georgia',
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8B7355),
                      fontSize: 12,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: isMulti ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: isMulti ? BorderRadius.circular(6) : null,
                color: isSelected
                    ? Colors.transparent
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : const Color(0xFFCCC5B8),
                  width: 1.5,
                ),
              ),
              child: isSelected
                  ? Container(
                      decoration: BoxDecoration(
                        color: isMulti ? Colors.transparent : Colors.transparent,
                        shape: isMulti ? BoxShape.rectangle : BoxShape.circle,
                        borderRadius: isMulti ? BorderRadius.circular(6) : null,
                        border: Border.all(
                          color: const Color(0xFFD4941A),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFFD4941A),
                        size: 14,
                      ),
                    )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data class ─────────────────────────────────────────────────────────
class _PrefOption {
  final String emoji;
  final String label;
  final String value;
  final String subtitle;
  const _PrefOption(this.emoji, this.label, this.value, this.subtitle);
}
