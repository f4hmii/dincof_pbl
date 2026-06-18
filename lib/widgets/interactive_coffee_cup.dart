import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class InteractiveCoffeeCup extends StatefulWidget {
  final String coffeeName;
  final double volume; // 0.1 to 1.0
  final double sweetness; // 0.0 to 1.0
  final ValueChanged<double> onVolumeChanged;
  final ValueChanged<double> onSweetnessChanged;

  const InteractiveCoffeeCup({
    super.key,
    required this.coffeeName,
    required this.volume,
    required this.sweetness,
    required this.onVolumeChanged,
    required this.onSweetnessChanged,
  });

  @override
  State<InteractiveCoffeeCup> createState() => _InteractiveCoffeeCupState();
}

class _InteractiveCoffeeCupState extends State<InteractiveCoffeeCup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _dragDirection; // 'vertical' or 'horizontal'

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth > 0 ? constraints.maxWidth : 300.0;
        double height = 280.0; // Tetapkan tinggi ideal untuk visualisasi cangkir

        return GestureDetector(
          onPanStart: (details) {
            _dragDirection = null;
          },
          onPanUpdate: (details) {
            if (_dragDirection == null) {
              if (details.delta.dy.abs() > details.delta.dx.abs()) {
                _dragDirection = 'vertical';
              } else {
                _dragDirection = 'horizontal';
              }
            }

            if (_dragDirection == 'vertical') {
              // Naikkan / turunkan cairan kopi
              // Y=0 di atas, Y=height di bawah.
              // Rentang aktif cairan antara height*0.35 sampai height*0.78
              double topLimit = height * 0.35;
              double bottomLimit = height * 0.78;
              double currentY = details.localPosition.dy.clamp(topLimit, bottomLimit);
              
              // Hitung persentase pengisian (1.0 = penuh/atas, 0.1 = kosong/bawah)
              double newVolume = 1.0 - ((currentY - topLimit) / (bottomLimit - topLimit));
              widget.onVolumeChanged(newVolume.clamp(0.1, 1.0));
            } else if (_dragDirection == 'horizontal') {
              // Geser untuk mengatur kemanisan (0.0 ke 1.0)
              double minX = width * 0.25;
              double maxX = width * 0.75;
              double currentX = details.localPosition.dx.clamp(minX, maxX);
              double newSweetness = (currentX - minX) / (maxX - minX);
              widget.onSweetnessChanged(newSweetness.clamp(0.0, 1.0));
            }
          },
          child: Column(
            children: [
              CustomPaint(
                size: Size(width, height),
                painter: CoffeeCupPainter(
                  coffeeName: widget.coffeeName,
                  volume: widget.volume,
                  sweetness: widget.sweetness,
                  animationValue: _animationController.value,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Manis: ${(widget.sweetness * 100).round()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '💡 Tips: Geser Vertikal untuk Ukuran | Geser Horizontal untuk Kemanisan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CoffeeCupPainter extends CustomPainter {
  final String coffeeName;
  final double volume;
  final double sweetness;
  final double animationValue;

  CoffeeCupPainter({
    required this.coffeeName,
    required this.volume,
    required this.sweetness,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double w = size.width;
    double h = size.height;

    // Koordinat Cangkir Kopi
    double cupTopY = h * 0.35;
    double cupBottomY = h * 0.80;
    double cupLeftTopX = w * 0.28;
    double cupRightTopX = w * 0.72;
    double cupLeftBottomX = w * 0.34;
    double cupRightBottomX = w * 0.66;
    double glassThickness = 8.0;

    // Ambil warna kopi berdasarkan nama kopi
    Color coffeeColor = _getCoffeeColor();
    Color foamColor = _getFoamColor();

    // 1. Gambar Uap Panas (Steam) jika volume > 0.2
    if (volume > 0.2) {
      _paintSteam(canvas, size, cupTopY);
    }

    // 2. Gambar Gagang Cangkir (Cup Handle) - di sebelah kanan cangkir
    Paint handlePaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;
    
    Path handlePath = Path();
    handlePath.moveTo(cupRightTopX - 10, cupTopY + 20);
    handlePath.cubicTo(
      w * 0.88, cupTopY + 20,
      w * 0.88, cupBottomY - 20,
      cupRightBottomX + 5, cupBottomY - 30,
    );
    canvas.drawPath(handlePath, handlePaint);

    // 3. Gambar Cairan Kopi (di dalam cangkir - dipotong/clip dengan bentuk dalam cangkir)
    Path innerCupPath = Path();
    innerCupPath.moveTo(cupLeftTopX + glassThickness, cupTopY);
    innerCupPath.lineTo(cupLeftBottomX + glassThickness - 2, cupBottomY - glassThickness);
    // Bagian dasar cangkir melengkung halus
    innerCupPath.quadraticBezierTo(
      w * 0.5, cupBottomY - glassThickness + 5,
      cupRightBottomX - glassThickness + 2, cupBottomY - glassThickness,
    );
    innerCupPath.lineTo(cupRightTopX - glassThickness, cupTopY);
    innerCupPath.close();

    canvas.save();
    canvas.clipPath(innerCupPath);

    // Hitung posisi ketinggian cairan kopi
    double activeMinY = cupBottomY - glassThickness;
    double activeMaxY = cupTopY + 15; // Jarak aman dari bibir cangkir
    double liquidY = activeMinY - (volume * (activeMinY - activeMaxY));

    // Gambar Cairan Kopi Utama
    Paint liquidPaint = Paint()
      ..color = coffeeColor
      ..style = PaintingStyle.fill;

    Path liquidPath = Path();
    liquidPath.moveTo(cupLeftBottomX, h); // Mulai dari bawah cangkir
    liquidPath.lineTo(cupLeftTopX, liquidY);

    // Gelombang Cairan Kopi (Wave)
    double waveAmplitude = 4.0;
    double waveFrequency = 0.05;
    double phase = animationValue * 2 * pi;

    for (double x = cupLeftTopX; x <= cupRightTopX; x += 2) {
      double relativeX = x - cupLeftTopX;
      double y = liquidY + waveAmplitude * sin(relativeX * waveFrequency + phase);
      liquidPath.lineTo(x, y);
    }

    liquidPath.lineTo(cupRightTopX, h);
    liquidPath.close();
    canvas.drawPath(liquidPath, liquidPaint);

    // Gambar Lapisan Krim / Foam di atas cangkir kopi
    Paint foamPaint = Paint()
      ..color = foamColor
      ..style = PaintingStyle.fill;

    Path foamPath = Path();
    // Gambar garis gelombang foam tipis sedikit menjorok ke bawah
    foamPath.moveTo(cupLeftTopX, liquidY - 2);
    for (double x = cupLeftTopX; x <= cupRightTopX; x += 2) {
      double relativeX = x - cupLeftTopX;
      double waveY = liquidY + waveAmplitude * sin(relativeX * waveFrequency + phase);
      foamPath.lineTo(x, waveY);
    }
    // Gambar gelombang kedua sedikit di bawahnya
    for (double x = cupRightTopX; x >= cupLeftTopX; x -= 2) {
      double relativeX = x - cupLeftTopX;
      double waveY = liquidY + 6 + waveAmplitude * sin(relativeX * waveFrequency + phase + 0.5);
      foamPath.lineTo(x, waveY);
    }
    foamPath.close();
    canvas.drawPath(foamPath, foamPaint);

    canvas.restore(); // Akhiri clipping dalam cangkir

    // 4. Gambar Bodi Kaca Cangkir (Glass Outer Layer)
    Paint glassPaint = Paint()
      ..color = Colors.grey.withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = glassThickness
      ..strokeCap = StrokeCap.round;

    Path outerCupPath = Path();
    outerCupPath.moveTo(cupLeftTopX, cupTopY);
    outerCupPath.lineTo(cupLeftBottomX, cupBottomY);
    // Dasar cangkir melengkung halus
    outerCupPath.quadraticBezierTo(w * 0.5, cupBottomY + 6, cupRightBottomX, cupBottomY);
    outerCupPath.lineTo(cupRightTopX, cupTopY);
    canvas.drawPath(outerCupPath, glassPaint);

    // 5. Gambar Piring Tatakan Cangkir (Saucer) di bawah cangkir
    Paint saucerPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    Path saucerPath = Path();
    saucerPath.moveTo(cupLeftBottomX - 35, cupBottomY + 12);
    saucerPath.quadraticBezierTo(
      w * 0.5, cupBottomY + 25,
      cupRightBottomX + 35, cupBottomY + 12,
    );
    canvas.drawPath(saucerPath, saucerPaint);

    // 6. Gambar Garis Level Pengukuran (S, M, L) di sisi kiri cangkir kopi
    Paint linePaint = Paint()
      ..color = Colors.grey.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Label Teks Ukuran
    _drawTextLabel(canvas, "L", Offset(cupLeftTopX - 22, activeMaxY), Colors.grey);
    _drawTextLabel(canvas, "M", Offset(cupLeftTopX - 22, (activeMaxY + activeMinY) / 2), Colors.grey);
    _drawTextLabel(canvas, "S", Offset(cupLeftTopX - 22, activeMinY - 20), Colors.grey);

    // Garis penunjuk batas
    canvas.drawLine(Offset(cupLeftTopX - 10, activeMaxY), Offset(cupLeftTopX - 4, activeMaxY), linePaint);
    canvas.drawLine(Offset(cupLeftTopX - 10, (activeMaxY + activeMinY) / 2), Offset(cupLeftTopX - 4, (activeMaxY + activeMinY) / 2), linePaint);
    canvas.drawLine(Offset(cupLeftTopX - 10, activeMinY - 20), Offset(cupLeftTopX - 4, activeMinY - 20), linePaint);
  }

  void _paintSteam(Canvas canvas, Size size, double cupTopY) {
    double w = size.width;
    Paint steamPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15 + 0.05 * sin(animationValue * 2 * pi))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    double steamHeight = 35.0;
    double timePhase = animationValue * 2 * pi;

    for (int i = 0; i < 3; i++) {
      double startX = w * (0.42 + i * 0.08);
      double startY = cupTopY - 5;
      
      // Animasi naik turun dan meliuk menggunakan kurva Bezier
      double xOffset1 = 8.0 * sin(timePhase + i);
      double xOffset2 = -6.0 * sin(timePhase + i * 1.5);
      
      Path steamPath = Path();
      steamPath.moveTo(startX, startY);
      steamPath.cubicTo(
        startX + xOffset1, startY - steamHeight * 0.3,
        startX + xOffset2, startY - steamHeight * 0.7,
        startX + (xOffset1 + xOffset2) / 2, startY - steamHeight,
      );
      
      canvas.drawPath(steamPath, steamPaint);
    }
  }

  void _drawTextLabel(Canvas canvas, String text, Offset offset, Color color) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2));
  }

  Color _getCoffeeColor() {
    switch (coffeeName.toLowerCase()) {
      case 'cappuccino':
        return const Color(0xFF6F4E37);
      case 'macchiato':
        return const Color(0xFF5A3825);
      case 'latte':
        return const Color(0xFF8B5A2B);
      case 'espresso':
        return const Color(0xFF3E2723);
      default:
        return const Color(0xFF5C4033);
    }
  }

  Color _getFoamColor() {
    switch (coffeeName.toLowerCase()) {
      case 'cappuccino':
        return const Color(0xFFF5E6D3);
      case 'macchiato':
        return const Color(0xFFEEDC82);
      case 'latte':
        return const Color(0xFFFFFDD0);
      case 'espresso':
        return const Color(0xFF8B7355).withOpacity(0.4); // crema tipis
      default:
        return const Color(0xFFF3E5AB);
    }
  }

  @override
  bool shouldRepaint(covariant CoffeeCupPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.volume != volume ||
        oldDelegate.sweetness != sweetness;
  }
}
