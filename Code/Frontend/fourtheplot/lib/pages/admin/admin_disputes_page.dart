import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/admin/admin_models.dart';
import 'package:fourtheplot/pages/admin/admin_widgets.dart';
import 'package:intl/intl.dart';

class AdminDisputesPage extends StatefulWidget {
  const AdminDisputesPage({super.key});

  @override
  State<AdminDisputesPage> createState() => _AdminDisputesPageState();
}

class _AdminDisputesPageState extends State<AdminDisputesPage> {
  List<AdminDisputeCase> _disputes = const [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadDisputes();
  }

  Future<void> _loadDisputes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await DatabaseHelper.instance.getAdminDisputes(status: _statusFilter);
    if (!mounted) return;
    if (!result.success || result.data is! List<AdminDisputeCase>) {
      setState(() {
        _disputes = const [];
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }
    setState(() {
      _disputes = result.data as List<AdminDisputeCase>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1021),
        foregroundColor: Colors.white,
        title: const Text('Disputes'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDisputes,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            AdminFilterBar(
              values: const [
                'open',
                'needs_evidence',
                'escalated',
                'resolved',
                'pending_communication',
              ],
              selected: _statusFilter,
              onChanged: (value) {
                setState(() => _statusFilter = value);
                _loadDisputes();
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
        message: 'Could not load disputes: $_errorMessage',
        onRetry: _loadDisputes,
      );
    }
    if (_disputes.isEmpty) {
      return const AdminEmptyState(message: 'No disputes found.');
    }
    return Column(children: _disputes.map(_buildDisputeCard).toList());
  }

  Widget _buildDisputeCard(AdminDisputeCase dispute) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AdminSectionCard(
        child: InkWell(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AdminDisputeDetailsPage(disputeId: dispute.id),
              ),
            );
            _loadDisputes();
          },
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AdminStatusChip(label: dispute.status),
                    const SizedBox(height: 8),
                    Text(
                      dispute.event?.title ?? 'Dispute #${dispute.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      dispute.reason ?? 'No reason provided',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
                    ),
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

class AdminDisputeDetailsPage extends StatefulWidget {
  final int disputeId;

  const AdminDisputeDetailsPage({super.key, required this.disputeId});

  @override
  State<AdminDisputeDetailsPage> createState() => _AdminDisputeDetailsPageState();
}

class _AdminDisputeDetailsPageState extends State<AdminDisputeDetailsPage> {
  AdminDisputeCase? _dispute;
  AdminChatLogsResponse? _chatLogs;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDispute();
  }

  Future<void> _loadDispute() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await DatabaseHelper.instance.getAdminDispute(widget.disputeId);
    if (!mounted) return;
    if (!result.success || result.data is! AdminDisputeCase) {
      setState(() {
        _dispute = null;
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }
    setState(() {
      _dispute = result.data as AdminDisputeCase;
      _isLoading = false;
    });
  }

  Future<void> _loadChatLogs() async {
    final result = await DatabaseHelper.instance.getAdminDisputeChatLogs(widget.disputeId);
    if (!mounted) return;
    if (!result.success || result.data is! AdminChatLogsResponse) {
      _showSnackBar('Could not load chat logs: ${result.message}');
      return;
    }
    setState(() => _chatLogs = result.data as AdminChatLogsResponse);
  }

  Future<void> _resolve(String status) async {
    final reason = await showAdminReasonDialog(context, title: 'Submit decision');
    if (reason == null) return;
    setState(() => _isSubmitting = true);
    final result = await DatabaseHelper.instance.resolveAdminDispute(
      widget.disputeId,
      decision: status == 'resolved' ? 'resolved' : status,
      reason: reason,
      status: status,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (!result.success) {
      _showSnackBar('Decision failed: ${result.message}');
      return;
    }
    _loadDispute();
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
        title: const Text('Dispute Details'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AdminErrorState(
            message: 'Could not load dispute: $_errorMessage',
            onRetry: _loadDispute,
          ),
        ],
      );
    }
    final dispute = _dispute!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminStatusChip(label: dispute.status),
              const SizedBox(height: 12),
              _info('Event', dispute.event?.title ?? 'Unknown'),
              _info('Host', dispute.host?.displayName ?? 'Unknown'),
              _info('Goer', dispute.goer?.displayName ?? 'Unknown'),
              _info('Reason', dispute.reason ?? 'Not provided'),
              if (dispute.createdAt != null)
                _info('Created', DateFormat('MMM d, h:mm a').format(dispute.createdAt!)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AdminSectionCard(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton(
                onPressed: _isSubmitting ? null : () => _resolve('resolved'),
                child: const Text('Resolve'),
              ),
              OutlinedButton(
                onPressed: _isSubmitting ? null : () => _resolve('needs_evidence'),
                child: const Text('Need evidence'),
              ),
              OutlinedButton(
                onPressed: _isSubmitting ? null : () => _resolve('escalated'),
                child: const Text('Escalate'),
              ),
              OutlinedButton(onPressed: _loadChatLogs, child: const Text('Chat logs')),
            ],
          ),
        ),
        if (_chatLogs != null) ...[
          const SizedBox(height: 16),
          AdminSectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminStatusChip(
                  label: _chatLogs!.complete ? 'complete' : 'incomplete',
                ),
                const SizedBox(height: 10),
                ..._chatLogs!.evidence.map(
                  (item) => _info(
                    item.evidenceType,
                    item.contentText ?? item.contentUrl ?? 'No content',
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
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
