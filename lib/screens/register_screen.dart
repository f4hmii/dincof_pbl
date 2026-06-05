import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/colors.dart';
import '../providers/app_provider.dart';
import 'dart:developer' as developer;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _errorMessage = '');

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Validation
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Nama lengkap tidak boleh kosong');
      return;
    }
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
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password minimal 6 karakter');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Konfirmasi password tidak cocok');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = context.read<AppProvider>();
      final registerSuccess = await provider.registerUser(name, email, password);

      if (!mounted) return;

      if (registerSuccess) {
        developer.log('✅ Register berhasil: $email');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() => _errorMessage = 'Email sudah terdaftar atau registrasi gagal');
      }
    } catch (e) {
      developer.log('❌ Register error: $e', error: e);
      setState(() => _errorMessage = 'Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  'Join Dincoff to get your favorite coffee.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              // Error Message
              if (_errorMessage.isNotEmpty) ...[
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
                const SizedBox(height: 20),
              ],
              _buildTextField(context, 'Full Name', _nameController, enabled: !_isLoading),
              const SizedBox(height: 20),
              _buildTextField(context, 'Email', _emailController, enabled: !_isLoading),
              const SizedBox(height: 20),
              _buildTextField(context, 'Password', _passwordController, obscure: true, enabled: !_isLoading),
              const SizedBox(height: 20),
              _buildTextField(context, 'Confirm Password', _confirmPasswordController, obscure: true, enabled: !_isLoading),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
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
                        'Register',
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
                    'Already have an account?',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, TextEditingController controller, {bool obscure = false, bool enabled = true}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
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
    );
  }
}
