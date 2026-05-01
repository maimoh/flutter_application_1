import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/validators.dart';
import 'login_screen.dart';
import 'preferences_flow.dart';
import '../services/google_sign_in_service.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _submitted = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Firebase instances ──────────────────────────────────────────────
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _slideAnim =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
            CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── Email/Password Sign Up ──────────────────────────────────────────
  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // 1. Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // 2. Update display name
      await credential.user!.updateDisplayName(_nameController.text.trim());

      // 3. Save user data in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'uid': credential.user!.uid,
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'photoUrl': null,
        'provider': 'email',
        'createdAt': FieldValue.serverTimestamp(),
        'preferencesCompleted': false,
      });

      if (!mounted) return;
      _goToPreferences();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showError(_getAuthErrorMessage(e.code));
    } catch (e) {
      if (!mounted) return;
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Google Sign In ──────────────────────────────────────────────────
  Future<void> _signInWithGoogle() async {
  setState(() => _isGoogleLoading = true);
  try {
    final user = await GoogleSignInService.signIn();
    if (user == null) return; // user cancelled

    final docRef = _firestore.collection('users').doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoUrl': user.photoURL,
        'provider': 'google',
        'stats': {'places_visited': 0, 'trips_created': 0},
        'travel_style': {'companion': '', 'interests': [], 'pace': ''},
        'preferences_completed': false,
        'created_at': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      _goToPreferences();
      return;
    }

      if (!mounted) return;
      _goToPreferences();

  } catch (e) {
    if (!mounted) return;
    _showError('Google sign-in failed. Please try again.');
  } finally {
    if (mounted) setState(() => _isGoogleLoading = false);
  }
}
  // ── Helpers ─────────────────────────────────────────────────────────
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger one.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'account-exists-with-different-credential':
        return 'Account already exists with a different sign-in method.';
      default:
        return 'Sign up failed. Please try again.';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(fontFamily: 'Georgia', color: Colors.white)),
        backgroundColor: const Color(0xFFCC3300),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _goToPreferences() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const PreferencesFlow(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/bg_egyptian.jpeg', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.4, 1.0],
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.88),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0, left: 0, right: 0, bottom: 0,
            child: SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 24, right: 24, top: 40,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                  ),
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        children: [
                          Text('Begin Your Journey',
                              style: TextStyle(
                                color: const Color(0xFFD4941A),
                                fontSize: 30,
                                fontFamily: 'Georgia',
                                fontWeight: FontWeight.bold,
                                shadows: [Shadow(
                                    color: Colors.black.withOpacity(0.7),
                                    blurRadius: 16)],
                              )),
                          const SizedBox(height: 8),
                          Text(
                            'Create your account & unlock the wonders of Egypt',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 13, fontFamily: 'Georgia'),
                          ),
                          const SizedBox(height: 28),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF7F2),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 32,
                                    offset: const Offset(0, 12))
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              autovalidateMode: _submitted
                                  ? AutovalidateMode.onUserInteraction
                                  : AutovalidateMode.disabled,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _FormDividerTitle(label: 'CREATE ACCOUNT'),
                                  const SizedBox(height: 20),
                                  const _FieldLabel(label: 'FULL NAME'),
                                  const SizedBox(height: 8),
                                  _KemetFormField(
                                    controller: _nameController,
                                    hint: 'Cleopatra VII',
                                    prefixIcon: Icons.person_outline,
                                    validator: KemetValidators.fullName,
                                  ),
                                  const SizedBox(height: 14),
                                  const _FieldLabel(label: 'EMAIL ADDRESS'),
                                  const SizedBox(height: 8),
                                  _KemetFormField(
                                    controller: _emailController,
                                    hint: 'pharaoh@kemet.com',
                                    prefixIcon: Icons.mail_outline,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: KemetValidators.email,
                                  ),
                                  const SizedBox(height: 14),
                                  const _FieldLabel(label: 'PASSWORD'),
                                  const SizedBox(height: 8),
                                  _KemetFormField(
                                    controller: _passwordController,
                                    hint: '••••••••',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    validator: KemetValidators.password,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: const Color(0xFF8B7355),
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Min. 8 characters with one uppercase letter',
                                    style: TextStyle(
                                        color: const Color(0xFF8B7355)
                                            .withOpacity(0.7),
                                        fontSize: 10,
                                        fontFamily: 'Georgia'),
                                  ),
                                  const SizedBox(height: 20),
                                  _KemetButton(
                                    label: 'Claim Your Throne',
                                    isLoading: _isLoading,
                                    onTap: _submit,
                                  ),
                                  const SizedBox(height: 16),
                                  const _OrDivider(label: 'or sign up with'),
                                  const SizedBox(height: 14),
                                  _GoogleButton(
                                    isLoading: _isGoogleLoading,
                                    onTap: _signInWithGoogle,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Already have an account? ',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.65),
                                      fontSize: 13,
                                      fontFamily: 'Georgia')),
                              GestureDetector(
                                onTap: () => Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (_, __, ___) =>
                                        const LoginScreen(),
                                    transitionDuration:
                                        const Duration(milliseconds: 400),
                                    transitionsBuilder: (_, anim, __, child) =>
                                        FadeTransition(
                                            opacity: anim, child: child),
                                  ),
                                ),
                                child: const Text('Sign In',
                                    style: TextStyle(
                                        color: Color(0xFFD4941A),
                                        fontSize: 13,
                                        fontFamily: 'Georgia',
                                        fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
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

// ═══════════════════════════════════════════════════════════════════════
// Widgets — نفس اللي كانت موجودة بالظبط
// ═══════════════════════════════════════════════════════════════════════

class _GoogleButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _GoogleButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity, height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0D8CC)),
          boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Color(0xFF4285F4)))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(width: 22, height: 22,
                      child: CustomPaint(painter: _GoogleLogoPainter())),
                  const SizedBox(width: 12),
                  const Text('Continue with Google',
                      style: TextStyle(color: Color(0xFF3C3C3C),
                          fontSize: 15, fontFamily: 'Georgia',
                          fontWeight: FontWeight.w500)),
                ]),
        ),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    final rect = Rect.fromCircle(center: c, radius: r);
    final sw = size.width * 0.28;
    canvas.drawArc(rect, -1.5708, 3.1416, false,
        Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.stroke..strokeWidth = sw);
    canvas.drawArc(rect, 1.5708, 1.5708, false,
        Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.stroke..strokeWidth = sw);
    canvas.drawArc(rect, 3.1416, 0.7854, false,
        Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.stroke..strokeWidth = sw);
    canvas.drawArc(rect, 3.9270, 0.7854, false,
        Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.stroke..strokeWidth = sw);
    canvas.drawCircle(c, r * 0.5, Paint()..color = Colors.white);
    canvas.drawRect(
        Rect.fromLTWH(c.dx, c.dy - size.height * 0.12, r * 0.85, size.height * 0.24),
        Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.fill);
  }
  @override
  bool shouldRepaint(_) => false;
}

