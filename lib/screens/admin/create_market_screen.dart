import 'package:flutter/material.dart';
import '../../services/app_service.dart';
import '../../theme/fpt_theme.dart';

class CreateMarketScreen extends StatefulWidget {
  const CreateMarketScreen({super.key});

  @override
  State<CreateMarketScreen> createState() => _CreateMarketScreenState();
}

class _CreateMarketScreenState extends State<CreateMarketScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _backstopController = TextEditingController(text: '50');
  
  String _selectedCategory = 'Học tập & Thi cử';
  String _selectedCampus = 'Toàn quốc';
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  final List<String> _categories = [
    'Học tập & Thi cử',
    'Vinh danh & Cóc Vàng',
    'Đời sống Campus',
    'Sự kiện & CLB',
    'Thể thao Vovinam',
    'Công nghệ & Hackathon',
  ];

  final List<String> _campuses = [
    'Toàn quốc',
    'Hà Nội (Hòa Lạc)',
    'TP.HCM (Quận 9)',
    'Đà Nẵng',
    'Cần Thơ',
    'Quy Nhơn',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _backstopController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final title = _titleController.text.trim();
    final desc = _descriptionController.text.trim();
    final backstop = int.tryParse(_backstopController.text) ?? 50;

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ tiêu đề và mô tả kèo')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final appService = AppService();
    await appService.createMarket(
      title: title,
      description: desc,
      category: _selectedCategory,
      campus: _selectedCampus,
      endDate: _endDate,
      initialAdminBackstop: backstop,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 Admin đã tạo kèo dự đoán mới thành công!'),
        backgroundColor: FptColors.yesGreen,
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (picked != null) {
      setState(() {
        _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Admin: Tạo Kèo Dự Đoán Mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Admin Note Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: FptColors.blue, size: 22),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tạo kèo dự đoán mới cho toàn bộ sinh viên FPT. Admin sẽ đóng vai trò nhà cái và bảo chứng kẹo cho kèo này.',
                      style: TextStyle(fontSize: 12, color: FptColors.blue, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề kèo dự đoán *',
                hintText: 'VD: Sinh viên ngành SE có đạt giải nhất Techday 2026?',
                prefixIcon: Icon(Icons.title, color: FptColors.orange),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Mô tả & Điều kiện chốt kèo (Rules) *',
                hintText: 'Nêu rõ tiêu chí xác định kết quả CÓ hay KHÔNG...',
                prefixIcon: Icon(Icons.notes, color: FptColors.orange),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Chủ đề / Danh mục',
                    ),
                    items: _categories.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCampus,
                    decoration: const InputDecoration(
                      labelText: 'Cơ sở Campus',
                    ),
                    items: _campuses.map((c) {
                      return DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCampus = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Kẹo bảo chứng Admin (Liquidity)
            TextField(
              controller: _backstopController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số kẹo Admin bảo chứng (Liquidity Pool)',
                hintText: '50',
                prefixIcon: Icon(Icons.shield, color: FptColors.orange),
                helperText: 'Nếu không ai cược bên còn lại, Admin dùng kẹo này chi trả hoặc nhận kẹo.',
                suffixText: '🍬 Kẹo',
              ),
            ),
            const SizedBox(height: 16),

            // Date Picker Tile
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: FptColors.gray200),
              ),
              leading: const Icon(Icons.calendar_today, color: FptColors.orange),
              title: const Text('Ngày kết thúc dự đoán', style: TextStyle(fontSize: 13)),
              subtitle: Text(
                '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                style: const TextStyle(fontWeight: FontWeight.w700, color: FptColors.textDark),
              ),
              trailing: const Icon(Icons.edit, size: 18),
              onTap: _pickDate,
            ),
            const SizedBox(height: 28),

            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _handleCreate,
                icon: const Icon(Icons.add_task),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text(
                        'ĐĂNG KÈO LÊN SÀN FPT',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
