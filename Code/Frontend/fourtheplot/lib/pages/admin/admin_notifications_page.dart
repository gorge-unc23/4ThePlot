import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/admin/admin_models.dart';
import 'package:fourtheplot/pages/admin/admin_widgets.dart';
import 'package:intl/intl.dart';

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage> {
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
    final result = await DatabaseHelper.instance.getAdminNotifications();
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

  Future<void> _openForm([AdminGlobalNotification? notification]) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminNotificationFormPage(notification: notification),
      ),
    );
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1021),
        foregroundColor: Colors.white,
        title: const Text('Notifications'),
        actions: [
          IconButton(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add),
            tooltip: 'Create notification',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: ListView(
          padding: const EdgeInsets.all(10),
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
      return AdminErrorState(
        message: 'Could not load notifications: $_errorMessage',
        onRetry: _loadNotifications,
      );
    }
    if (_notifications.isEmpty) {
      return const AdminEmptyState(message: 'No notifications found.');
    }
    return Column(
      children: _notifications
          .map(
            (notification) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AdminSectionCard(
                child: InkWell(
                  onTap: () => _openForm(notification),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AdminStatusChip(label: notification.status),
                            const SizedBox(height: 8),
                            Text(
                              notification.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              notification.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class AdminNotificationFormPage extends StatefulWidget {
  final AdminGlobalNotification? notification;

  const AdminNotificationFormPage({super.key, this.notification});

  @override
  State<AdminNotificationFormPage> createState() => _AdminNotificationFormPageState();
}

class _AdminNotificationFormPageState extends State<AdminNotificationFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _messageController;
  late final TextEditingController _reasonController;
  String _status = 'draft';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final notification = widget.notification;
    _titleController = TextEditingController(text: notification?.title ?? '');
    _messageController = TextEditingController(text: notification?.message ?? '');
    _reasonController = TextEditingController();
    _status = notification?.status ?? 'draft';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    final payload = {
      'title': _titleController.text.trim(),
      'message': _messageController.text.trim(),
      'status': _status,
      'reason': _reasonController.text.trim(),
    };
    final notification = widget.notification;
    final result = notification == null
        ? await DatabaseHelper.instance.createAdminNotification(payload)
        : await DatabaseHelper.instance.updateAdminNotification(notification.id, payload);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = widget.notification?.createdAt;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1021),
        foregroundColor: Colors.white,
        title: Text(widget.notification == null ? 'Create Notification' : 'Edit Notification'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (createdAt != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  DateFormat('MMM d, h:mm a').format(createdAt),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
                ),
              ),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(labelText: 'Message'),
              minLines: 3,
              maxLines: 6,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Message is required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              items: const ['draft', 'scheduled', 'published']
                  .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                  .toList(),
              onChanged: (value) => setState(() => _status = value ?? 'draft'),
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _reasonController,
              decoration: const InputDecoration(labelText: 'Reason'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Reason is required' : null,
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child: Text(_isSubmitting ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}
