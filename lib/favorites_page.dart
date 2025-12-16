import 'package:flutter/material.dart';

import 'country_guide.dart';
import 'etiquette_card.dart';
import 'gradient_background.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({
    required this.favorites,
    required this.expandedCountryName,
    required this.onExpansionChanged,
    required this.onToggleFavorite,
    super.key,
  });

  final List<CountryGuide> favorites;
  final String? expandedCountryName;
  final void Function(CountryGuide country, bool isExpanded) onExpansionChanged;
  final void Function(CountryGuide country) onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    if (favorites.isEmpty) {
      return const GradientBackground(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No favorites yet.\nTap the heart on a country card to save it.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      );
    }

    return GradientBackground(
      child: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          itemCount: favorites.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final country = favorites[index];
            return EtiquetteCard(
              country: country,
              isFavorite: true,
              isExpanded: expandedCountryName == country.name,
              onFavoriteToggle: () => onToggleFavorite(country),
              onExpansionChanged: (expanded) =>
                  onExpansionChanged(country, expanded),
            );
          },
        ),
      ),
    );
  }
}
