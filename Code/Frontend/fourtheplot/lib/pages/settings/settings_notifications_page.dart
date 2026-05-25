import 'package:flutter/material.dart';
import 'package:fourtheplot/pages/settings/settings_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsNotificationsPage extends StatefulWidget {
  const SettingsNotificationsPage({super.key});

  @override
  State<SettingsNotificationsPage> createState() =>
      _SettingsNotificationsPageState();
}

class _SettingsNotificationsPageState extends State<SettingsNotificationsPage> {
  bool _eventReminders = true;
  bool _registrationUpdates = true;
  bool _commentReplies = true;
  bool _globalAnnouncements = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _eventReminders =
          prefs.getBool('settings.notifications.eventReminders') ?? true;
      _registrationUpdates =
          prefs.getBool('settings.notifications.registrationUpdates') ?? true;
      _commentReplies =
          prefs.getBool('settings.notifications.commentReplies') ?? true;
      _globalAnnouncements =
          prefs.getBool('settings.notifications.globalAnnouncements') ?? true;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return SettingsShell(
      title: 'Notifications',
      subtitle: 'Event alerts and reminders',
      child: SettingsCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _switchTile(
              'Event reminders',
              _eventReminders,
              (value) {
                setState(() => _eventReminders = value);
                _save('settings.notifications.eventReminders', value);
              },
            ),
            settingsDivider(),
            _switchTile(
              'Registration updates',
              _registrationUpdates,
              (value) {
                setState(() => _registrationUpdates = value);
                _save('settings.notifications.registrationUpdates', value);
              },
            ),
            settingsDivider(),
            _switchTile(
              'Comment replies',
              _commentReplies,
              (value) {
                setState(() => _commentReplies = value);
                _save('settings.notifications.commentReplies', value);
              },
            ),
            settingsDivider(),
            _switchTile(
              'Admin announcements',
              _globalAnnouncements,
              (value) {
                setState(() => _globalAnnouncements = value);
                _save('settings.notifications.globalAnnouncements', value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      onChanged: onChanged,
    );
  }
}
