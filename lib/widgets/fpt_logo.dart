import 'package:flutter/material.dart';

class FptLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const FptLogo({
    super.key,
    this.size = 36,
    this.showText = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // FPT 3 Slanted Shapes
        CustomPaint(
          size: Size(size * 1.1, size),
          painter: _FptLogoPainter(),
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'FPT ',
                      style: TextStyle(
                        fontSize: size * 0.52,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFF37021),
                        letterSpacing: -0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'MARKET',
                      style: TextStyle(
                        fontSize: size * 0.52,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0054A6),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF37021).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '🍬 KẸO CÓC CAMPUS',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFD65809),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _FptLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // FPT Signature 3 Color Ribbons: Orange (#F37021), Green (#00904B), Blue (#0054A6)
    final orangePaint = Paint()..color = const Color(0xFFF37021)..style = PaintingStyle.fill;
    final greenPaint = Paint()..color = const Color(0xFF00904B)..style = PaintingStyle.fill;
    final bluePaint = Paint()..color = const Color(0xFF0054A6)..style = PaintingStyle.fill;

    final slant = w * 0.22;
    final barW = w * 0.24;
    final gap = w * 0.08;

    // 1. Orange Bar
    final path1 = Path()
      ..moveTo(0, h)
      ..lineTo(slant, 0)
      ..lineTo(slant + barW, 0)
      ..lineTo(barW, h)
      ..close();
    canvas.drawPath(path1, orangePaint);

    // 2. Green Bar
    final x2 = barW + gap;
    final path2 = Path()
      ..moveTo(x2, h)
      ..lineTo(x2 + slant, 0)
      ..lineTo(x2 + slant + barW, 0)
      ..lineTo(x2 + barW, h)
      ..close();
    canvas.drawPath(path2, greenPaint);

    // 3. Blue Bar
    final x3 = x2 + barW + gap;
    final path3 = Path()
      ..moveTo(x3, h)
      ..lineTo(x3 + slant, 0)
      ..lineTo(x3 + slant + barW, 0)
      ..lineTo(x3 + barW, h)
      ..close();
    canvas.drawPath(path3, bluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
