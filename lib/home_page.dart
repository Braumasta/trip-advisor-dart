import 'package:flutter/material.dart';

import 'account_page.dart';
import 'country_data.dart';
import 'country_guide.dart';
import 'etiquette_card.dart';
import 'favorites_page.dart';
import 'gradient_background.dart';

class EtiquetteHomePage extends StatefulWidget {
  const EtiquetteHomePage({super.key});

  @override
  State<EtiquetteHomePage> createState() => _EtiquetteHomePageState();
}

class _EtiquetteHomePageState extends State<EtiquetteHomePage> {
  int _selectedIndex = 0;
  final Set<String> _favoriteCountryNames = {};
  String _searchQuery = '';
  String? _expandedCountryName;

  List<CountryGuide> get _favoriteCountries => countryGuides
      .where((country) => _favoriteCountryNames.contains(country.name))
      .toList();

  List<CountryGuide> get _visibleCountries {
    if (_searchQuery.trim().isEmpty) return countryGuides;
    final query = _searchQuery.toLowerCase();
    return countryGuides
        .where((country) => country.name.toLowerCase().contains(query))
        .toList();
  }

  void _toggleFavorite(CountryGuide country) {
    setState(() {
      if (_favoriteCountryNames.contains(country.name)) {
        _favoriteCountryNames.remove(country.name);
        if (_expandedCountryName == country.name) {
          _expandedCountryName = null;
        }
      } else {
        _favoriteCountryNames.add(country.name);
      }
    });
  }

  void _onExpansionChange(CountryGuide country, bool isExpanded) {
    setState(() {
      _expandedCountryName = isExpanded ? country.name : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Trip Advisor'
              : _selectedIndex == 1
              ? 'Favorites'
              : 'Account',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _HomeSection(
            favorites: _favoriteCountryNames,
            countries: _visibleCountries,
            searchQuery: _searchQuery,
            expandedCountryName: _expandedCountryName,
            onToggleFavorite: _toggleFavorite,
            onSearchChanged: (value) => setState(() {
              _searchQuery = value.trim();
              _expandedCountryName = null;
            }),
            onExpansionChanged: _onExpansionChange,
          ),
          FavoritesPage(
            favorites: _favoriteCountries,
            onToggleFavorite: _toggleFavorite,
            expandedCountryName: _expandedCountryName,
            onExpansionChanged: _onExpansionChange,
          ),
          const AccountPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.favorites,
    required this.countries,
    required this.searchQuery,
    required this.expandedCountryName,
    required this.onToggleFavorite,
    required this.onSearchChanged,
    required this.onExpansionChanged,
  });

  final Set<String> favorites;
  final List<CountryGuide> countries;
  final String? expandedCountryName;
  final String searchQuery;
  final void Function(CountryGuide country) onToggleFavorite;
  final ValueChanged<String> onSearchChanged;
  final void Function(CountryGuide country, bool isExpanded) onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _SearchBar(query: searchQuery, onChanged: onSearchChanged),
            const SizedBox(height: 12),
            if (countries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    'No countries match your search.',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              )
            else
              ...countries.map(
                (country) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: EtiquetteCard(
                    country: country,
                    isFavorite: favorites.contains(country.name),
                    isExpanded: expandedCountryName == country.name,
                    onFavoriteToggle: () => onToggleFavorite(country),
                    onExpansionChanged: (expanded) =>
                        onExpansionChanged(country, expanded),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar({required this.query, required this.onChanged});

  final String query;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.query,
  );

  @override
  void didUpdateWidget(covariant _SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query && widget.query != _controller.text) {
      _controller
        ..text = widget.query
        ..selection = TextSelection.fromPosition(
          TextPosition(offset: widget.query.length),
        );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search country',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      textInputAction: TextInputAction.search,
    );
  }
}
