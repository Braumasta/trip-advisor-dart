import 'package:flutter/material.dart';

import 'about_us_page.dart';
import 'account_details_page.dart';
import 'contact_page.dart';
import 'demo_auth_state.dart';
import 'gradient_background.dart';
import 'login_page.dart';
import 'security_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  void _openPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  void _confirmDelete(BuildContext context) {
    final controller = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final canDelete = controller.text.trim() == 'CONFIRM';
            return AlertDialog(
              title: const Text('Delete account'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Type CONFIRM to delete your account.',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Type CONFIRM',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: canDelete
                      ? () {
                          Navigator.of(dialogContext).pop();
                          DemoAuthState.instance.signOut();
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Account deleted'),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final auth = DemoAuthState.instance;

    return GradientBackground(
      child: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([auth.isSignedIn, auth.profileVersion]),
          builder: (context, _) {
            final signedIn = auth.isSignedIn.value;
            return ListView(
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
                          backgroundImage: auth.avatarBytes != null
                              ? MemoryImage(auth.avatarBytes!)
                              : null,
                          child: auth.avatarBytes == null
                              ? const Icon(
                                  Icons.person_outline,
                                  size: 42,
                                  color: Colors.black87,
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          signedIn
                              ? 'Signed in as ${auth.displayName.isNotEmpty ? auth.displayName : 'Traveler'}'
                              : 'You\'re not signed in',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          signedIn
                              ? (auth.lastEmail?.isNotEmpty == true
                                  ? auth.lastEmail!
                                  : '')
                              : 'Access your saved trips and personalize your experience.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        if (!signedIn)
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
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: auth.signOut,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Sign out'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                  const SizedBox(height: 16),
                if (signedIn) ...[
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person_outline,
                              color: Colors.black87),
                          title: const Text('Account details'),
                          subtitle: Text(auth.displayName),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openPage(context, const AccountDetailsPage()),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading:
                              const Icon(Icons.shield_outlined, color: Colors.black87),
                          title: const Text('Security'),
                          subtitle: const Text('Change your password'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _openPage(context, const SecurityPage()),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.delete_outline, color: Colors.red),
                          title: const Text(
                            'Delete account',
                            style: TextStyle(color: Colors.red),
                          ),
                          subtitle: const Text(
                            'Remove this account from the app',
                            style: TextStyle(color: Colors.red),
                          ),
                          trailing:
                              const Icon(Icons.chevron_right, color: Colors.red),
                          onTap: () => _confirmDelete(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
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
            );
          },
        ),
      ),
    );
  }
}
