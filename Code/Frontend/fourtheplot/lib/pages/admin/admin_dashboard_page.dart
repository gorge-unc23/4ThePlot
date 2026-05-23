import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/admin/admin_models.dart';
import 'package:fourtheplot/pages/admin/admin_audit_logs_page.dart';
import 'package:fourtheplot/pages/admin/admin_disputes_page.dart';
import 'package:fourtheplot/pages/admin/admin_events_page.dart';
import 'package:fourtheplot/pages/admin/admin_host_verification_page.dart';
import 'package:fourtheplot/pages/admin/admin_metrics_page.dart';
import 'package:fourtheplot/pages/admin/admin_notifications_page.dart';
import 'package:fourtheplot/pages/admin/admin_reports_page.dart';
import 'package:fourtheplot/pages/admin/admin_widgets.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  AdminMetricsOverview? _overview;
  bool _isLoadingMetrics = true;
  String? _metricsError;

  static final _tiles = [
    _AdminTileData(
      title: 'Safety Reports',
      description: 'Review queued reports and prepare moderation decisions.',
      icon: Icons.report_outlined,
      color: const Color(0xFFFF6B6B),
      builder: () => const AdminReportsPage(),
    ),
    _AdminTileData(
      title: 'Host Verification',
      description: 'Verify submitted host documents and approval requests.',
      icon: Icons.verified_user_outlined,
      color: const Color(0xFF22D3EE),
      builder: () => const AdminHostVerificationPage(),
    ),
    _AdminTileData(
      title: 'Disputes',
      description: 'Review evidence, chat logs, and refund outcomes.',
      icon: Icons.gavel_outlined,
      color: const Color(0xFFFACC15),
      builder: () => const AdminDisputesPage(),
    ),
    _AdminTileData(
      title: 'Global Notifications',
      description: 'Publish platform-wide announcements and banners.',
      icon: Icons.campaign_outlined,
      color: const Color(0xFFC084FC),
      builder: () => const AdminNotificationsPage(),
    ),
    _AdminTileData(
      title: 'Growth KPIs',
      description: 'Monitor DAU, new events, and platform growth signals.',
      icon: Icons.insights_outlined,
      color: const Color(0xFF34D399),
      builder: () => const AdminMetricsPage(),
    ),
    _AdminTileData(
      title: 'Audit Logs',
      description: 'Review admin actions and moderation reasons.',
      icon: Icons.history,
      color: const Color(0xFFFB923C),
      builder: () => const AdminAuditLogsPage(),
    ),
    _AdminTileData(
      title: 'Event Moderation',
      description: 'Inspect events and remove events or comments.',
      icon: Icons.event_busy_outlined,
      color: const Color(0xFF6EA8FF),
      builder: () => const AdminEventsPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() {
      _isLoadingMetrics = true;
      _metricsError = null;
    });
    final now = DateTime.now();
    final result = await DatabaseHelper.instance.getAdminMetricsOverview(
      startDate: now.subtract(Duration(days: now.weekday - 1)),
      endDate: now,
    );
    if (!mounted) return;
    if (!result.success || result.data is! AdminMetricsOverview) {
      setState(() {
        _overview = null;
        _isLoadingMetrics = false;
        _metricsError = result.message;
      });
      return;
    }
    setState(() {
      _overview = result.data as AdminMetricsOverview;
      _isLoadingMetrics = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadMetrics,
          child: ListView(
            padding: const EdgeInsets.all(10),
            children: [
              const SizedBox(height: 6),
              const Text(
                'Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Moderation and platform operations',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 18),
              _buildMetrics(),
              const SizedBox(height: 18),
              ..._tiles.map((tile) => _buildTile(context, tile)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetrics() {
    if (_isLoadingMetrics) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 28),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_metricsError != null || _overview == null) {
      return AdminErrorState(
        message: 'Could not load metrics: $_metricsError',
        onRetry: _loadMetrics,
      );
    }
    final overview = _overview!;
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.65,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _metric('Pending reports', overview.pendingReports),
        _metric('Host requests', overview.pendingHostVerifications),
        _metric('New users\nthis week', overview.newUsers),
        _metric('New events\nthis week', overview.newEvents),
      ],
    );
  }

  Widget _metric(String label, int value) {
    return AdminSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.toString(),
            style: const TextStyle(
              color: Color(0xFF6EA8FF),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.65))),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, _AdminTileData tile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => tile.builder()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: tile.color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(tile.icon, color: tile.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tile.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tile.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminTileData {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget Function() builder;

  const _AdminTileData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.builder,
  });
}
