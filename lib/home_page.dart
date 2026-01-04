import 'package:flutter/material.dart';

import 'account_page.dart';
import 'api_client.dart';
import 'country_guide.dart';
import 'demo_auth_state.dart';
import 'etiquette_card.dart';
import 'favorites_page.dart';
import 'gradient_background.dart';
import 'models.dart';

class EtiquetteHomePage extends StatefulWidget {
  const EtiquetteHomePage({super.key});

  @override
  State<EtiquetteHomePage> createState() => _EtiquetteHomePageState();
}

class _EtiquetteHomePageState extends State<EtiquetteHomePage> {
  int _selectedIndex = 0;
  final Set<int> _favoriteCountryIds = {};
  final _api = ApiClient();
  bool _loading = true;
  String? _error;
  List<CountryGuide> _countries = [];
  String _searchQuery = '';
  String? _expandedCountryName;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  List<CountryGuide> get _favoriteCountries => _countries
      .where((country) => country.id != null && _favoriteCountryIds.contains(country.id))
      .toList();

  List<CountryGuide> get _visibleCountries {
    if (_searchQuery.trim().isEmpty) return _countries;
    final query = _searchQuery.toLowerCase();
    return _countries
        .where((country) => country.name.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final countries = await _api.fetchCountries();
      final guides = <CountryGuide>[];
      for (final country in countries) {
        final tips = await _api.fetchTips(country.id);
        final etiquette = <String>[];
        final travel = <String>[];
        for (final tip in tips) {
          if (tip.kind == 'etiquette') {
            etiquette.add(tip.tip);
          } else if (tip.kind == 'travel') {
            travel.add(tip.tip);
          }
        }
        guides.add(
          CountryGuide(
            id: country.id,
            name: country.name,
            description: country.description,
            accent: _hexToColor(country.accentHex),
            etiquetteTips: etiquette,
            travelTips: travel,
            flagAsset: country.flagAsset.isNotEmpty ? country.flagAsset : null,
          ),
        );
      }
      Set<int> favoriteIds = {};
      try {
        final favorites = await _api.fetchFavorites();
        favoriteIds = favorites.map((f) => f.id).toSet();
      } catch (_) {
        // ignore favorites load errors (likely unauthenticated)
      }
      if (!mounted) return;
      setState(() {
        _countries = guides;
        _favoriteCountryIds
          ..clear()
          ..addAll(favoriteIds);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _toggleFavorite(CountryGuide country) async {
    if (country.id == null) return;
    final auth = DemoAuthState.instance;
    if (!auth.isSignedIn.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to save favorites')),
      );
      return;
    }
    final isFav = _favoriteCountryIds.contains(country.id);
    setState(() {
      if (isFav) {
        _favoriteCountryIds.remove(country.id);
      } else {
        _favoriteCountryIds.add(country.id!);
      }
    });
    try {
      if (isFav) {
        await _api.removeFavorite(country.id!);
      } else {
        await _api.addFavorite(country.id!);
      }
    } catch (e) {
      setState(() {
        if (isFav) {
          _favoriteCountryIds.add(country.id!);
        } else {
          _favoriteCountryIds.remove(country.id);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update favorite: $e')),
        );
      }
    }
  }

  void _onExpansionChange(CountryGuide country, bool isExpanded) {
    setState(() {
      _expandedCountryName = isExpanded ? country.name : null;
    });
  }

  Color _hexToColor(String hex) {
    final cleaned = hex.replaceAll('#', '').padLeft(6, '0');
    return Color(int.parse('FF$cleaned', radix: 16));
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Failed to load data',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : IndexedStack(
                  index: _selectedIndex,
                  children: [
                    _HomeSection(
                      favorites: _favoriteCountryIds,
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

  final Set<int> favorites;
  final List<CountryGuide> countries;
  final String? expandedCountryName;
  final String searchQuery;
  final void Function(CountryGuide country) onToggleFavorite;
  final ValueChanged<String> onSearchChanged;
  final void Function(CountryGuide country, bool isExpanded) onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final listPadding = const EdgeInsets.fromLTRB(16, 16, 16, 24);

    if (countries.isEmpty) {
      return GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: listPadding,
            children: [
              _SearchBar(query: searchQuery, onChanged: onSearchChanged),
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    'No countries match your search.',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GradientBackground(
      child: SafeArea(
        child: ListView.separated(
          padding: listPadding,
          itemCount: countries.length + 1,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _SearchBar(query: searchQuery, onChanged: onSearchChanged);
            }
            final country = countries[index - 1];
            return EtiquetteCard(
              country: country,
              isFavorite: country.id != null && favorites.contains(country.id),
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
