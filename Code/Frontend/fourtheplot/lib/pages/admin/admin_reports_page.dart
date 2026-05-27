import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/admin/admin_models.dart';
import 'package:fourtheplot/pages/admin/admin_widgets.dart';
import 'package:intl/intl.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  List<AdminSafetyReport> _reports = const [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _statusFilter;
  String? _severityFilter;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await DatabaseHelper.instance.getAdminReports(
      status: _statusFilter,
      severity: _severityFilter,
    );
    if (!mounted) return;
    if (!result.success || result.data is! List<AdminSafetyReport>) {
      setState(() {
        _reports = const [];
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }
    setState(() {
      _reports = result.data as List<AdminSafetyReport>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1021),
        foregroundColor: Colors.white,
        title: const Text('Safety Reports'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadReports,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            AdminFilterBar(
              values: const ['open', 'resolved'],
              selected: _statusFilter,
              onChanged: (value) {
                setState(() => _statusFilter = value);
                _loadReports();
              },
            ),
            const SizedBox(height: 10),
            AdminFilterBar(
              values: const ['low', 'medium', 'high'],
              selected: _severityFilter,
              onChanged: (value) {
                setState(() => _severityFilter = value);
                _loadReports();
              },
            ),
            const SizedBox(height: 16),
            _buildContent(),
          ],
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
        message: 'Could not load reports: $_errorMessage',
        onRetry: _loadReports,
      );
    }
    if (_reports.isEmpty) {
      return const AdminEmptyState(message: 'No safety reports found.');
    }
    return Column(children: _reports.map(_buildReportCard).toList());
  }

  Widget _buildReportCard(AdminSafetyReport report) {
    final target = report.reportedEvent?.title ??
        report.reportedComment?.text ??
        report.reportedUser?.displayName ??
        'Report #${report.id}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AdminSectionCard(
        child: InkWell(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AdminReportDetailsPage(reportId: report.id),
              ),
            );
            _loadReports();
          },
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AdminStatusChip(label: report.status),
                        const SizedBox(width: 8),
                        AdminStatusChip(label: report.severity),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      target,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      report.reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
                    ),
                    if (report.createdAt != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        DateFormat('MMM d, h:mm a').format(report.createdAt!),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminReportDetailsPage extends StatefulWidget {
  final int reportId;

  const AdminReportDetailsPage({super.key, required this.reportId});

  @override
  State<AdminReportDetailsPage> createState() => _AdminReportDetailsPageState();
}

class _AdminReportDetailsPageState extends State<AdminReportDetailsPage> {
  AdminSafetyReport? _report;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await DatabaseHelper.instance.getAdminReport(widget.reportId);
    if (!mounted) return;
    if (!result.success || result.data is! AdminSafetyReport) {
      setState(() {
        _report = null;
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }
    setState(() {
      _report = result.data as AdminSafetyReport;
      _isLoading = false;
    });
  }

  Future<void> _applyAction(String action) async {
    final reason = await showAdminReasonDialog(
      context,
      title: 'Apply ${_actionLabel(action)}',
    );
    if (reason == null || _report == null) return;
    setState(() => _isSubmitting = true);
    final result = await DatabaseHelper.instance.applyAdminModerationAction(
      _report!.id,
      action: action,
      reason: reason,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (!result.success) {
      _showSnackBar('Action failed: ${result.message}');
      return;
    }
    _showSnackBar('Moderation action applied.');
    _loadReport();
  }

  Future<void> _updateStatus(String status) async {
    final reason = await showAdminReasonDialog(context, title: 'Update status');
    if (reason == null || _report == null) return;
    setState(() => _isSubmitting = true);
    final result = await DatabaseHelper.instance.updateAdminReportStatus(
      _report!.id,
      status: status,
      reason: reason,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (!result.success) {
      _showSnackBar('Status update failed: ${result.message}');
      return;
    }
    _loadReport();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1021),
        foregroundColor: Colors.white,
        title: const Text('Report Details'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AdminErrorState(
            message: 'Could not load report: $_errorMessage',
            onRetry: _loadReport,
          ),
        ],
      );
    }
    final report = _report!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AdminStatusChip(label: report.status),
                  const SizedBox(width: 8),
                  AdminStatusChip(label: report.severity),
                ],
              ),
              const SizedBox(height: 14),
              _info('Reason', report.reason),
              _info('Reporter', report.reporter?.displayName ?? 'Unknown'),
              _info('Reported user', report.reportedUser?.displayName ?? 'None'),
              _info('Reported event', report.reportedEvent?.title ?? 'None'),
              _info('Reported comment', report.reportedComment?.text ?? 'None'),
              _info('Evidence complete', report.evidenceComplete ? 'Yes' : 'No'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AdminSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Moderation',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _buildModerationButtons(report),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...report.evidence.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AdminSectionCard(
              child: _info(
                item.evidenceType,
                item.contentText ?? item.contentUrl ?? 'No evidence content',
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildModerationButtons(AdminSafetyReport report) {
    final buttons = <Widget>[];

    if (report.reportedUserId != null) {
      buttons.add(_actionButton('Warn user', 'warn_user'));
    }
    if (report.reportedEventId != null) {
      buttons.add(_actionButton('Delete event', 'delete_event'));
    }
    if (report.reportedCommentId != null) {
      buttons.add(_actionButton('Delete comment', 'delete_comment'));
    }

    buttons.add(_actionButton('Dismiss', 'dismiss_report'));
    buttons.add(_statusButton('Resolve', 'resolved'));
    return buttons;
  }

  Widget _actionButton(String label, String action) {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : () => _applyAction(action),
      child: Text(label),
    );
  }

  String _actionLabel(String action) {
    switch (action) {
      case 'warn_user':
        return 'warn user';
      case 'delete_event':
        return 'delete event';
      case 'delete_comment':
        return 'delete comment';
      case 'dismiss_report':
        return 'dismiss report';
      default:
        return action.replaceAll('_', ' ');
    }
  }

  Widget _statusButton(String label, String status) {
    return OutlinedButton(
      onPressed: _isSubmitting ? null : () => _updateStatus(status),
      child: Text(label),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
