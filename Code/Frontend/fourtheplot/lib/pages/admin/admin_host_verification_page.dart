import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/user.dart';

class AdminHostVerificationPage extends StatefulWidget {
  const AdminHostVerificationPage({super.key});

  @override
  State<AdminHostVerificationPage> createState() => _AdminHostVerificationPageState();
}

class _AdminHostVerificationPageState extends State<AdminHostVerificationPage> {
  List<User> _users = const [];
  bool _isLoading = true;
  int? _updatingUserId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await DatabaseHelper.instance.getNotTrustedUsers();
    if (!mounted) {
      return;
    }

    if (!result.success || result.data is! List<User>) {
      setState(() {
        _users = const [];
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }

    final users = List<User>.from(result.data as List<User>)
      ..sort((a, b) => a.displayName.compareTo(b.displayName));
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _openUser(User user) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminHostVerificationDetailsPage(
          user: user,
          onApprove: () => _approveUser(user),
        ),
      ),
    );
  }

  Future<bool> _approveUser(User user) async {
    if (_updatingUserId != null) {
      return false;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve host?'),
        content: Text('Mark ${user.displayName} as a trusted host.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return false;
    }

    setState(() {
      _updatingUserId = user.id;
    });
    final result = await DatabaseHelper.instance.markUserAsTrusted(user);
    if (!mounted) {
      return false;
    }
    setState(() {
      _updatingUserId = null;
    });

    if (!result.success) {
      _showSnackBar('Could not approve host: ${result.message}');
      return false;
    }

    setState(() {
      _users = _users.where((item) => item.id != user.id).toList();
    });
    _showSnackBar('Host approved.');
    return true;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: RefreshIndicator(
            onRefresh: _loadUsers,
            child: ListView(
              children: [
                const SizedBox(height: 6),
                const Text(
                  'Host Verification',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Review hosts waiting for trusted status',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 20),
                _buildContent(),
              ],
            ),
          ),
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Text(
              'Could not load host requests: $_errorMessage',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _loadUsers, child: const Text('Try again')),
          ],
        ),
      );
    }

    if (_users.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1B1F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Text(
          'There are no hosts waiting for verification.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
        ),
      );
    }

    return Column(children: _users.map(_buildUserCard).toList());
  }

  Widget _buildUserCard(User user) {
    final businessName = user.businessProfile?.name.trim();
    final isUpdating = _updatingUserId == user.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openUser(user),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _buildAvatar(user),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName?.isNotEmpty == true
                          ? businessName!
                          : user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Status: ${userStatusToString(user.status)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: isUpdating ? null : () => _approveUser(user),
                tooltip: 'Approve host',
                icon: isUpdating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.verified, color: Color(0xFF22D3EE)),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(User user) {
    final logoUrl = user.businessProfile?.logoUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          logoUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(user),
        ),
      );
    }

    return _buildFallbackAvatar(user);
  }

  Widget _buildFallbackAvatar(User user) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFF22D3EE).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          _initial(user),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  String _initial(User user) {
    final source = user.businessProfile?.name.trim().isNotEmpty == true
        ? user.businessProfile!.name
        : user.displayName;
    return source.isNotEmpty ? source[0].toUpperCase() : '?';
  }
}

class AdminHostVerificationDetailsPage extends StatelessWidget {
  final User user;
  final Future<bool> Function() onApprove;

  const AdminHostVerificationDetailsPage({
    super.key,
    required this.user,
    required this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    final businessProfile = user.businessProfile;
    final credibility = user.hostCredibility;
    final businessName = businessProfile?.name.trim();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1021),
        foregroundColor: Colors.white,
        title: const Text('Host Details'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1B1F),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    businessName?.isNotEmpty == true
                        ? businessName!
                        : user.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('User', user.displayName),
                  _buildInfoRow('Phone', user.phone ?? 'Not provided'),
                  _buildInfoRow('Role', userRoleToString(user.role)),
                  _buildInfoRow('Status', userStatusToString(user.status)),
                  _buildInfoRow(
                    'Published',
                    businessProfile?.isPublished == true ? 'Yes' : 'No',
                  ),
                  _buildInfoRow('Website', businessProfile?.websiteUrl ?? 'Not provided'),
                  _buildInfoRow(
                    'Rating',
                    (credibility?.rating ?? 0).toStringAsFixed(1),
                  ),
                  _buildInfoRow(
                    'Reviews',
                    (credibility?.reviewCount ?? 0).toString(),
                  ),
                  _buildInfoRow(
                    'Trusted',
                    credibility?.trusted == true ? 'Yes' : 'No',
                  ),
                  if (businessProfile?.description?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Text(
                      businessProfile!.description!.trim(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        height: 1.45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final approved = await onApprove();
                if (approved && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.verified),
              label: const Text('Approve trusted host'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
