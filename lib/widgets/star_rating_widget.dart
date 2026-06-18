import 'dart:math';
import 'package:flutter/material.dart';

// ============================================================
// StarRatingWidget — Custom Drawing Widget
// Menggambar bintang secara manual dengan CustomPainter.
// Mendukung:
//   - Bintang terisi sebagian (misal rating 3.7)
//   - Gesture onTapDown & onHorizontalDragUpdate untuk rating interaktif
//   - Animasi scale bounce saat nilai berubah
// ============================================================

class StarRatingWidget extends StatefulWidget {
  final double rating;       // nilai rating: 0.0 – 5.0
  final int starCount;       // jumlah bintang (default 5)
  final double size;         // ukuran tiap bintang
  final bool interactive;    // apakah bisa diubah user
  final ValueChanged<double>? onRatingChanged;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 24.0,
    this.interactive = false,
    this.onRatingChanged,
  });

  @override
  State<StarRatingWidget> createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget>
    with SingleTickerProviderStateMixin {
  late double _currentRating;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  @override
  void didUpdateWidget(covariant StarRatingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rating != widget.rating) {
      _currentRating = widget.rating;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _handleRatingUpdate(double localX) {
    if (!widget.interactive) return;
    final totalWidth = widget.starCount * (widget.size + 4);
    final newRating = (localX / totalWidth * widget.starCount)
        .clamp(0.5, widget.starCount.toDouble());
    // Bulatkan ke 0.5 terdekat
    final rounded = (newRating * 2).round() / 2;
    if (rounded != _currentRating) {
      setState(() => _currentRating = rounded);
      _bounceController.forward(from: 0.0);
      widget.onRatingChanged?.call(rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalWidth = widget.starCount * (widget.size + 4);

    return GestureDetector(
      onTapDown: widget.interactive
          ? (d) => _handleRatingUpdate(d.localPosition.dx)
          : null,
      onHorizontalDragUpdate: widget.interactive
          ? (d) => _handleRatingUpdate(d.localPosition.dx)
          : null,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.interactive ? _bounceAnimation.value : 1.0,
            child: child,
          );
        },
        child: SizedBox(
          width: totalWidth,
          height: widget.size + 4,
          child: CustomPaint(
            painter: _StarPainter(
              rating: _currentRating,
              starCount: widget.starCount,
              starSize: widget.size,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// _StarPainter — inti CustomPainter bintang
// ============================================================
class _StarPainter extends CustomPainter {
  final double rating;
  final int starCount;
  final double starSize;

  _StarPainter({
    required this.rating,
    required this.starCount,
    required this.starSize,
  });

  /// Membuat path bintang bersudut [points] di sekitar [center]
  Path _buildStarPath(Offset center, double outerRadius, double innerRadius, int points) {
    final path = Path();
    final double angleStep = pi / points;
    for (int i = 0; i < points * 2; i++) {
      final double angle = i * angleStep - pi / 2;
      final double r = i.isEven ? outerRadius : innerRadius;
      final double x = center.dx + r * cos(angle);
      final double y = center.dy + r * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double outerR = starSize / 2;
    final double innerR = outerR * 0.42;
    final double spacing = starSize + 4;
    final double centerY = size.height / 2;

    final Paint emptyPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < starCount; i++) {
      final double centerX = i * spacing + outerR + 2;
      final Offset center = Offset(centerX, centerY);
      final Path starPath = _buildStarPath(center, outerR, innerR, 5);

      // 1. Gambar bintang kosong (abu-abu) sebagai latar
      canvas.drawPath(starPath, emptyPaint);
      canvas.drawPath(starPath, borderPaint);

      // 2. Hitung seberapa penuh bintang ini
      final double fill = (rating - i).clamp(0.0, 1.0);
      if (fill <= 0) continue;

      // 3. Gambar bintang terisi (gradient kuning → oranye)
      // Gunakan clipRect agar hanya terisi sebagian jika fill < 1.0
      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(centerX - outerR, 0, outerR * 2 * fill, size.height),
      );

      // Gradient kuning → oranye berdasarkan rating keseluruhan
      final Color fillColor = rating >= 4.0
          ? const Color(0xFFFFB300)   // Emas terang
          : rating >= 2.5
              ? const Color(0xFFFFC107)  // Kuning amber
              : const Color(0xFFFF8F00); // Oranye gelap

      final Paint filledPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            fillColor.withValues(alpha: 0.95),
            fillColor,
          ],
          center: Alignment.topCenter,
          radius: 0.8,
        ).createShader(
          Rect.fromCircle(center: center, radius: outerR),
        )
        ..style = PaintingStyle.fill;

      canvas.drawPath(starPath, filledPaint);

      // Highlight kecil di atas bintang untuk efek glossy
      final Paint highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      final Path topStarClip = _buildStarPath(
        Offset(center.dx, center.dy + outerR * 0.15),
        outerR * 0.5,
        innerR * 0.5,
        5,
      );
      canvas.drawPath(topStarClip, highlightPaint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _StarPainter oldDelegate) {
    return oldDelegate.rating != rating;
  }
}
