import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/admin/admin_models.dart';
import 'package:fourtheplot/pages/settings/settings_shared.dart';
import 'package:intl/intl.dart';

class SettingsGlobalNotificationsPage extends StatefulWidget {
  const SettingsGlobalNotificationsPage({super.key});

  @override
  State<SettingsGlobalNotificationsPage> createState() =>
      _SettingsGlobalNotificationsPageState();
}

class _SettingsGlobalNotificationsPageState
    extends State<SettingsGlobalNotificationsPage> {
  List<AdminGlobalNotification> _notifications = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await DatabaseHelper.instance.getGlobalNotifications();
    if (!mounted) return;
    if (!result.success || result.data is! List<AdminGlobalNotification>) {
      setState(() {
        _notifications = const [];
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }

    setState(() {
      _notifications = result.data as List<AdminGlobalNotification>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsShell(
      title: 'Announcements',
      subtitle: 'Platform updates from admins',
      child: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView(
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [_buildContent()],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorMessage != null) {
      return SettingsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Could not load announcements: $_errorMessage',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _loadNotifications,
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    if (_notifications.isEmpty) {
      return const SettingsCard(
        child: Text('No announcements right now.'),
      );
    }

    return Column(
      children: _notifications.map(_buildNotificationCard).toList(),
    );
  }

  Widget _buildNotificationCard(AdminGlobalNotification notification) {
    final date = notification.startsAt ??
        notification.createdAt ??
        notification.updatedAt;
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  notification.status.replaceAll('_', ' '),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (date != null)
                Text(
                  DateFormat('MMM d').format(date),
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notification.title,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            notification.message,
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.72),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
