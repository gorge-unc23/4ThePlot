import 'package:flutter/material.dart';
import 'package:fourtheplot/app_theme_controller.dart';
import 'package:fourtheplot/pages/settings/settings_shared.dart';

class SettingsAppearanceLanguagePage extends StatefulWidget {
  const SettingsAppearanceLanguagePage({super.key});

  @override
  State<SettingsAppearanceLanguagePage> createState() =>
      _SettingsAppearanceLanguagePageState();
}

class _SettingsAppearanceLanguagePageState
    extends State<SettingsAppearanceLanguagePage> {
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final themeController = AppThemeController.instance;
    return SettingsShell(
      title: 'Appearance & Language',
      subtitle: 'Theme and language preferences',
      child: AnimatedBuilder(
        animation: themeController,
        builder: (context, _) {
          return SettingsCard(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: themeController.selectedMode,
                  decoration: const InputDecoration(labelText: 'Theme'),
                  items: const [
                    DropdownMenuItem(value: 'system', child: Text('System')),
                    DropdownMenuItem(value: 'light', child: Text('Light')),
                    DropdownMenuItem(value: 'dark', child: Text('Dark')),
                  ],
                  onChanged: (value) {
                    themeController.setThemeMode(value ?? 'system');
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _language,
                  decoration: const InputDecoration(labelText: 'Language'),
                  items: const [
                    DropdownMenuItem(value: 'English', child: Text('English')),
                    DropdownMenuItem(value: 'Albanian', child: Text('Albanian')),
                  ],
                  onChanged: (value) =>
                      setState(() => _language = value ?? 'English'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
