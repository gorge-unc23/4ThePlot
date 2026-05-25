import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/user.dart';
import 'package:fourtheplot/pages/landing/landing_page.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';
import 'package:fourtheplot/pages/settings/settings_shared.dart';

class SettingsPrivacySafetyPage extends StatefulWidget {
  const SettingsPrivacySafetyPage({super.key});

  @override
  State<SettingsPrivacySafetyPage> createState() =>
      _SettingsPrivacySafetyPageState();
}

class _SettingsPrivacySafetyPageState
    extends State<SettingsPrivacySafetyPage> {
  bool _isDeleting = false;

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isDeleting = true);
    final result =
        await DatabaseHelper.instance.deleteUser(MainWrapper.loggedInUser.id);
    if (!mounted) return;
    setState(() => _isDeleting = false);
    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    await DatabaseHelper.instance.clearSession();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LandingPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = MainWrapper.loggedInUser;
    return SettingsShell(
      title: 'Privacy & Safety',
      subtitle: 'Account status and deletion',
      child: Column(
        children: [
          SettingsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _info('Role', userRoleToString(user.role)),
                _info('Status', userStatusToString(user.status)),
                _info('Account ID', user.id.toString()),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(
                color: Colors.red.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text(
              'Delete account',
              style: TextStyle(color: Colors.redAccent),
            ),
            subtitle: const Text('Permanently remove your account'),
            onTap: _isDeleting ? null : _deleteAccount,
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.white54)),
          ),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
