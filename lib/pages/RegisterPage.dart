import 'package:flutter/material.dart';
import 'package:frontend/services/api.dart';
import 'package:frontend/pages/LoginPage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  // --- PALET WARNA SESUAI DESAIN ---
  static const Color bgBlue = Color(0xFF4285F4);
  static const Color textDarkBlue = Color(0xFF003399);
  static const Color buttonBlue = Color(0xFF678FEA);
  static const Color linkBlue = Color(0xFF4285F4);

  void _showMsg(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result != null && mounted) {
        _showMsg('Registrasi berhasil, silakan login');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } on ApiException catch (e) {
      _showMsg(e.message);
    } catch (e) {
      _showMsg('Gagal registrasi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
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
        borderSide: const BorderSide(color: Colors.black, width: 1.0),
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
                          'assets/logoKisara.png', // Pastikan path ini benar
                          width: 140,
                          // color: Colors.white, // Aktifkan jika logo asli berwarna gelap
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
                                // JUDUL CREATE YOUR ACCOUNT
                                const Text(
                                  'Create Your Account',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: textDarkBlue,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // SUB-JUDUL JOIN KISARA
                                const Text(
                                  'Join Kisara and start sharing your content',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'serif',
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // LABEL & INPUT USERNAME
                                const Text(
                                  'Username',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _nameController,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputStyle('John Susilo', Icons.person),
                                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Username wajib diisi' : null,
                                ),
                                const SizedBox(height: 16),

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
                                  decoration: _inputStyle('Example@gmail.com', Icons.email),
                                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Email wajib diisi' : (!val.contains('@')) ? 'Email tidak valid' : null,
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
                                    if (!_isLoading) _register();
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
                                const SizedBox(height: 28),

                                // TOMBOL REGISTER (Desain persis dengan tombol Login di gambar)
                                SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: buttonBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: const BorderSide(color: Colors.black, width: 1.0),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 21,
                                            height: 21,
                                            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                                          )
                                        : const Text(
                                            'Register', // Diubah dari 'Login' agar masuk akal untuk pendaftaran
                                            style: TextStyle(
                                              fontFamily: 'serif',
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

                                // SPACER AGAR TEKS LOGIN TETAP DI BAWAH
                                const Spacer(),

                                // BAGIAN ALREADY HAVE AN ACCOUNT? LOGIN
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10, top: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        "Already have an account? ",
                                        style: TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.bold),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (context) => const LoginPage()),
                                          );
                                        },
                                        child: const Text(
                                          'Login',
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