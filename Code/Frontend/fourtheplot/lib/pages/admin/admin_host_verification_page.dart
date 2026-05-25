import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/admin/admin_models.dart';
import 'package:fourtheplot/models/user.dart';
import 'package:fourtheplot/pages/admin/admin_widgets.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminHostVerificationPage extends StatefulWidget {
  const AdminHostVerificationPage({super.key});

  @override
  State<AdminHostVerificationPage> createState() => _AdminHostVerificationPageState();
}

class _AdminHostVerificationPageState extends State<AdminHostVerificationPage> {
  List<AdminHostVerificationRequest> _requests = const [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await DatabaseHelper.instance.getAdminHostVerifications(
      status: _statusFilter,
    );
    if (!mounted) return;
    if (!result.success || result.data is! List<AdminHostVerificationRequest>) {
      setState(() {
        _requests = const [];
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }
    setState(() {
      _requests = result.data as List<AdminHostVerificationRequest>;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1021),
        foregroundColor: Colors.white,
        title: const Text('Host Verification'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadRequests,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            AdminFilterBar(
              values: const [
                'pending',
                'approved',
                'rejected',
              ],
              selected: _statusFilter,
              onChanged: (value) {
                setState(() => _statusFilter = value);
                _loadRequests();
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
        message: 'Could not load host verifications: $_errorMessage',
        onRetry: _loadRequests,
      );
    }
    if (_requests.isEmpty) {
      return const AdminEmptyState(message: 'No host verification requests found.');
    }
    return Column(children: _requests.map(_buildRequestCard).toList());
  }

  Widget _buildRequestCard(AdminHostVerificationRequest request) {
    final host = request.host;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AdminSectionCard(
        child: InkWell(
          onTap: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    AdminHostVerificationDetailsPage(requestId: request.id),
              ),
            );
            _loadRequests();
          },
          child: Row(
            children: [
              _Avatar(user: host),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AdminStatusChip(label: request.status),
                        const SizedBox(width: 8),
                        Text(
                          '${request.documents.length} docs',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      host?.businessProfile?.name.isNotEmpty == true
                          ? host!.businessProfile!.name
                          : host?.displayName ?? 'Host #${request.hostUserId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (request.submittedAt != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, h:mm a').format(request.submittedAt!),
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

class AdminHostVerificationDetailsPage extends StatefulWidget {
  final int requestId;

  const AdminHostVerificationDetailsPage({super.key, required this.requestId});

  @override
  State<AdminHostVerificationDetailsPage> createState() =>
      _AdminHostVerificationDetailsPageState();
}

class _AdminHostVerificationDetailsPageState
    extends State<AdminHostVerificationDetailsPage> {
  AdminHostVerificationRequest? _request;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRequest();
  }

  Future<void> _loadRequest() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final result = await DatabaseHelper.instance.getAdminHostVerification(widget.requestId);
    if (!mounted) return;
    if (!result.success || result.data is! AdminHostVerificationRequest) {
      setState(() {
        _request = null;
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }
    setState(() {
      _request = result.data as AdminHostVerificationRequest;
      _isLoading = false;
    });
  }

  Future<void> _review(String status) async {
    final reason = await showAdminReasonDialog(
      context,
      title: status.replaceAll('_', ' '),
    );
    if (reason == null || _request == null) return;
    setState(() => _isSubmitting = true);
    final result = await DatabaseHelper.instance.reviewAdminHostVerification(
      _request!.id,
      status: status,
      reason: reason,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (!result.success) {
      _showSnackBar('Review failed: ${result.message}');
      return;
    }
    if (result.data is AdminHostVerificationRequest) {
      setState(() => _request = result.data as AdminHostVerificationRequest);
    }
    _showSnackBar(
      status == 'approved'
          ? 'Host approved and marked as trusted.'
          : 'Host verification updated.',
    );
  }

  Future<void> _openDocument(AdminHostVerificationDocument document) async {
    final uri = Uri.tryParse(document.documentUrl);
    if (uri == null || !uri.hasScheme) {
      _showSnackBar('Invalid document URL.');
      return;
    }

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      _showSnackBar('Could not open document.');
    }
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
        title: const Text('Host Details'),
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
            message: 'Could not load request: $_errorMessage',
            onRetry: _loadRequest,
          ),
        ],
      );
    }
    final request = _request!;
    final host = request.host;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AdminSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminStatusChip(label: request.status),
              const SizedBox(height: 14),
              _info('Host', host?.displayName ?? 'Host #${request.hostUserId}'),
              _info('Email', host?.email ?? 'Unknown'),
              _info('Business', host?.businessProfile?.name ?? 'Not provided'),
              _info('Status', host != null ? userStatusToString(host.status) : 'Unknown'),
              _info(
                'Trusted',
                host?.hostCredibility?.trusted == true ? 'Verified' : 'Unverified',
              ),
              _info('Documents', request.documents.length.toString()),
              if (request.reviewReason?.isNotEmpty == true)
                _info('Review reason', request.reviewReason!),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (request.status != "approved" && request.status != "rejected") ...[
          AdminSectionCard(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: _isSubmitting ? null : () => _review('approved'),
                  child: const Text('Approve'),
                ),
                OutlinedButton(
                  onPressed: _isSubmitting ? null : () => _review('rejected'),
                  child: const Text('Reject'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        ...request.documents.map(
          (document) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AdminSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminStatusChip(label: document.status),
                  const SizedBox(height: 8),
                  _info('Type', document.documentType),
                  _info('URL', document.documentUrl),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () => _openDocument(document),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('View document'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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

class _Avatar extends StatelessWidget {
  final User? user;

  const _Avatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final logoUrl = user?.businessProfile?.logoUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          logoUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final source = user?.businessProfile?.name.isNotEmpty == true
        ? user!.businessProfile!.name
        : user?.displayName ?? '?';
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF22D3EE).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          source.isNotEmpty ? source[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
