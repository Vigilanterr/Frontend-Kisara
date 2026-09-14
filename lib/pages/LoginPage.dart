import 'package:flutter/material.dart';
import 'package:frontend/services/api.dart';
import 'package:frontend/pages/RegisterPage.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // --- PALET WARNA SESUAI DESAIN ---
  static const Color bgBlue = Color(0xFF4285F4); // Biru background atas
  static const Color textDarkBlue = Color(0xFF003399); // Biru tua untuk "Welcome Back!"
  static const Color buttonBlue = Color(0xFF678FEA); // Biru pudar tombol Login
  static const Color linkBlue = Color(0xFF4285F4); // Biru terang untuk link

  void _showMsg(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result != null && mounted) {
        _showMsg('Login berhasil');
        // Navigator.pop(context, true); // Sesuaikan navigasi
      }
    } on ApiException catch (e) {
      _showMsg(e.message);
    } catch (e) {
      _showMsg('Gagal login: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- STYLE INPUT FORM (Border Hitam Sesuai Desain) ---
  InputDecoration _inputStyle(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.black87),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 1.0), // Outline hitam solid
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: bgBlue, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBlue,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // --- BAGIAN ATAS: LOGO KISARA (40% Layar) ---
                    Container(
                      height: constraints.maxHeight * 0.4,
                      alignment: Alignment.center,
                      child: SafeArea(
                        bottom: false,
                        child: Image.asset(
                          'assets/logoKisara.png', // Pastikan file ini ada
                          width: 140,
                          // Jika logo aslinya tidak putih, aktifkan baris di bawah:
                          // color: Colors.white, 
                        ),
                      ),
                    ),
                    
                    // --- BAGIAN BAWAH: KOTAK PUTIH (Sisa Layar) ---
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // JUDUL WELCOME BACK
                                const Text(
                                  'Welcome Back!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: textDarkBlue,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // LABEL & INPUT EMAIL
                                const Text(
                                  'Email',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputStyle('Example@gmail.com', Icons.mail_outline_rounded),
                                  validator: (val) => (val == null || val.isEmpty) ? 'Email wajib diisi' : (!val.contains('@')) ? 'Email tidak valid' : null,
                                ),
                                const SizedBox(height: 16),
                                
                                // LABEL & INPUT PASSWORD
                                const Text(
                                  'Password',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) {
                                    if (!_isLoading) _login();
                                  },
                                  decoration: _inputStyle('••••••••', Icons.key_outlined).copyWith(
                                    suffixIcon: IconButton(
                                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                                      onPressed: () {
                                        setState(() => _obscurePassword = !_obscurePassword);
                                      },
                                    ),
                                  ),
                                  validator: (val) => (val == null || val.isEmpty) ? 'Password wajib diisi' : (val.length < 6) ? 'Minimal 6 karakter' : null,
                                ),
                                const SizedBox(height: 8),
                                
                                // TEKS FORGOT PASSWORD
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {},
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: linkBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                
                                // TOMBOL LOGIN UTAMA
                                SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: buttonBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(color: Colors.black, width: 1.0), // Border Hitam
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 21,
                                            height: 21,
                                            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                                          )
                                        : const Text(
                                            'Login',
                                            style: TextStyle(
                                              fontFamily: 'serif', // Font Serif
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                
                                // BAGIAN OR SIGN IN WITH
                                const Center(
                                  child: Text(
                                    'Or sign in with',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // ICON SOSIAL MEDIA
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Image.asset('assets/logoGoogle.png', width: 42, height: 42),
                                    ),
                                    const SizedBox(width: 24),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Image.asset('assets/logoFacebook.png', width: 42, height: 42),
                                    ),
                                  ],
                                ),
                              Spacer(),
                                
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Don't have an account? ",
                                        style: TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage()));
                                        },
                                        child: const Text(
                                          'Sign Up',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: linkBlue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}