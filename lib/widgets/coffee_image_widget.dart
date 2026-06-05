import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CoffeeImageWidget extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget fallbackWidget;

  const CoffeeImageWidget({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    required this.fallbackWidget,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedPath = imagePath.trim();

    if (trimmedPath.isEmpty) {
      return fallbackWidget;
    }

    // 1. Memuat gambar dari Network/URL
    if (trimmedPath.startsWith('http://') ||
        trimmedPath.startsWith('https://')) {
      return Image.network(
        trimmedPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return fallbackWidget;
        },
      );
    }

    // 2. Memuat gambar dari Assets Aplikasi
    if (trimmedPath.startsWith('assets/') || trimmedPath.startsWith('lib/')) {
      return Image.asset(
        trimmedPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return fallbackWidget;
        },
      );
    }

    // 3. Memuat gambar dari File Penyimpanan Lokal (tidak didukung di Web)
    if (!kIsWeb) {
      try {
        final file = File(trimmedPath);
        if (file.existsSync()) {
          return Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return fallbackWidget;
            },
          );
        }
      } catch (e) {
        // Jika terjadi error saat membaca file, gunakan fallback
        return fallbackWidget;
      }
    }

    // Default fallback jika tidak memenuhi kondisi di atas
    return fallbackWidget;
  }
}
