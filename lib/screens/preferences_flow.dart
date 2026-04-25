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
  int _step = 0; // 0, 1, 2

  // Step 1 — multi-select
  final Set<String> _selectedInterests = {};

  // Step 2 — single
  String? _selectedPace;

  // Step 3 — single
  String? _selectedCompanion;

  Future<void> _savePreferences() async {

  final user = FirebaseAuth.instance.currentUser;

  if(user == null) return;

  await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .update({
    'travel_style.interests': _selectedInterests.toList(),
    'travel_style.pace': _selectedPace,
    'travel_style.companion': _selectedCompanion,

    // لو عندك سؤال budget ضيفيه هنا
    // 'travel_style.budget': _selectedBudget,

    'preferences_completed': true,
  });

}

  void _next() async {
  if (_step < 2) {
    setState(() => _step++);
    return;
  }

  // Step 3 — احفظ وروح HomeShell
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
      content: Text('Failed to save preferences', style: TextStyle(fontFamily: 'Georgia')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Progress bar ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(3, (i) {
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                          height: 5,
                          decoration: BoxDecoration(
                            color: i <= _step
                                ? (i == _step
                                    ? const Color(0xFFD4941A)
                                    : const Color(0xFF2E7D5A))
                                : const Color(0xFFDDD8CE),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Step ${_step + 1} of 3',
                    style: const TextStyle(
                      color: Color(0xFF8B7355),
                      fontSize: 13,
                      fontFamily: 'Georgia',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // ── Step content ─────────────────────────────────────────
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.15, 0),
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

            // ── Continue button ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: _canProceed ? 1.0 : 0.4,
                child: GestureDetector(
                  onTap: _canProceed ? _next : null,
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8A020), Color(0xFFB8720A)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _canProceed
                          ? [
                              BoxShadow(
                                color:
                                    const Color(0xFFD4941A).withOpacity(0.35),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        _step == 2 ? 'Start Exploring' : 'Continue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
    _PrefOption('🏛️', 'Ancient / Pharaonic', 'pharaonic'),
    _PrefOption('🕌', 'Islamic Heritage', 'islamic'),
    _PrefOption('⛪', 'Coptic History', 'coptic'),
    _PrefOption('🌿', 'Nature & Adventure', 'natural'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What interests you\nmost?',
            style: TextStyle(
              color: Color(0xFF1A0E08),
              fontSize: 32,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "We'll personalize your Egyptian journey",
            style: TextStyle(
              color: Color(0xFF8B7355),
              fontSize: 14,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select all that apply',
            style: TextStyle(
              color: const Color(0xFFD4941A).withOpacity(0.8),
              fontSize: 12,
              fontFamily: 'Georgia',
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 28),
          ..._options.map((opt) => _SelectCard(
                emoji: opt.emoji,
                label: opt.label,
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
    _PrefOption('⚡', 'Quick Visit', 'quick'),
    _PrefOption('🚶', 'Medium Pace', 'medium'),
    _PrefOption('🧘', 'Take It Slow', 'slow'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's your pace?",
            style: TextStyle(
              color: Color(0xFF1A0E08),
              fontSize: 32,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'How do you like to explore?',
            style: TextStyle(
              color: Color(0xFF8B7355),
              fontSize: 14,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 32),
          ..._options.map((opt) => _SelectCard(
                emoji: opt.emoji,
                label: opt.label,
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
    _PrefOption('🧭', 'Solo', 'solo'),
    _PrefOption('👫', 'Partner', 'partner'),
    _PrefOption('👨‍👩‍👧', 'Family', 'family'),
    _PrefOption('👯', 'Friends', 'friends'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Who are you\ntraveling with?',
            style: TextStyle(
              color: Color(0xFF1A0E08),
              fontSize: 32,
              fontFamily: 'Georgia',
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "We'll adjust recommendations",
            style: TextStyle(
              color: Color(0xFF8B7355),
              fontSize: 14,
              fontFamily: 'Georgia',
            ),
          ),
          const SizedBox(height: 32),
          ..._options.map((opt) => _SelectCard(
                emoji: opt.emoji,
                label: opt.label,
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
// Shared — Selection Card
// ══════════════════════════════════════════════════════════════════════
class _SelectCard extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final bool isMulti;
  final VoidCallback onTap;

  const _SelectCard({
    required this.emoji,
    required this.label,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4941A).withOpacity(0.08)
              : Colors.white,
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
            // Emoji badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFD4941A).withOpacity(0.12)
                    : const Color(0xFFF0EBE3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 16),
            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF1A0E08)
                      : const Color(0xFF3A2A1A),
                  fontSize: 16,
                  fontFamily: 'Georgia',
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            // Right indicator
            isMulti
                ? AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFD4941A)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFD4941A)
                            : const Color(0xFFCCC5B8),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 14)
                        : null,
                  )
                : Icon(
                    Icons.chevron_right,
                    color: isSelected
                        ? const Color(0xFFD4941A)
                        : const Color(0xFFB0A090),
                    size: 22,
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
  const _PrefOption(this.emoji, this.label, this.value);
}
