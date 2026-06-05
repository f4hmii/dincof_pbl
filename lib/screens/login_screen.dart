import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../helpers/prefs_helper.dart';
import '../providers/app_provider.dart';
import 'dart:developer' as developer;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = '');

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validation
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Email tidak boleh kosong');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _errorMessage = 'Format email tidak valid');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Password tidak boleh kosong');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AppProvider>();
      final userData = await provider.loginUser(email, password);

      if (!mounted) return;

      if (userData != null) {
        // Save login data
        final username = userData['username'] as String? ?? 'User';
        final role = userData['role'] as String? ?? 'user';
        final userId = userData['id'] as String?;
        await PrefsHelper.saveLoginData(username, email, role, userId: userId);
        developer.log('✅ Login berhasil: $email');
        
        if (role == 'admin') {
          Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
        }
      } else {
        setState(() => _errorMessage = 'Email atau password salah');
      }
    } catch (e) {
      developer.log('❌ Login error: $e', error: e);
      setState(() => _errorMessage = 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'Dincoff',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Welcome back! Please login to your account.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 50),
              // Error Message
              if (_errorMessage.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              if (_errorMessage.isNotEmpty)
                const SizedBox(height: 20),
              // Email Field
              TextFormField(
                controller: _emailController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                ),
              ),
              const SizedBox(height: 20),
              // Password Field
              TextFormField(
                controller: _passwordController,
                enabled: !_isLoading,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.lightGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  suffixIcon: const Icon(Icons.visibility_off, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Login Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account?',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Demo Login Button
              TextButton(
                onPressed: _isLoading ? null : () {
                  final pwdController = TextEditingController();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          'Sandi Admin Diperlukan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        content: TextField(
                          controller: pwdController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Masukkan Sandi',
                            hintText: 'Sandi admin',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              if (pwdController.text == 'admin123') {
                                Navigator.pop(context);
                                await PrefsHelper.saveLoginData('Admin', 'admin@dincoff.com', 'admin');
                                if (mounted) {
                                  Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Sandi admin salah!'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: const Text('Masuk', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text(
                  'Login as Admin (Demo)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
