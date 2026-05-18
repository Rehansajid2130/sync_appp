import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class SocialCircleButton extends StatelessWidget {
  final String? letter;
  final IconData? icon;
  final Color color;
  final VoidCallback onPressed;

  const SocialCircleButton({
    super.key,
    this.letter,
    this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.textMutedLight.withOpacity(0.3)),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, color: color, size: 24)
              : Text(
                  letter ?? '',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
        ),
      ),
    );
  }
}
