import 'package:flutter/material.dart';
import 'package:fourtheplot/pages/landing/landing_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tweak your experience',
                    style: TextStyle(fontSize: 14, color: Colors.white54),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    _buildSettingTile(
                      icon: Icons.person_outline,
                      title: 'Account',
                      subtitle: 'Profile, password, security',
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      subtitle: 'Event alerts and reminders',
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.lock_outline,
                      title: 'Privacy & Safety',
                      subtitle: 'Visibility and safety controls',
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.tune,
                      title: 'Event Preferences',
                      subtitle: 'Categories and filters',
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.location_on_outlined,
                      title: 'Location & Map',
                      subtitle: 'City defaults and map settings',
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.credit_card,
                      title: 'Tickets & Payments',
                      subtitle: 'Payment methods and tickets',
                    ),
                    _buildDivider(),
                    _buildSettingTile(
                      icon: Icons.help_outline,
                      title: 'Support & Feedback',
                      subtitle: 'Help center and contact',
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
  }) {
    return ListTile(
      // tileColor: const Color(0xFF1A1B1F),
      splashColor: const Color.fromARGB(6, 255, 255, 255),
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: () {},
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.white.withValues(alpha: 0.1),
      indent: 16,
      endIndent: 16,
    );
  }
}
