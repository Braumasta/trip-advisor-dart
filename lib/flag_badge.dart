import 'package:flutter/material.dart';

class FlagBadge extends StatelessWidget {
  const FlagBadge({required this.fallbackColor, this.assetPath, super.key});

  final Color fallbackColor;
  final String? assetPath;

  String? _normalize(String? path) {
    if (path == null) return null;
    final trimmed = path.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http')) return trimmed;
    // Treat any non-http path as relative to your uploads host
    final cleaned = trimmed.replaceFirst(RegExp(r'^/+'), '');
    return 'http://mobcrud.atwebpages.com/api/uploads/$cleaned';
  }

  @override
  Widget build(BuildContext context) {
    final normalized = _normalize(assetPath);
    if (normalized == null) return _PlaceholderFlag(color: fallbackColor);
    if (normalized.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          normalized,
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
