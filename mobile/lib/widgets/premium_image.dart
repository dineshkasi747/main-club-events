import 'package:flutter/material.dart';

class PremiumImage extends StatelessWidget {
  final String url;
  final String category;
  final double? height;
  final double? width;
  final BoxFit fit;
  final double borderRadius;
  final BorderRadius? customBorderRadius;

  const PremiumImage({
    super.key,
    required this.url,
    required this.category,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.customBorderRadius,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color startColor;
    Color endColor;

    final lowerCat = category.toLowerCase();
    if (lowerCat.contains('tech')) {
      icon = Icons.code;
      startColor = const Color(0xFF06B6D4);
      endColor = const Color(0xFF0891B2);
    } else if (lowerCat.contains('cult')) {
      icon = Icons.music_note;
      startColor = const Color(0xFF8B5CF6);
      endColor = const Color(0xFF7C3AED);
    } else if (lowerCat.contains('sport')) {
      icon = Icons.sports_cricket;
      startColor = const Color(0xFF10B981);
      endColor = const Color(0xFF059669);
    } else {
      icon = Icons.school;
      startColor = const Color(0xFF6366F1);
      endColor = const Color(0xFF4F46E5);
    }

    final placeholder = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: customBorderRadius ?? BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          color: Colors.white,
          size: (height != null && height! < 70) ? 22 : 36,
        ),
      ),
    );

    if (url.isEmpty) {
      return placeholder;
    }

    // Local asset image
    if (url.startsWith('assets/')) {
      final isLogo = url.toLowerCase().contains('logo');
      final isIeeeCs = url.toLowerCase().contains('ieee_cs');
      
      Widget imageWidget = Image.asset(
        url,
        height: height,
        width: width,
        fit: isLogo ? BoxFit.contain : fit,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );

      if (isLogo) {
        return ClipRRect(
          borderRadius: customBorderRadius ?? BorderRadius.circular(borderRadius),
          child: Container(
            height: height,
            width: width,
            color: isIeeeCs ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            padding: const EdgeInsets.all(12.0),
            child: imageWidget,
          ),
        );
      }

      return ClipRRect(
        borderRadius: customBorderRadius ?? BorderRadius.circular(borderRadius),
        child: imageWidget,
      );
    }

    // Network image
    if (url.startsWith('http')) {
      final isLogo = url.toLowerCase().contains('logo');
      final isIeeeCs = url.toLowerCase().contains('ieee_cs');

      Widget imageWidget = Image.network(
        url,
        height: height,
        width: width,
        fit: isLogo ? BoxFit.contain : fit,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );

      if (isLogo) {
        return ClipRRect(
          borderRadius: customBorderRadius ?? BorderRadius.circular(borderRadius),
          child: Container(
            height: height,
            width: width,
            color: isIeeeCs ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            padding: const EdgeInsets.all(12.0),
            child: imageWidget,
          ),
        );
      }

      return ClipRRect(
        borderRadius: customBorderRadius ?? BorderRadius.circular(borderRadius),
        child: imageWidget,
      );
    }

    return placeholder;
  }
}
