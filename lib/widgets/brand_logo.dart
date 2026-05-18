import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  const BrandLogo({
    super.key,
    this.size = 64.0,
    this.backgroundColor = Colors.white,
    this.iconColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.25), // Padding proportional to size
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.handshake_rounded, // Temporary placeholder for the HelperHive logo
        size: size,
        color: iconColor,
      ),
    );
  }
}
