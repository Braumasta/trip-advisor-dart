import 'package:flutter/material.dart';
import 'api_client.dart';
import 'models.dart';

class EditCountryPage extends StatefulWidget {
  const EditCountryPage({required this.userId, required this.country, super.key});

  final int userId;
  final Country country;

  @override
  State<EditCountryPage> createState() => _EditCountryPageState();
}

class _EditCountryPageState extends State<EditCountryPage> {
  final _api = ApiClient();
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl =
      TextEditingController(text: widget.country.name);
  late final TextEditingController _descCtrl =
      TextEditingController(text: widget.country.description);
  late final TextEditingController _accentCtrl =
      TextEditingController(text: widget.country.accentHex);
  final _etiquetteCtrl = TextEditingController();
  final _travelCtrl = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  final _flagUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _flagUrlController.text = widget.country.flagAsset;
    _loadTips();
  }

  Future<void> _loadTips() async {
    setState(() => _loading = true);
    try {
      final tips = await _api.fetchTips(widget.country.id);
      _etiquetteCtrl.text =
          tips.where((t) => t.kind == 'etiquette').map((t) => t.tip).join('\n');
      _travelCtrl.text =
          tips.where((t) => t.kind == 'travel').map((t) => t.tip).join('\n');
    } catch (_) {
      // ignore tip load errors; keep empty
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final etiquetteTips = _etiquetteCtrl.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final travelTips = _travelCtrl.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final accent = _accentCtrl.text.trim().replaceAll('#', '').toUpperCase();
      final flag = _flagUrlController.text.trim();
      await _api.updateCountry(
        userId: widget.userId,
        countryId: widget.country.id,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        accentHex: accent,
        flagAsset: flag,
        etiquetteTips: etiquetteTips,
        travelTips: travelTips,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Country updated')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _accentCtrl.dispose();
    _etiquetteCtrl.dispose();
    _travelCtrl.dispose();
    _flagUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit country')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.flag_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descCtrl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _accentCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Accent hex',
                        prefixIcon: Icon(Icons.color_lens_outlined),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _flagUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Flag image URL',
                        hintText: 'http://...',
                        prefixIcon: Icon(Icons.link),
                      ),
                      validator: (v) =>
                          v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _etiquetteCtrl,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Etiquette tips (one per line)',
                        prefixIcon: Icon(Icons.list_alt_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _travelCtrl,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Travel tips (one per line)',
                        prefixIcon: Icon(Icons.travel_explore_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