class _FormDividerTitle extends StatelessWidget {
  final String label;
  const _FormDividerTitle({required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Divider(
          color: const Color(0xFFD4941A).withOpacity(0.4), thickness: 1)),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(label, style: const TextStyle(color: Color(0xFFD4941A),
              fontSize: 11, fontFamily: 'Georgia', letterSpacing: 3,
              fontWeight: FontWeight.w600))),
      Expanded(child: Divider(
          color: const Color(0xFFD4941A).withOpacity(0.4), thickness: 1)),
    ]);
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});
  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(color: Color(0xFF4A3728), fontSize: 11,
          fontFamily: 'Georgia', letterSpacing: 1.5, fontWeight: FontWeight.w600));
}

class _KemetFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _KemetFormField({
    required this.controller, required this.hint, required this.prefixIcon,
    this.obscureText = false, this.keyboardType, this.suffixIcon, this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
          color: Color(0xFF2C1810), fontFamily: 'Georgia', fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: const Color(0xFF8B7355).withOpacity(0.6),
            fontFamily: 'Georgia', fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF8B7355), size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF0EBE3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFFD4941A).withOpacity(0.15))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(0xFFD4941A).withOpacity(0.15))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD4941A), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCC3300), width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCC3300), width: 1.5)),
        errorStyle: const TextStyle(color: Color(0xFFCC3300), fontSize: 11, fontFamily: 'Georgia'),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _KemetButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  const _KemetButton(
      {required this.label, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity, height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFE8A020), Color(0xFFB8720A)]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(
              color: const Color(0xFFD4941A).withOpacity(0.35),
              blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Text(label, style: const TextStyle(color: Colors.white,
                  fontSize: 16, fontFamily: 'Georgia',
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  final String label;
  const _OrDivider({required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: TextStyle(color: Colors.grey.shade500,
              fontSize: 12, fontFamily: 'Georgia'))),
      Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
    ]);
  }
}
