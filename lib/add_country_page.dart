import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'api_client.dart';
import 'demo_auth_state.dart';
import 'gradient_background.dart';

class AddCountryPage extends StatefulWidget {
  const AddCountryPage({super.key});

  @override
  State<AddCountryPage> createState() => _AddCountryPageState();
}

class _AddCountryPageState extends State<AddCountryPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _accentController = TextEditingController(text: '2196F3');
  final _etiquetteController = TextEditingController();
  final _travelController = TextEditingController();
  final _api = ApiClient();
  bool _saving = false;
  XFile? _flagFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _accentController.dispose();
    _etiquetteController.dispose();
    _travelController.dispose();
    super.dispose();
  }

  Future<void> _pickFlag() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (file != null) {
      setState(() {
        _flagFile = file;
      });
    }
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_flagFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a flag image')),
      );
      return;
    }
    setState(() => _saving = true);
    final userId = DemoAuthState.instance.userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in first')),
      );
      setState(() => _saving = false);
      return;
    }
    final etiquetteTips = _etiquetteController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final travelTips = _travelController.text
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    try {
      final flagBytes = await _flagFile!.readAsBytes();
      final flagUrl = await _api.uploadImage(
        target: 'flag',
        bytes: flagBytes,
        filename: _flagFile!.name,
      );
      await _api.addCountry(
        userId: userId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        flagAsset: flagUrl,
        accentHex: _accentController.text.trim().replaceAll('#', ''),
        etiquetteTips: etiquetteTips,
        travelTips: travelTips,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Country added')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add country')),
      body: GradientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Country name',
                            prefixIcon: Icon(Icons.flag_outlined),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          minLines: 2,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _pickFlag,
                            icon: const Icon(Icons.upload_file_outlined),
                            label: Text(_flagFile == null
                                ? 'Upload flag image'
                                : 'Flag selected: ${_flagFile!.name}'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _accentController,
                          decoration: const InputDecoration(
                            labelText: 'Accent hex (e.g., 2196F3)',
                            prefixIcon: Icon(Icons.color_lens_outlined),
                          ),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _etiquetteController,
                          minLines: 3,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'Etiquette tips (one per line)',
                            prefixIcon: Icon(Icons.list_alt_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _travelController,
                          minLines: 3,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'Travel tips (one per line)',
                            prefixIcon: Icon(Icons.travel_explore_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Add country'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
