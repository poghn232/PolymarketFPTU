import 'package:flutter/material.dart';
import '../../services/app_service.dart';
import '../../theme/fpt_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _studentCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedCampus = 'Hà Nội (Hòa Lạc)';
  bool _isLoading = false;

  final List<String> _campuses = [
    'Hà Nội (Hòa Lạc)',
    'TP.HCM (Quận 9)',
    'Đà Nẵng',
    'Cần Thơ',
    'Quy Nhơn',
  ];

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _fullNameController.text.trim();
    final code = _studentCodeController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passwordController.text;

    if (name.isEmpty || code.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ các thông tin')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final appService = AppService();
    final success = await appService.register(
      fullName: name,
      studentCode: code,
      email: email,
      campus: _selectedCampus,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Chào mừng bạn! Đã nhận 50 🍬 Kẹo vào tài khoản.'),
          backgroundColor: FptColors.yesGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email này đã được sử dụng!'),
          backgroundColor: FptColors.noRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Đăng ký Tân Sinh Viên'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Candy Banner (50 Kẹo)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDBA74)),
                ),
                child: const Row(
                  children: [
                    Text('🍬', style: TextStyle(fontSize: 32)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ưu đãi đặc biệt!',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF9A3412),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Nhận ngay 50 KẸO 🍬',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFC2410C),
                            ),
                          ),
                          Text(
                            'Dành cho tân sinh viên bắt đầu trải nghiệm dự đoán môn học và sự kiện campus.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF7C2D12)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên sinh viên',
                  prefixIcon: Icon(Icons.person_outline, color: FptColors.orange),
                  hintText: 'VD: Nguyễn Văn Cóc',
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _studentCodeController,
                decoration: const InputDecoration(
                  labelText: 'Mã số sinh viên (MSSV)',
                  prefixIcon: Icon(Icons.badge_outlined, color: FptColors.orange),
                  hintText: 'VD: SE180123',
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email sinh viên FPT',
                  prefixIcon: Icon(Icons.email_outlined, color: FptColors.orange),
                  hintText: 'VD: cocnvse180123@fpt.edu.vn',
                ),
              ),
              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                initialValue: _selectedCampus,
                decoration: const InputDecoration(
                  labelText: 'Cơ sở đào tạo (Campus)',
                  prefixIcon: Icon(Icons.location_city_outlined, color: FptColors.orange),
                ),
                items: _campuses.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCampus = val);
                },
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  prefixIcon: Icon(Icons.lock_outline, color: FptColors.orange),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'HOÀN TẤT ĐĂNG KÝ (+50 🍬)',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
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
