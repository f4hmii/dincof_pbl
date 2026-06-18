import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

// ============================================================
// LiquidLoyaltyBar — Custom Drawing Widget
// Progress bar berbentuk cairan bergelombang untuk poin member.
// Mendukung:
//   - Gelombang animasi loop menggunakan AnimationController.repeat()
//   - Warna berubah gradasi berdasarkan persentase poin
//   - Teks poin digambar di atas canvas via TextPainter
//   - Gesture onTap untuk info poin
// ============================================================

class LiquidLoyaltyBar extends StatefulWidget {
  final int currentPoints;  // poin saat ini
  final int maxPoints;      // poin maksimal untuk naik level
  final double height;      // tinggi bar

  const LiquidLoyaltyBar({
    super.key,
    required this.currentPoints,
    required this.maxPoints,
    this.height = 36.0,
  });

  @override
  State<LiquidLoyaltyBar> createState() => _LiquidLoyaltyBarState();
}

class _LiquidLoyaltyBarState extends State<LiquidLoyaltyBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(); // animasi gelombang terus-menerus
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double percent =
        (widget.currentPoints / widget.maxPoints).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.currentPoints} dari ${widget.maxPoints} poin terkumpul. '
              '${widget.maxPoints - widget.currentPoints} poin lagi untuk naik level!',
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _waveController,
        builder: (context, _) {
          return CustomPaint(
            size: Size(double.infinity, widget.height),
            painter: _LiquidBarPainter(
              percent: percent,
              animationValue: _waveController.value,
              currentPoints: widget.currentPoints,
              maxPoints: widget.maxPoints,
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// _LiquidBarPainter — inti CustomPainter progress cairan
// ============================================================
class _LiquidBarPainter extends CustomPainter {
  final double percent;
  final double animationValue;
  final int currentPoints;
  final int maxPoints;

  _LiquidBarPainter({
    required this.percent,
    required this.animationValue,
    required this.currentPoints,
    required this.maxPoints,
  });

  /// Tentukan warna cairan berdasarkan persentase poin
  List<Color> _getLiquidColors() {
    if (percent > 0.8) {
      // > 80% → hijau emas (level hampir penuh)
      return [const Color(0xFF66BB6A), const Color(0xFF43A047)];
    } else if (percent > 0.5) {
      // > 50% → amber
      return [const Color(0xFFFFB300), const Color(0xFFFF8F00)];
    } else {
      // < 50% → coklat kopi
      return [const Color(0xFF8B6F47), AppColors.primary];
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double radius = h / 2;

    // ── 1. Gambar wadah (background bar) ──────────────────────────
    final Paint bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final RRect bgRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      Radius.circular(radius),
    );
    canvas.drawRRect(bgRRect, bgPaint);

    if (percent <= 0) return;

    // ── 2. Gambar cairan bergelombang di dalam bar ─────────────────
    canvas.save();
    canvas.clipRRect(bgRRect); // potong ke bentuk rounded bar

    final List<Color> colors = _getLiquidColors();
    final double liquidRight = w * percent;
    final double waveAmplitude = h * 0.18; // tinggi gelombang
    final double phase = animationValue * 2 * pi;

    // Buat path cairan dengan gelombang di tepi kanan
    final Path liquidPath = Path();
    liquidPath.moveTo(0, 0);
    liquidPath.lineTo(liquidRight - waveAmplitude * 2, 0);

    // Gelombang di ujung cairan (vertikal — tepi kanan bergelombang)
    for (double y = 0; y <= h; y += 1) {
      final double relativeY = y / h;
      final double waveX = liquidRight +
          waveAmplitude * sin(relativeY * 4 * pi + phase);
      liquidPath.lineTo(waveX, y);
    }

    liquidPath.lineTo(0, h);
    liquidPath.close();

    // Juga gambar gelombang horizontal di permukaan atas cairan (jika penuh)
    // untuk efek lebih dinamis
    final Path surfacePath = Path();
    surfacePath.moveTo(0, h * 0.35);
    for (double x = 0; x <= liquidRight; x += 2) {
      final double relX = x / w;
      final double surfaceY =
          h * 0.3 + waveAmplitude * sin(relX * 3 * pi + phase + 1.5);
      surfacePath.lineTo(x, surfaceY);
    }
    surfacePath.lineTo(liquidRight, h);
    surfacePath.lineTo(0, h);
    surfacePath.close();

    // Gradient cairan (kiri → kanan)
    final Paint liquidPaint = Paint()
      ..shader = LinearGradient(
        colors: [colors[0].withOpacity(0.9), colors[1]],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromLTWH(0, 0, liquidRight, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(liquidPath, liquidPaint);

    // Lapisan surface tipis lebih terang (efek shimmer/gloss)
    final Paint surfacePaint = Paint()
      ..color = colors[0].withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawPath(surfacePath, surfacePaint);

    canvas.restore();

    // ── 3. Garis border bar ────────────────────────────────────────
    final Paint borderPaint = Paint()
      ..color = colors[1].withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(bgRRect, borderPaint);

    // ── 4. Teks poin di tengah bar ─────────────────────────────────
    final String label = '$currentPoints / $maxPoints pts';
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: percent > 0.4 ? Colors.white : colors[1],
          fontSize: h * 0.38,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: w);
    tp.paint(
      canvas,
      Offset((w - tp.width) / 2, (h - tp.height) / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidBarPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.percent != percent;
  }
}
