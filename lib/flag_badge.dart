import 'package:flutter/material.dart';

class FlagBadge extends StatelessWidget {
  const FlagBadge({required this.fallbackColor, this.assetPath, super.key});

  final Color fallbackColor;
  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          assetPath!,
          width: 32,
          height: 24,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _PlaceholderFlag(color: fallbackColor),
        ),
      );
    }
    return _PlaceholderFlag(color: fallbackColor);
  }
}

class _PlaceholderFlag extends StatelessWidget {
  const _PlaceholderFlag({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 24,
        color: color.withValues(alpha: 0.12),
        alignment: Alignment.center,
        child: Icon(Icons.flag, size: 14, color: color),
      ),
    );
  }
}
