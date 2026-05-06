import 'dart:ui';

import 'package:flutter/material.dart';

class Glassmorphism extends StatelessWidget {
  final double blur;
  final double opacity;
  final double radius;
  final Widget child;
  final Color color;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;

  const Glassmorphism({
    super.key,
    required this.child,
    required this.color,
    this.blur = 6,
    this.opacity = 0.2,
    this.radius = 30,
    this.padding,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur), // The blur effect
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color.withValues(alpha: opacity), // Semi-transparent color
            borderRadius: BorderRadius.circular(radius),
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }
}
