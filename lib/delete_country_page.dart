import 'package:flutter/material.dart';

import 'api_client.dart';
import 'gradient_background.dart';

class DeleteCountryPage extends StatefulWidget {
  const DeleteCountryPage({required this.userId, super.key});

  final int userId;

  @override
  State<DeleteCountryPage> createState() => _DeleteCountryPageState();
}

class _DeleteCountryPageState extends State<DeleteCountryPage> {
  final _formKey = GlobalKey<FormState>();
  final _countryIdController = TextEditingController();
  final _api = ApiClient();
  bool _saving = false;

  @override
  void dispose() {
    _countryIdController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final id = int.tryParse(_countryIdController.text.trim()) ?? 0;
    try {
      await _api.deleteCountry(userId: widget.userId, countryId: id);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Country deleted')),
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
      appBar: AppBar(title: const Text('Delete country')),
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
                          controller: _countryIdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Country ID',
                            prefixIcon: Icon(Icons.delete_outline),
                          ),
                          validator: (v) {
                            final id = int.tryParse(v ?? '');
                            if (id == null || id <= 0) return 'Enter a valid ID';
                            return null;
                          },
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
                                : const Text('Delete'),
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
