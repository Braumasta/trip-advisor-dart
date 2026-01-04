import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'api_client.dart';
import 'demo_auth_state.dart';
import 'gradient_background.dart';
import 'models.dart';

class DeleteEditCountryPage extends StatefulWidget {
  const DeleteEditCountryPage({super.key});

  @override
  State<DeleteEditCountryPage> createState() => _DeleteEditCountryPageState();
}

class _DeleteEditCountryPageState extends State<DeleteEditCountryPage> {
  final _api = ApiClient();
  final _picker = ImagePicker();
  bool _loading = true;
  String? _error;
  List<Country> _countries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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
    final userId = DemoAuthState.instance.userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in first')),
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
    final userId = DemoAuthState.instance.userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in first')),
      );
      return;
    }
    List<Tip> tips = [];
    try {
      tips = await _api.fetchTips(country.id);
    } catch (_) {}
    final etiquetteText =
        tips.where((t) => t.kind == 'etiquette').map((t) => t.tip).join('\n');
    final travelText =
        tips.where((t) => t.kind == 'travel').map((t) => t.tip).join('\n');
    final nameCtrl = TextEditingController(text: country.name);
    final descCtrl = TextEditingController(text: country.description);
    final accentCtrl = TextEditingController(text: country.accentHex);
    final etiquetteCtrl = TextEditingController(text: etiquetteText);
    final travelCtrl = TextEditingController(text: travelText);
    XFile? flagFile;
    bool saving = false;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descCtrl,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: accentCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Accent hex',
                    prefixIcon: Icon(Icons.color_lens_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: etiquetteCtrl,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Etiquette tips (one per line)',
                    prefixIcon: Icon(Icons.list_alt_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: travelCtrl,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Travel tips (one per line)',
                    prefixIcon: Icon(Icons.travel_explore_outlined),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final file = await _picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 800,
                      );
                      if (file != null) {
                        flagFile = file;
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.upload_file_outlined),
                    label: Text(flagFile == null
                        ? 'Upload new flag (optional)'
                        : 'Selected: ${flagFile!.name}'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: saving
                        ? null
                        : () async {
                            saving = true;
                            try {
                              String? flagUrl;
                              if (flagFile != null) {
                                final bytes = await flagFile!.readAsBytes();
                                flagUrl = await _api.uploadImage(
                                  target: 'flag',
                                  bytes: bytes,
                                  filename: flagFile!.name,
                                );
                              }
                              final etiquetteTips = etiquetteCtrl.text
                                  .split('\n')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();
                              final travelTips = travelCtrl.text
                                  .split('\n')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();
                              await _api.updateCountry(
                                userId: userId,
                                countryId: country.id,
                                name: nameCtrl.text.trim(),
                                description: descCtrl.text.trim(),
                                accentHex: accentCtrl.text.trim(),
                                flagAsset: flagUrl,
                                etiquetteTips: etiquetteTips,
                                travelTips: travelTips,
                              );
                              if (!mounted) return;
                              Navigator.of(ctx).pop();
                              await _load();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Country updated')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed: $e')),
                              );
                            } finally {
                              saving = false;
                            }
                          },
                    child: saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    nameCtrl.dispose();
    descCtrl.dispose();
    accentCtrl.dispose();
    etiquetteCtrl.dispose();
    travelCtrl.dispose();
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
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: c.flagAsset.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.network(
                                      c.flagAsset,
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
