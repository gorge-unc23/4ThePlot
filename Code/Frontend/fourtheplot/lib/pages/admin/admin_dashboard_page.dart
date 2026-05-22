import 'package:flutter/material.dart';
import 'package:fourtheplot/pages/admin/admin_events_page.dart';
import 'package:fourtheplot/pages/admin/admin_host_verification_page.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  static const _tiles = [
    // _AdminTileData(
    //   title: 'Safety Reports',
    //   description: 'Review queued reports and prepare moderation decisions.',
    //   icon: Icons.report_outlined,
    //   color: Color(0xFFFF6B6B),
    //   isAvailable: false,
    // ),
    _AdminTileData(
      title: 'Host Verification',
      description: 'Verify submitted host documents and approval requests.',
      icon: Icons.verified_user_outlined,
      color: Color(0xFF22D3EE),
      isAvailable: true,
    ),
    // _AdminTileData(
    //   title: 'Disputes',
    //   description: 'Review evidence, chat logs, and refund outcomes.',
    //   icon: Icons.gavel_outlined,
    //   color: Color(0xFFFACC15),
    //   isAvailable: false,
    // ),
    // _AdminTileData(
    //   title: 'Global Notifications',
    //   description: 'Publish platform-wide announcements and banners.',
    //   icon: Icons.campaign_outlined,
    //   color: Color(0xFFC084FC),
    //   isAvailable: false,
    // ),
    // _AdminTileData(
    //   title: 'Growth KPIs',
    //   description: 'Monitor DAU, new events, and platform growth signals.',
    //   icon: Icons.insights_outlined,
    //   color: Color(0xFF34D399),
    //   isAvailable: false,
    // ),
    _AdminTileData(
      title: 'Event Moderation',
      description: 'Inspect events and remove events or comments.',
      icon: Icons.event_busy_outlined,
      color: Color(0xFF6EA8FF),
      isAvailable: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
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
              const SizedBox(height: 20),
              ..._tiles.map((tile) => _buildTile(context, tile)),
            ],
          ),
        ),
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
        onTap: () => _openTile(context, tile),
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
              if (!tile.isAvailable)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'API needed',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }

  void _openTile(BuildContext context, _AdminTileData tile) {
    if (tile.title == 'Event Moderation') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AdminEventsPage()),
      );
      return;
    }

    if (tile.title == 'Host Verification') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const AdminHostVerificationPage()),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminUnavailablePage(
          title: tile.title,
          description: tile.description,
        ),
      ),
    );
  }
}

class AdminUnavailablePage extends StatelessWidget {
  final String title;
  final String description;

  const AdminUnavailablePage({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1021),
        foregroundColor: Colors.white,
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1B1F),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 16),
              Text(
                'This use case is scaffolded in the UI, but the backend endpoint is not available yet.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.55)),
              ),
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
  final bool isAvailable;

  const _AdminTileData({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isAvailable,
  });
}
