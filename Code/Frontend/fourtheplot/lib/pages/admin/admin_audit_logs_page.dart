import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/admin/admin_models.dart';
import 'package:fourtheplot/pages/admin/admin_widgets.dart';
import 'package:intl/intl.dart';

class AdminAuditLogsPage extends StatefulWidget {
  const AdminAuditLogsPage({super.key});

  @override
  State<AdminAuditLogsPage> createState() => _AdminAuditLogsPageState();
}

class _AdminAuditLogsPageState extends State<AdminAuditLogsPage> {
  List<AdminAuditLog> _logs = const [];
  bool _isLoading = true;
  String? _errorMessage;
  int _page = 1;
  int _pageSize = 20;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await DatabaseHelper.instance.getAdminAuditLogs(
      page: _page,
      pageSize: _pageSize,
    );
    if (!mounted) return;
    if (!result.success || result.data is! AdminAuditLogPage) {
      setState(() {
        _logs = const [];
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }

    final auditPage = result.data as AdminAuditLogPage;
    setState(() {
      _logs = auditPage.items;
      _page = auditPage.page == 0 ? _page : auditPage.page;
      _pageSize = auditPage.pageSize == 0 ? _pageSize : auditPage.pageSize;
      _total = auditPage.total;
      _isLoading = false;
    });
  }

  Future<void> _goToPage(int page) async {
    if (page < 1 || page == _page) return;
    setState(() => _page = page);
    await _loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1021),
        foregroundColor: Colors.white,
        title: const Text('Audit Logs'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadLogs,
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
        message: 'Could not load audit logs: $_errorMessage',
        onRetry: _loadLogs,
      );
    }
    if (_logs.isEmpty) {
      return const AdminEmptyState(message: 'No audit logs found.');
    }

    final hasNext = _page * _pageSize < _total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Page $_page · $_total total',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ),
        ..._logs.map(_buildLogCard),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _page > 1 ? () => _goToPage(_page - 1) : null,
                child: const Text('Previous'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: hasNext ? () => _goToPage(_page + 1) : null,
                child: const Text('Next'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogCard(AdminAuditLog log) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AdminSectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AdminStatusChip(label: log.action),
                const SizedBox(width: 8),
                AdminStatusChip(label: log.method),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${log.model} #${log.modelId}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${log.route} · ${log.actorRole} #${log.actorUserId}',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
            if (log.ipAddress?.isNotEmpty == true) ...[
              const SizedBox(height: 5),
              Text(
                log.ipAddress!,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
              ),
            ],
            if (log.oldValues.isNotEmpty || log.newValues.isNotEmpty) ...[
              const SizedBox(height: 10),
              _buildValuesPreview(log),
            ],
            if (log.createdAt != null) ...[
              const SizedBox(height: 5),
              Text(
                DateFormat('MMM d, h:mm a').format(log.createdAt!),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildValuesPreview(AdminAuditLog log) {
    final keys = <String>{
      ...log.oldValues.keys,
      ...log.newValues.keys,
    }.toList();

    if (keys.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Changes',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...keys.map((key) {
            final oldValue = _formatValue(log.oldValues[key]);
            final newValue = _formatValue(log.newValues[key]);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '$key: $oldValue -> $newValue',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 12,
                ),
              ),
            );
          }),
          if (log.oldValues.length > keys.length || log.newValues.length > keys.length)
            Text(
              'More fields changed',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) {
      return 'null';
    }
    final text = value.toString();
    return text.length > 42 ? '${text.substring(0, 42)}...' : text;
  }
}
