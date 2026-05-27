import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/admin/admin_models.dart';
import 'package:fourtheplot/pages/admin/admin_widgets.dart';

class AdminMetricsPage extends StatefulWidget {
  const AdminMetricsPage({super.key});

  @override
  State<AdminMetricsPage> createState() => _AdminMetricsPageState();
}

class _AdminMetricsPageState extends State<AdminMetricsPage> {
  AdminMetricsOverview? _overview;
  List<AdminDailyMetrics> _daily = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final results = await Future.wait([
      DatabaseHelper.instance.getAdminMetricsOverview(),
      DatabaseHelper.instance.getAdminDailyMetrics(),
    ]);
    if (!mounted) return;
    if (!results[0].success || !results[1].success) {
      setState(() {
        _overview = null;
        _daily = const [];
        _isLoading = false;
        _errorMessage = !results[0].success ? results[0].message : results[1].message;
      });
      return;
    }
    setState(() {
      _overview = results[0].data as AdminMetricsOverview?;
      _daily = (results[1].data as List<dynamic>? ?? const [])
          .whereType<AdminDailyMetrics>()
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1021),
        foregroundColor: Colors.white,
        title: const Text('Growth KPIs'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadMetrics,
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
        message: 'Could not load metrics: $_errorMessage',
        onRetry: _loadMetrics,
      );
    }
    final overview = _overview;
    if (overview == null) {
      return const AdminEmptyState(message: 'No metrics available.');
    }
    return Column(
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.55,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            _metric('Total users', overview.totalUsers),
            _metric('New users\nthis week', overview.newUsers),
            _metric('Total events', overview.totalEvents),
            _metric('New events\nthis week', overview.newEvents),
            _metric('Registrations', overview.registrations),
            _metric('Comments', overview.comments),
            _metric('Pending reports', overview.pendingReports),
            _metric('Host requests', overview.pendingHostVerifications),
          ],
        ),
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
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.65))),
        ],
      ),
    );
  }
}
