import 'package:flutter/material.dart';

class CountryGuide {
  const CountryGuide({
    required this.name,
    required this.description,
    required this.accent,
    required this.etiquetteTips,
    required this.travelTips,
    this.flagAsset,
  });

  final String name;
  final String description;
  final Color accent;
  final List<String> etiquetteTips;
  final List<String> travelTips;
  final String? flagAsset;
}
