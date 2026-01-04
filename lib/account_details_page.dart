import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'api_client.dart';
import 'demo_auth_state.dart';
import 'gradient_background.dart';

class AccountDetailsPage extends StatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  State<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends State<AccountDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController =
      TextEditingController(text: DemoAuthState.instance.firstName);
  late final TextEditingController _lastNameController =
      TextEditingController(text: DemoAuthState.instance.lastName);
  late final TextEditingController _dobController =
      TextEditingController(text: DemoAuthState.instance.dob ?? '');
  Uint8List? _avatarBytes = DemoAuthState.instance.avatarBytes;
  late final TextEditingController _profileUrlController =
      TextEditingController(text: DemoAuthState.instance.profilePicUrl ?? '');
  bool _saving = false;
  final _api = ApiClient();

  String _normalizeDob(String input) {
    final cleaned = input.trim();
    if (cleaned.isEmpty) return '';
    final parts =
        cleaned.replaceAll('-', '/').replaceAll('.', '/').split('/');
    if (parts.length < 3) return cleaned;
    final day = parts[0].padLeft(2, '0');
    final month = parts[1].padLeft(2, '0');
    var year = parts[2];
    if (year.length == 2) {
      year = year.startsWith('9') ? '19$year' : '20$year';
    }
    if (year.length != 4) return cleaned;
    return '$year-$month-$day';
  }

  String? _normalizeProfileUrl(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.startsWith('http')
        ? trimmed
        : 'http://mobcrud.atwebpages.com/api/uploads/${trimmed.replaceFirst(RegExp(r'^/+'), '')}';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _profileUrlController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final auth = DemoAuthState.instance;
    final userId = auth.userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in first')),
      );
      setState(() => _saving = false);
      return;
    }
    _api
        .updateProfile(
          userId: userId,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          dob: _normalizeDob(_dobController.text),
          profilePicUrl: _normalizeProfileUrl(_profileUrlController.text),
        )
        .then((user) {
      DemoAuthState.instance.updateProfile(
        first: user.firstName,
        last: user.lastName,
        dob: user.dob ?? _normalizeDob(_dobController.text),
        profilePicUrl:
            _normalizeProfileUrl(_profileUrlController.text) ?? user.profilePicUrl,
        avatar: _avatarBytes,
      );
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $error')),
      );
    }).whenComplete(() {
      if (mounted) setState(() => _saving = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final networkUrl = _normalizeProfileUrl(_profileUrlController.text);
    return Scaffold(
      appBar: AppBar(title: const Text('Account details')),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 42,
                          backgroundColor: const Color(0xFFE0E0E0),
                          backgroundImage: _avatarBytes != null
                              ? MemoryImage(_avatarBytes!)
                              : (networkUrl != null ? NetworkImage(networkUrl) : null),
                          child: _avatarBytes == null && networkUrl == null
                              ? const Icon(
                                  Icons.person_outline,
                                  size: 42,
                                  color: Colors.black87,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Name',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'First name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last name',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _dobController,
                              decoration: const InputDecoration(
                                labelText: 'Date of birth',
                                hintText: 'DD/MM/YY',
                                prefixIcon: Icon(Icons.calendar_today_outlined),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _profileUrlController,
                              decoration: const InputDecoration(
                                labelText: 'Profile picture URL',
                                hintText: 'http://...',
                                prefixIcon: Icon(Icons.link),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _save,
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
                              : const Text('Save'),
                        ),
                      ),
                    ],
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
