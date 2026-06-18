import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

// ============================================================
// EmptyCartWidget — Custom Drawing Widget (Troli Belanja)
// Menggambar troli belanja tampak samping secara manual
// menggunakan CustomPainter. Dilengkapi animasi:
//   - Floating / melayang naik turun (bobbing)
//   - Uap kopi di dalam troli bergerak
//   - Bintang kecil berkelip di sekitar troli
// Gesture: onTap untuk efek "goyang" (shake)
// ============================================================

class EmptyCartWidget extends StatefulWidget {
  final double size;

  const EmptyCartWidget({super.key, this.size = 180.0});

  @override
  State<EmptyCartWidget> createState() => _EmptyCartWidgetState();
}

class _EmptyCartWidgetState extends State<EmptyCartWidget>
    with TickerProviderStateMixin {
  // Animasi floating (naik turun)
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  // Animasi uap kopi & bintang
  late AnimationController _steamController;

  // Animasi shake saat di-tap
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();

    // Float: naik turun dalam 2 detik
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Steam & sparkle loop
    _steamController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Shake saat tap
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _steamController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onTap() {
    _shakeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _floatAnimation,
          _steamController,
          _shakeAnimation,
        ]),
        builder: (context, _) {
          // Offset goyang kiri-kanan saat di-tap
          final double shakeOffset = _shakeController.isAnimating
              ? 10.0 *
                    sin(_shakeAnimation.value * pi * 6) *
                    (1 - _shakeAnimation.value)
              : 0.0;

          return Transform.translate(
            offset: Offset(shakeOffset, _floatAnimation.value),
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _TrolleyPainter(
                steamValue: _steamController.value,
                shakeValue: _shakeController.value,
                primaryColor: AppColors.primary,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// _TrolleyPainter — CustomPainter troli belanja tampak samping
//
// Anatomi troli (tampak kiri → kanan, handle di kanan):
//
//          ══════════════╗  ← handle
//         ╔══════════════╝
//         ║  [isi kosong] ║
//         ║_______________║
//          \             /   ← dasar keranjang miring
//           \___________/
//            |         |    ← kaki depan & belakang
//           ( )       ( )   ← roda depan & belakang
//
// ============================================================
class _TrolleyPainter extends CustomPainter {
  final double steamValue;
  final double shakeValue;
  final Color primaryColor;

  _TrolleyPainter({
    required this.steamValue,
    required this.shakeValue,
    required this.primaryColor,
  });

  // ── helper paint ─────────────────────────────────────────────────
  Paint _stroke(Color c, double w, {StrokeCap cap = StrokeCap.round}) =>
      Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = w
        ..strokeCap = cap
        ..strokeJoin = StrokeJoin.round;

  Paint _fill(Color c) => Paint()
    ..color = c
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // ── Koordinat utama troli ─────────────────────────────────────
    // Keranjang (basket) — bagian atas troli
    final double bLeft   = w * 0.10;  // kiri atas keranjang
    final double bRight  = w * 0.78;  // kanan atas keranjang
    final double bTop    = h * 0.22;  // atas keranjang
    final double bBottom = h * 0.62;  // bawah keranjang

    // Dasar keranjang sedikit mengerucut ke dalam (trapesoidal)
    final double dLeft   = w * 0.18;  // kiri bawah keranjang
    final double dRight  = w * 0.72;  // kanan bawah keranjang

    // Posisi roda
    final double wheelY      = h * 0.875;
    final double wheelFrontX = w * 0.22;  // roda depan (kiri)
    final double wheelBackX  = w * 0.72;  // roda belakang (kanan)
    final double wheelR      = w * 0.072;

    // ── 1. Bintang / sparkle latar ────────────────────────────────
    _drawSparkles(canvas, w, h);

    // ── 2. Handle (pegangan) troli ────────────────────────────────
    _drawHandle(canvas, w, bRight, bTop);

    // ── 3. Keranjang troli ────────────────────────────────────────
    _drawBasket(canvas, bLeft, bRight, bTop, bBottom, dLeft, dRight);

    // ── 4. Rangka bawah / chassis ─────────────────────────────────
    _drawFrame(canvas, dLeft, dRight, bBottom, wheelFrontX, wheelBackX, wheelY, wheelR);

    // ── 5. Roda troli ─────────────────────────────────────────────
    _drawWheel(canvas, wheelFrontX, wheelY, wheelR);
    _drawWheel(canvas, wheelBackX, wheelY, wheelR);

    // ── 6. Cangkir kopi kecil di dalam keranjang ──────────────────
    _drawCoffeeCup(canvas, w, bTop, bBottom);

    // ── 7. Uap dari cangkir kopi ──────────────────────────────────
    _drawSteam(canvas, w, bTop);

    // ── 8. Tanda "?" di bawah ─────────────────────────────────────
    _drawHint(canvas, w, h);
  }

  // ── Bintang berkelip ─────────────────────────────────────────────
  void _drawSparkles(Canvas canvas, double w, double h) {
    final double alpha = 0.12 + 0.12 * sin(steamValue * 2 * pi);
    final Paint p = _fill(primaryColor.withValues(alpha: alpha));

    final List<Offset> pos = [
      Offset(w * 0.05, h * 0.20),
      Offset(w * 0.95, h * 0.25),
      Offset(w * 0.04, h * 0.72),
      Offset(w * 0.96, h * 0.68),
      Offset(w * 0.12, h * 0.92),
      Offset(w * 0.88, h * 0.90),
    ];

    for (int i = 0; i < pos.length; i++) {
      final double r = 2.5 + 2.0 * sin(steamValue * 2 * pi + i * pi / 3);
      _drawStar(canvas, pos[i], r, p);
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint p) {
    final Path path = Path();
    for (int i = 0; i < 8; i++) {
      final double angle = i * pi / 4;
      final double radius = i.isEven ? r : r * 0.45;
      final double x = center.dx + radius * cos(angle - pi / 2);
      final double y = center.dy + radius * sin(angle - pi / 2);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, p);
  }

  // ── Handle / pegangan troli (horizontal bar + tiang) ─────────────
  void _drawHandle(Canvas canvas, double w, double bRight, double bTop) {
    final Color c = primaryColor;

    // Tiang vertikal handle (dari tepi kanan keranjang ke atas)
    canvas.drawLine(
      Offset(bRight, bTop),
      Offset(bRight, bTop - w * 0.10),
      _stroke(c, 5.0),
    );

    // Bar horizontal handle (ke kanan menonjol)
    final double hLeft  = bRight - w * 0.04;
    final double hRight = w * 0.94;
    final double hY     = bTop - w * 0.10;

    canvas.drawLine(
      Offset(hLeft, hY),
      Offset(hRight, hY),
      _stroke(c, 6.5, cap: StrokeCap.round),
    );

    // Ujung handle melengkung (grip)
    final RRect grip = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(hRight + 2, hY),
        width: 8,
        height: 12,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(grip, _fill(c.withValues(alpha: 0.7)));
    canvas.drawRRect(grip, _stroke(c, 1.5));
  }

  // ── Badan keranjang troli ─────────────────────────────────────────
  void _drawBasket(Canvas canvas,
      double bLeft, double bRight, double bTop, double bBottom,
      double dLeft, double dRight) {

    // Bentuk keranjang: trapesoid (atas lebih lebar, bawah mengerucut)
    final Path basketPath = Path()
      ..moveTo(bLeft, bTop)
      ..lineTo(dLeft, bBottom)
      ..lineTo(dRight, bBottom)
      ..lineTo(bRight, bTop)
      ..close();

    // Bayangan keranjang
    canvas.drawPath(
      basketPath,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // Fill keranjang (terang transparan)
    canvas.drawPath(basketPath, _fill(primaryColor.withValues(alpha: 0.07)));

    // Border keranjang
    canvas.drawPath(basketPath, _stroke(primaryColor, 3.0));

    // ── Garis horizontal dalam keranjang (rak/mesh) ─────────────
    final int hLines = 3;
    for (int i = 1; i <= hLines; i++) {
      final double t = i / (hLines + 1);
      final double y = bTop + (bBottom - bTop) * t;
      // Interpolasi x kiri & kanan mengikuti kemiringan keranjang
      final double lx = bLeft  + (dLeft  - bLeft)  * t;
      final double rx = bRight + (dRight - bRight) * t;
      canvas.drawLine(
        Offset(lx + 3, y),
        Offset(rx - 3, y),
        _stroke(primaryColor.withValues(alpha: 0.20), 1.5),
      );
    }

    // ── Garis vertikal dalam keranjang ───────────────────────────
    final int vLines = 4;
    for (int i = 1; i <= vLines; i++) {
      final double t = i / (vLines + 1);
      // Titik atas (di garis bibir)
      final double topX = bLeft + (bRight - bLeft) * t;
      // Titik bawah (di dasar, miring)
      final double botX = dLeft + (dRight - dLeft) * t;
      canvas.drawLine(
        Offset(topX, bTop + 3),
        Offset(botX, bBottom - 3),
        _stroke(primaryColor.withValues(alpha: 0.18), 1.2),
      );
    }

    // ── Bibir atas keranjang (lebih tebal) ──────────────────────
    canvas.drawLine(
      Offset(bLeft - 1, bTop),
      Offset(bRight + 1, bTop),
      _stroke(primaryColor, 4.0),
    );
  }

  // ── Rangka / kaki bawah troli ─────────────────────────────────────
  void _drawFrame(Canvas canvas,
      double dLeft, double dRight, double bBottom,
      double wheelFrontX, double wheelBackX,
      double wheelY, double wheelR) {

    final Color c = primaryColor;
    final double axleY = wheelY; // sumbu roda

    // Kaki depan (dari sudut kiri bawah keranjang ke roda depan)
    final Path frontLeg = Path()
      ..moveTo(dLeft, bBottom)
      ..lineTo(wheelFrontX, axleY - wheelR);
    canvas.drawPath(frontLeg, _stroke(c, 3.5));

    // Kaki belakang (dari sudut kanan bawah keranjang ke roda belakang)
    final Path backLeg = Path()
      ..moveTo(dRight, bBottom)
      ..lineTo(wheelBackX, axleY - wheelR);
    canvas.drawPath(backLeg, _stroke(c, 3.5));

    // Batang sumbu bawah (menghubungkan kedua roda)
    canvas.drawLine(
      Offset(wheelFrontX, axleY),
      Offset(wheelBackX, axleY),
      _stroke(c.withValues(alpha: 0.30), 2.0),
    );
  }

  // ── Roda troli ────────────────────────────────────────────────────
  void _drawWheel(Canvas canvas, double cx, double cy, double r) {
    // Bayangan roda
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + r + 2), width: r * 2, height: r * 0.4),
      _fill(primaryColor.withValues(alpha: 0.08)),
    );

    // Isi roda
    canvas.drawCircle(Offset(cx, cy), r, _fill(primaryColor.withValues(alpha: 0.12)));

    // Ban luar
    canvas.drawCircle(Offset(cx, cy), r, _stroke(primaryColor, 3.0));

    // Velg / lingkaran dalam
    canvas.drawCircle(Offset(cx, cy), r * 0.55, _stroke(primaryColor.withValues(alpha: 0.40), 1.5));

    // Hub tengah
    canvas.drawCircle(Offset(cx, cy), r * 0.18, _fill(primaryColor));

    // Jeruji (spoke) × 4
    for (int i = 0; i < 4; i++) {
      final double angle = i * pi / 4;
      canvas.drawLine(
        Offset(cx + cos(angle) * r * 0.18, cy + sin(angle) * r * 0.18),
        Offset(cx + cos(angle) * r * 0.52, cy + sin(angle) * r * 0.52),
        _stroke(primaryColor.withValues(alpha: 0.45), 1.5),
      );
    }
  }

  // ── Cangkir kopi kecil di dalam keranjang ────────────────────────
  void _drawCoffeeCup(Canvas canvas, double w, double bTop, double bBottom) {
    final double cx   = w * 0.44;
    final double midY = (bTop + bBottom) / 2 + (bBottom - bTop) * 0.05;
    final double cW   = w * 0.20;
    final double cH   = cW * 0.82;

    // Badan cangkir (trapesoid kecil)
    final Path cup = Path()
      ..moveTo(cx - cW / 2, midY - cH / 2)
      ..lineTo(cx - cW * 0.40, midY + cH / 2)
      ..quadraticBezierTo(cx, midY + cH / 2 + cH * 0.08, cx + cW * 0.40, midY + cH / 2)
      ..lineTo(cx + cW / 2, midY - cH / 2)
      ..close();

    canvas.drawPath(cup, _fill(primaryColor.withValues(alpha: 0.45)));
    canvas.drawPath(cup, _stroke(primaryColor, 2.0));

    // Garis bibir cangkir
    canvas.drawLine(
      Offset(cx - cW / 2 - 1, midY - cH / 2),
      Offset(cx + cW / 2 + 1, midY - cH / 2),
      _stroke(primaryColor, 2.5),
    );

    // Cairan kopi di dalam (setengah penuh)
    canvas.save();
    canvas.clipPath(cup);
    final double liquidTop = midY;
    final Path liquid = Path()
      ..moveTo(cx - cW, liquidTop)
      ..lineTo(cx - cW, midY + cH)
      ..lineTo(cx + cW, midY + cH)
      ..lineTo(cx + cW, liquidTop)
      ..close();
    canvas.drawPath(liquid, _fill(primaryColor.withValues(alpha: 0.30)));
    canvas.restore();

    // Gagang cangkir
    final Path handle = Path()
      ..moveTo(cx + cW * 0.38, midY - cH * 0.12)
      ..cubicTo(
        cx + cW * 0.62, midY - cH * 0.12,
        cx + cW * 0.62, midY + cH * 0.28,
        cx + cW * 0.38, midY + cH * 0.28,
      );
    canvas.drawPath(handle, _stroke(primaryColor, 2.0));
  }

  // ── Uap kopi bergerak ─────────────────────────────────────────────
  void _drawSteam(Canvas canvas, double w, double bTop) {
    final double cx    = w * 0.44;
    final double baseY = bTop - w * 0.01;
    final double phase = steamValue * 2 * pi;

    final Paint steamPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.10 + 0.09 * sin(phase))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 2; i++) {
      final double sx = cx + (i == 0 ? -w * 0.04 : w * 0.04);
      final double sh = w * 0.11;
      final double x1 =  5.0 * sin(phase + i * 1.3);
      final double x2 = -4.0 * sin(phase + i * 0.9);

      final Path s = Path()
        ..moveTo(sx, baseY)
        ..cubicTo(
          sx + x1, baseY - sh * 0.35,
          sx + x2, baseY - sh * 0.70,
          sx + (x1 + x2) / 2, baseY - sh,
        );
      canvas.drawPath(s, steamPaint);
    }
  }

  // ── Teks hint di bawah ────────────────────────────────────────────
  void _drawHint(Canvas canvas, double w, double h) {
    final TextPainter tp = TextPainter(
      text: TextSpan(
        text: 'tap ✦',
        style: TextStyle(
          color: primaryColor.withValues(alpha: 0.20),
          fontSize: w * 0.09,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset((w - tp.width) / 2, h * 0.88));
  }

  @override
  bool shouldRepaint(covariant _TrolleyPainter oldDelegate) {
    return oldDelegate.steamValue != steamValue ||
        oldDelegate.shakeValue != shakeValue;
  }
}
