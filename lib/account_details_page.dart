import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  late final TextEditingController _profilePicController =
      TextEditingController(text: DemoAuthState.instance.profilePicUrl ?? '');
  Uint8List? _avatarBytes = DemoAuthState.instance.avatarBytes;
  bool _picking = false;
  bool _saving = false;
  final _api = ApiClient();

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _profilePicController.dispose();
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
          dob: _dobController.text.trim(),
          profilePicUrl: _profilePicController.text.trim().isNotEmpty
              ? _profilePicController.text.trim()
              : null,
        )
        .then((user) {
      DemoAuthState.instance.updateProfile(
        first: user.firstName,
        last: user.lastName,
        dob: user.dob ?? _dobController.text.trim(),
        profilePicUrl: user.profilePicUrl ?? _profilePicController.text.trim(),
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

  Future<void> _pickImage() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final XFile? file =
          await _picker.pickImage(source: ImageSource.gallery, maxWidth: 600);
      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _avatarBytes = bytes;
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to pick image right now')),
      );
    } finally {
      if (mounted) {
        setState(() => _picking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          backgroundImage: _profilePicController.text.trim().isNotEmpty
                              ? NetworkImage(_profilePicController.text.trim())
                              : (_avatarBytes != null ? MemoryImage(_avatarBytes!) : null),
                          child: _avatarBytes == null &&
                                  _profilePicController.text.trim().isEmpty
                              ? const Icon(
                                  Icons.person_outline,
                                  size: 42,
                                  color: Colors.black87,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: _pickImage,
                          icon: _picking
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.upload_file_outlined),
                          label: const Text('Upload image'),
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
                                hintText: 'YYYY-MM-DD',
                                prefixIcon: Icon(Icons.calendar_today_outlined),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _profilePicController,
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
