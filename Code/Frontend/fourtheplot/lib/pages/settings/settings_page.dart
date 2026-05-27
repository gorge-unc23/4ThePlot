import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/user.dart';
import 'package:fourtheplot/pages/landing/landing_page.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';
import 'package:fourtheplot/pages/settings/settings_sub_pages.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tweak your experience',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    _buildSettingTile(
                      icon: Icons.person_outline,
                      title: 'Profile',
                      subtitle: 'Name, email, phone, avatar',
                      page: const SettingsProfilePage(),
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.verified_user_outlined,
                      title: 'Verification',
                      subtitle: 'Trusted status and documents',
                      page: const SettingsVerificationPage(),
                    ),
                    if (MainWrapper.loggedInUser.role != UserRole.admin) ...[
                      _buildDivider(),
                      _buildSettingTile(
                        icon: Icons.campaign_outlined,
                        title: 'Announcements',
                        subtitle: 'Platform updates from admins',
                        page: const SettingsGlobalNotificationsPage(),
                      ),
                    ],
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.lock_outline,
                      title: 'Privacy & Safety',
                      subtitle: 'Account status and deletion',
                      page: const SettingsPrivacySafetyPage(),
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.palette_outlined,
                      title: 'Appearance', //& Language
                      subtitle: 'Theme preferences', //and language
                      page: const SettingsAppearanceLanguagePage(),
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.help_outline,
                      title: 'Support & Feedback',
                      subtitle: 'Help center and contact',
                      page: const SettingsSupportFeedbackPage(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                // tileColor: const Color(0xFF1A1B1F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18), // Set your radius here
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.4), width: 1), // Optional border
                ),
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
                trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
                onTap: () {
                  DatabaseHelper.instance.clearSession();
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => LandingPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return ListTile(
      // tileColor: const Color(0xFF1A1B1F),
      splashColor: const Color.fromARGB(6, 255, 255, 255),
      leading: Icon(icon, color: Theme.of(context).listTileTheme.iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.58),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
      indent: 16,
      endIndent: 16,
    );
  }
}
