import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project/screens/mock_user_entity.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  final _nameCtl = TextEditingController();
  final _ageCtl = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  // Healthcare color scheme
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color secondaryTeal = Color(0xFF00ACC1);
  static const Color accentGreen = Color(0xFF66BB6A);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color darkBlue = Color(0xFF1565C0);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(authRepositoryProvider);
    try {
      if (_isRegister) {
        await repo.signUp(
          email: _emailCtl.text.trim(),
          password: _passCtl.text,
          name: _nameCtl.text.trim(),
          age: int.parse(_ageCtl.text.trim()),
        );
      } else {
        await repo.signIn(
            email: _emailCtl.text.trim(), password: _passCtl.text);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtl.dispose();
    _passCtl.dispose();
    _nameCtl.dispose();
    _ageCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              lightBlue,
              Color(0xFFF1F8E9), // Softer greenish-white background
              Colors.white,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo container enhanced with layered shadows
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withOpacity(0.25),
                              blurRadius: 25,
                              spreadRadius: 6,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: Colors.teal.withOpacity(0.15),
                              blurRadius: 15,
                              spreadRadius: 3,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.health_and_safety,
                          size: 70,
                          color: primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'HealthAI',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: darkBlue,
                          letterSpacing: -0.7,
                          fontFamily: 'Montserrat', // modern sans serif font
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your AI-Powered Health Companion',
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 44),

                      // Auth Card with softly elevated shadows and gradient background
                      Card(
                        elevation: 15,
                        shadowColor: secondaryTeal.withOpacity(0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white,
                                Colors.white.withOpacity(0.97),
                              ],
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isRegister
                                      ? 'Create Account'
                                      : 'Welcome Back',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: darkBlue,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _isRegister
                                      ? 'Join thousands of users improving their health'
                                      : 'Sign in to continue your health journey',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 36),

                                // Fields remain unchanged except colors and borders updated below
                                // Name and Age inputs when _isRegister true
                                if (_isRegister) ...[
                                  TextFormField(
                                    controller: _nameCtl,
                                    decoration: InputDecoration(
                                      labelText: 'Full Name',
                                      prefixIcon: Icon(Icons.person_outline,
                                          color: secondaryTeal),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                            color: Colors.grey[350]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                            color: primaryBlue, width: 3),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                    ),
                                    textCapitalization:
                                        TextCapitalization.words,
                                    validator: (v) =>
                                        (v != null && v.trim().isNotEmpty)
                                            ? null
                                            : 'Please enter your full name',
                                  ),
                                  const SizedBox(height: 22),
                                  TextFormField(
                                    controller: _ageCtl,
                                    decoration: InputDecoration(
                                      labelText: 'Age',
                                      prefixIcon: Icon(Icons.cake_outlined,
                                          color: secondaryTeal),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                            color: Colors.grey[350]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                        borderSide: BorderSide(
                                            color: primaryBlue, width: 3),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty)
                                        return 'Please enter your age';
                                      final age = int.tryParse(v.trim());
                                      if (age == null)
                                        return 'Please enter a valid age';
                                      if (age < 13 || age > 120)
                                        return 'Please enter a valid age (13-120)';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 22),
                                ],

                                // Email Field
                                TextFormField(
                                  controller: _emailCtl,
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    prefixIcon: Icon(Icons.email_outlined,
                                        color: secondaryTeal),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide:
                                          BorderSide(color: Colors.grey[350]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                          color: primaryBlue, width: 3),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v == null || v.trim().isEmpty)
                                      return 'Please enter your email address';
                                    if (!RegExp(
                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                        .hasMatch(v.trim()))
                                      return 'Please enter a valid email address';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 22),

                                // Password Field
                                TextFormField(
                                  controller: _passCtl,
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                    prefixIcon: Icon(Icons.lock_outline,
                                        color: secondaryTeal),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: Colors.grey[600],
                                      ),
                                      onPressed: () => setState(() =>
                                          _obscurePassword = !_obscurePassword),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide:
                                          BorderSide(color: Colors.grey[350]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                          color: primaryBlue, width: 3),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                  ),
                                  obscureText: _obscurePassword,
                                  validator: (v) {
                                    if (v == null || v.isEmpty)
                                      return 'Please enter your password';
                                    if (_isRegister && v.length < 6)
                                      return 'Password must be at least 6 characters';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 28),

                                // Error message and other widgets remain unchanged with color tweaks

                                if (_error != null)
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(10),
                                      border:
                                          Border.all(color: Colors.red[300]!),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.error_outline,
                                            color: Colors.red[700], size: 22),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            _error!,
                                            style: TextStyle(
                                                color: Colors.red[700],
                                                fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (_error != null) const SizedBox(height: 24),

                                // Submit Button with enhanced gradient and shadow
                                _loading
                                    ? Container(
                                        padding: const EdgeInsets.all(18),
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  primaryBlue),
                                        ),
                                      )
                                    : SizedBox(
                                        width: double.infinity,
                                        height: 58,
                                        child: ElevatedButton(
                                          onPressed: _submit,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            padding: EdgeInsets.zero,
                                          ),
                                          child: Ink(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  primaryBlue,
                                                  secondaryTeal
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: primaryBlue
                                                      .withOpacity(0.4),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Container(
                                              alignment: Alignment.center,
                                              child: Text(
                                                _isRegister
                                                    ? 'Create Account'
                                                    : 'Sign In',
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                const SizedBox(height: 24),

                                // Toggle button remains but with updated text style for clarity
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isRegister = !_isRegister;
                                      _error = null;
                                      if (!_isRegister) {
                                        _nameCtl.clear();
                                        _ageCtl.clear();
                                      }
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: primaryBlue,
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 15),
                                      children: [
                                        TextSpan(
                                          text: _isRegister
                                              ? 'Already have an account? '
                                              : 'Don\'t have an account? ',
                                        ),
                                        TextSpan(
                                          text: _isRegister
                                              ? 'Sign In'
                                              : 'Create Account',
                                          style: TextStyle(
                                            color: primaryBlue,
                                            fontWeight: FontWeight.bold,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Footer remains but with slight adjustment for a softer tone
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.security,
                              size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 10),
                          Text(
                            'Your health data is secure and encrypted',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
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
        ),
      ),
    );
  }
}
