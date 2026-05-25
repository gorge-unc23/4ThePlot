import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/host_credibility_summary.dart';
import 'package:fourtheplot/models/user.dart';
import 'package:fourtheplot/pages/admin/admin_widgets.dart';

class AdminHostsManagementPage extends StatefulWidget {
  const AdminHostsManagementPage({super.key});

  @override
  State<AdminHostsManagementPage> createState() =>
      _AdminHostsManagementPageState();
}

class _AdminHostsManagementPageState extends State<AdminHostsManagementPage> {
  List<User> _users = const [];
  bool _isLoading = true;
  int? _updatingUserId;
  String? _errorMessage;
  UserRole? _roleFilter;

  @override
  void initState() {
    super.initState();
    _loadHosts();
  }

  Future<void> _loadHosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await DatabaseHelper.instance.getNonAdminUsers();
    if (!mounted) return;
    if (!result.success || result.data is! List<User>) {
      setState(() {
        _users = const [];
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }

    final users = (result.data as List<User>).toList()
      ..sort(
        (a, b) => _profileName(a).toLowerCase().compareTo(_profileName(b).toLowerCase()),
      );

    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  List<User> get _filteredUsers {
    final filter = _roleFilter;
    if (filter == null) return _users;
    return _users.where((user) => user.role == filter).toList();
  }

  Future<void> _markUnverified(User host) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark host as unverified?'),
        content: Text(
          '${_profileName(host)} will lose trusted host status.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Mark unverified'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _updatingUserId = host.id);
    final result = await DatabaseHelper.instance.markUserAsUntrusted(host);
    if (!mounted) return;
    setState(() => _updatingUserId = null);
    if (!result.success) {
      _showMessage('Could not update host: ${result.message}');
      return;
    }

    final credibility = host.hostCredibility;
    final updated = host.copyWith(
      hostCredibility: HostCredibilitySummary(
        rating: credibility?.rating,
        reviewCount: credibility?.reviewCount,
        trusted: false,
      ),
    );
    setState(() {
      _users = _users.map((item) => item.id == host.id ? updated : item).toList();
    });
    _showMessage('Host marked as unverified.');
  }

  void _showProfile(User host) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF101423),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final trusted = host.hostCredibility?.trusted == true;
        final updating = _updatingUserId == host.id;
        return Padding(
          padding: const EdgeInsets.all(18),
          child: ListView(
            // mainAxisSize: MainAxisSize.min,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _HostAvatar(user: host, size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            _profileName(host),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          host.email,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AdminStatusChip(
                    label: trusted ? 'verified' : 'unverified',
                    color: trusted
                        ? const Color(0xFF34D399)
                        : const Color(0xFFFACC15),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _info('Display name', host.displayName),
              _info('Role', userRoleToString(host.role)),
              _info('Business name', host.businessProfile?.name ?? 'Not provided'),
              _info(
                'Description',
                host.businessProfile?.description ?? 'Not provided',
              ),
              _info('Website', host.businessProfile?.websiteUrl ?? 'Not provided'),
              _info(
                'Published',
                host.businessProfile?.isPublished == true ? 'Yes' : 'No',
              ),
              _info(
                'Rating',
                host.hostCredibility?.rating?.toStringAsFixed(1) ?? 'Not rated',
              ),
              _info(
                'Reviews',
                host.hostCredibility?.reviewCount?.toString() ?? '0',
              ),
              const SizedBox(height: 16),
              if (trusted)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: updating
                        ? null
                        : () {
                            Navigator.of(context).pop();
                            _markUnverified(host);
                          },
                    icon: updating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.verified_user_outlined),
                    label: const Text('Mark as unverified'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1021),
        foregroundColor: Colors.white,
        title: const Text('Hosts Management'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadHosts,
        child: ListView(
          padding: const EdgeInsets.all(10),
          children: [
            Text(
              'Non-admin users',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 12),
            _buildRoleFilter(),
            const SizedBox(height: 12),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _roleChip(null, 'Both'),
          _roleChip(UserRole.business, 'Business'),
          _roleChip(UserRole.goer, 'Goer'),
        ],
      ),
    );
  }

  Widget _roleChip(UserRole? role, String label) {
    final selected = _roleFilter == role;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        selected: selected,
        label: Text(label),
        onSelected: (_) => setState(() => _roleFilter = role),
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
        message: 'Could not load hosts: $_errorMessage',
        onRetry: _loadHosts,
      );
    }
    final users = _filteredUsers;
    if (users.isEmpty) {
      return const AdminEmptyState(message: 'No users found for this role.');
    }
    return Column(children: users.map(_buildHostCard).toList());
  }

  Widget _buildHostCard(User host) {
    final trusted = host.hostCredibility?.trusted == true;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AdminSectionCard(
        child: InkWell(
          onTap: () => _showProfile(host),
          child: Row(
            children: [
              _HostAvatar(user: host),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AdminStatusChip(
                          label: trusted ? 'verified' : 'unverified',
                          color: trusted
                              ? const Color(0xFF34D399)
                              : const Color(0xFFFACC15),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          userRoleToString(host.role),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          userStatusToString(host.status),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _profileName(host),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      host.businessProfile?.description ?? host.email,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (trusted)
                const Icon(
                  Icons.verified_user_outlined,
                  color: Colors.blue,
                )
              else
                const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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

class _HostAvatar extends StatelessWidget {
  final User user;
  final double size;

  const _HostAvatar({required this.user, this.size = 52});

  @override
  Widget build(BuildContext context) {
    final logoUrl = user.businessProfile?.logoUrl ?? user.avatarUrl;
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          logoUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    final source = _profileName(user);
    return Container(
      width: size,
      height: size,
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

String _profileName(User user) {
  final businessName = user.businessProfile?.name;
  if (businessName != null && businessName.isNotEmpty) return businessName;
  return user.displayName.isNotEmpty ? user.displayName : 'User #${user.id}';
}
