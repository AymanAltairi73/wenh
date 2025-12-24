import 'package:flutter/material.dart';

class HeroImage extends StatelessWidget {
  final String imagePath;
  final double height;
  final String? heroTag;
  final Widget? fallback;

  const HeroImage({
    super.key,
    required this.imagePath,
    this.height = 80,
    this.heroTag,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = Image.asset(
      imagePath,
      height: height,
      errorBuilder: (_, __, ___) => fallback ?? _DefaultFallback(height: height),
    );

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

class _DefaultFallback extends StatelessWidget {
  final double height;

  const _DefaultFallback({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(height / 4),
      ),
      child: Icon(
        Icons.handyman,
        size: height * 0.6,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
