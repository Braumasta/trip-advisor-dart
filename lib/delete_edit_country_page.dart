import 'package:flutter/material.dart';

import 'api_client.dart';
import 'demo_auth_state.dart';
import 'edit_country_page.dart';
import 'gradient_background.dart';
import 'models.dart';

class DeleteEditCountryPage extends StatefulWidget {
  const DeleteEditCountryPage({super.key});

  @override
  State<DeleteEditCountryPage> createState() => _DeleteEditCountryPageState();
}

class _DeleteEditCountryPageState extends State<DeleteEditCountryPage> {
  final _api = ApiClient();
  bool _loading = true;
  String? _error;
  List<Country> _countries = [];

  String? _flagUrl(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.startsWith('http')
        ? trimmed
        : 'http://mobcrud.atwebpages.com/api/uploads/${trimmed.replaceFirst(RegExp(r'^/+'), '')}';
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!DemoAuthState.instance.isAdmin) {
      setState(() {
        _loading = false;
        _error = 'Admin only';
      });
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final countries = await _api.fetchCountries();
      setState(() {
        _countries = countries;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deleteCountry(int countryId) async {
    final auth = DemoAuthState.instance;
    final userId = auth.userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in first')),
      );
      return;
    }
    if (!auth.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin only action')),
      );
      return;
    }
    try {
      await _api.deleteCountry(userId: userId, countryId: countryId);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Country deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  Future<void> _editCountry(Country country) async {
    final auth = DemoAuthState.instance;
    final currentUserId = auth.userId;
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in first')),
      );
      return;
    }
    if (!auth.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin only action')),
      );
      return;
    }
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditCountryPage(userId: currentUserId, country: country),
      ),
    );
    if (ok == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit/Delete countries')),
      body: GradientBackground(
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Failed to load countries'),
                            const SizedBox(height: 8),
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _load,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                      itemCount: _countries.length,
                      itemBuilder: (context, index) {
                        final c = _countries[index];
                        final flagUrl = _flagUrl(c.flagAsset);
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: flagUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      flagUrl,
                                      width: 48,
                                      height: 32,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.flag_outlined),
                                    ),
                                  )
                                : const Icon(Icons.flag_outlined),
                            title: Text(c.name),
                            subtitle: Text(
                              c.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editCountry(c),
                                ),
                                IconButton(
                                  icon:
                                      const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteCountry(c.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}
