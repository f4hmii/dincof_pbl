import 'dart:math';
import 'package:flutter/material.dart';

// ============================================================
// CoffeeBeanLoadingWidget — Custom Drawing Widget
// Loading indicator berbentuk 3 biji kopi yang berputar.
// Menggantikan CircularProgressIndicator biasa.
// Mendukung:
//   - Setiap biji kopi digambar manual (oval + garis tengah)
//   - 3 biji berputar dalam orbit melingkar (0°, 120°, 240°)
//   - Ukuran dan warna bisa dikustomisasi
// ============================================================

class CoffeeBeanLoadingWidget extends StatefulWidget {
  final double size;
  final Color color;

  const CoffeeBeanLoadingWidget({
    super.key,
    this.size = 40.0,
    this.color = const Color(0xFF6F4E37),
  });

  @override
  State<CoffeeBeanLoadingWidget> createState() =>
      _CoffeeBeanLoadingWidgetState();
}

class _CoffeeBeanLoadingWidgetState extends State<CoffeeBeanLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(); // rotasi terus menerus
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _CoffeeBeanPainter(
            animationValue: _rotationController.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

// ============================================================
// _CoffeeBeanPainter — inti CustomPainter biji kopi berputar
// ============================================================
class _CoffeeBeanPainter extends CustomPainter {
  final double animationValue; // 0.0 – 1.0
  final Color color;

  _CoffeeBeanPainter({
    required this.animationValue,
    required this.color,
  });

  /// Menggambar 1 biji kopi di [center] dengan rotasi [angle]
  void _drawBean(Canvas canvas, Offset center, double angle, double beanSize, Color beanColor) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    // ── Badan biji kopi (oval) ──────────────────────────────────────
    final Paint beanPaint = Paint()
      ..color = beanColor
      ..style = PaintingStyle.fill;

    final RRect beanBody = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset.zero,
        width: beanSize,
        height: beanSize * 0.62,
      ),
      Radius.circular(beanSize * 0.3),
    );
    canvas.drawRRect(beanBody, beanPaint);

    // ── Garis tengah khas biji kopi ─────────────────────────────────
    final Paint linePaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = beanSize * 0.08
      ..strokeCap = StrokeCap.round;

    // Garis melengkung di tengah biji
    final Path centerLine = Path();
    centerLine.moveTo(-beanSize * 0.28, 0);
    centerLine.cubicTo(
      -beanSize * 0.1, -beanSize * 0.18,
      beanSize * 0.1, beanSize * 0.18,
      beanSize * 0.28, 0,
    );
    canvas.drawPath(centerLine, linePaint);

    // ── Highlight kecil (efek glossy) ───────────────────────────────
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-beanSize * 0.1, -beanSize * 0.12),
        width: beanSize * 0.22,
        height: beanSize * 0.14,
      ),
      highlightPaint,
    );

    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double orbitRadius = size.width * 0.28; // radius orbit biji
    final double beanSize = size.width * 0.3;      // ukuran tiap biji
    final double baseAngle = animationValue * 2 * pi; // sudut rotasi orbit

    // 3 biji kopi, tiap biji offset 120° (= 2π/3)
    for (int i = 0; i < 3; i++) {
      final double orbitAngle = baseAngle + (i * 2 * pi / 3);

      // Posisi di orbit melingkar
      final Offset beanCenter = Offset(
        cx + orbitRadius * cos(orbitAngle),
        cy + orbitRadius * sin(orbitAngle),
      );

      // Opacity makin transparan di bagian bawah orbit (efek kedalaman)
      final double opacityFactor = ((sin(orbitAngle - pi / 2) + 1) / 2)
          .clamp(0.4, 1.0);

      // Warna tiap biji sedikit berbeda shade
      final Color beanColor = Color.lerp(
        color.withOpacity(opacityFactor),
        color.withOpacity(opacityFactor * 0.7),
        i * 0.25,
      )!;

      // Rotasi biji kopi sendiri berlawanan arah orbit (memberi kesan berputar)
      final double selfRotation = -baseAngle * 1.5 + (i * pi / 3);

      _drawBean(canvas, beanCenter, selfRotation, beanSize, beanColor);
    }

    // ── Titik pusat kecil ──────────────────────────────────────────
    final Paint centerDotPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), size.width * 0.06, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant _CoffeeBeanPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
