import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  final baseTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2D9CDB)),
    fontFamily: 'Roboto',
  );

  return baseTheme.copyWith(
    appBarTheme: baseTheme.appBarTheme.copyWith(
      backgroundColor: baseTheme.colorScheme.surface,
      foregroundColor: baseTheme.colorScheme.onSurface,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Colors.black87,
      contentPadding: EdgeInsets.symmetric(horizontal: 12),
    ),
  );
}
