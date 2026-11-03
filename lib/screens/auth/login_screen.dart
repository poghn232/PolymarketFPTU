import 'package:flutter/material.dart';
import '../../services/app_service.dart';
import '../../theme/fpt_theme.dart';
import '../../widgets/fpt_logo.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email và mật khẩu')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final appService = AppService();
    final success = await appService.login(email, password);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email hoặc mật khẩu không chính xác!'),
          backgroundColor: FptColors.noRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              // Header Logo & Branding
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF37021).withOpacity(0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: 80,
                          height: 80,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const FptLogo(size: 42),
                    const SizedBox(height: 10),
                    const Text(
                      'Sàn Dự Đoán Kẹo Sinh Viên FPT',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: FptColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: FptColors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '🎓 Đề tài học tập môn học • Phi lợi nhuận',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: FptColors.orangeDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Normal Login Form
              const Text(
                'Đăng nhập tài khoản',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: FptColors.textDark,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email FPT (@fpt.edu.vn hoặc @fe.edu.vn)',
                  prefixIcon: Icon(Icons.email_outlined, color: FptColors.orange),
                  hintText: 'VD: admin@fpt.edu.vn hoặc student@fpt.edu.vn',
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: const Icon(Icons.lock_outline, color: FptColors.orange),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: FptColors.gray600,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'ĐĂNG NHẬP',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Register Navigation
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Chưa có tài khoản? ',
                    style: TextStyle(color: FptColors.gray600, fontSize: 14),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      'Đăng ký (+50 🍬)',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: FptColors.orange,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),

              // Ghi chú tài khoản admin và sinh viên để kiểm tra
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: FptColors.gray50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: FptColors.gray200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: FptColors.blue),
                        SizedBox(width: 6),
                        Text(
                          'Tài khoản đăng nhập có sẵn trong cơ sở dữ liệu SQLite:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: FptColors.textDark),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Quản trị viên: admin@fpt.edu.vn (Mật khẩu: admin123)\n• Sinh viên mẫu: student@fpt.edu.vn (Mật khẩu: student123)',
                      style: TextStyle(fontSize: 12, color: FptColors.gray800, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
