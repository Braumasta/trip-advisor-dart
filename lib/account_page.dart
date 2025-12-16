import 'package:flutter/material.dart';

import 'about_us_page.dart';
import 'contact_page.dart';
import 'gradient_background.dart';
import 'login_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GradientBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.person_outline, size: 42),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You\'re not signed in',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Access your saved trips and personalize your experience.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _openPage(context, const LoginPage()),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Sign in'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.info_outline, color: Colors.black87),
                    title: const Text('About Us'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openPage(context, const AboutUsPage()),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.mail_outline, color: Colors.black87),
                    title: const Text('Contact'),
                    subtitle:
                        const Text('42130732@students.liu.edu.lb'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openPage(context, const ContactPage()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
