import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:fourtheplot/models/user.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';
import 'package:fourtheplot/widgets/report_dialog.dart';
import 'package:intl/intl.dart';

class BusinessProfilePage extends StatefulWidget {
  final int hostId;
  final String? currentEventId;
  final String? initialHostName;
  final void Function(BuildContext context, Event event)? onEventTap;

  const BusinessProfilePage({
    super.key,
    required this.hostId,
    this.currentEventId,
    this.initialHostName,
    this.onEventTap,
  });

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage> {
  User? _host;
  List<Event> _hostedEvents = const [];
  bool _isLoading = true;
  bool _isReportingHost = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final results = await Future.wait([
      DatabaseHelper.instance.getUser(widget.hostId),
      DatabaseHelper.instance.getEventsByHostId(widget.hostId),
    ]);
    if (!mounted) return;

    final userResult = results[0];
    final eventsResult = results[1];
    if (!userResult.success || userResult.data is! User) {
      setState(() {
        _isLoading = false;
        _errorMessage = userResult.message;
      });
      return;
    }
    if (!eventsResult.success) {
      setState(() {
        _isLoading = false;
        _errorMessage = eventsResult.message;
      });
      return;
    }

    final events = (eventsResult.data as List<dynamic>? ?? const [])
        .whereType<Event>()
        .where((event) => event.id != widget.currentEventId)
        .toList()
      ..sort((a, b) => a.startAt.compareTo(b.startAt));

    setState(() {
      _host = userResult.data as User;
      _hostedEvents = events;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final fallbackTitle = widget.initialHostName ?? 'Host profile';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1021),
        foregroundColor: Colors.white,
        title: Text(_hostName(_host) ?? fallbackTitle),
        actions: [
          if (_canReportHost)
            IconButton(
              onPressed: _isReportingHost ? null : _handleReportHost,
              tooltip: 'Report host',
              icon: _isReportingHost
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.flag_outlined),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 64),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_errorMessage != null)
              _buildError()
            else ...[
              _buildHostSummary(_host!),
              const SizedBox(height: 20),
              _buildEventsSection(),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleReportHost() async {
    final host = _host;
    if (host == null || _isReportingHost) {
      return;
    }
    final report = await showReportDialog(context, title: 'Report host');
    if (report == null) {
      return;
    }

    setState(() => _isReportingHost = true);
    final result = await DatabaseHelper.instance.createSafetyReport(
      reportedUserId: host.id,
      reason: report.reason,
      severity: report.severity,
    );
    if (!mounted) return;
    setState(() => _isReportingHost = false);
    if (!result.success) {
      _showMessage('Could not submit report: ${result.message}');
      return;
    }
    _showMessage('Report submitted for review.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Text(
            'Could not load host profile: $_errorMessage',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: _loadProfile, child: const Text('Try again')),
        ],
      ),
    );
  }

  Widget _buildHostSummary(User host) {
    final businessProfile = host.businessProfile;
    final description = businessProfile?.description?.trim();
    final websiteUrl = businessProfile?.websiteUrl?.trim();
    final credibility = host.hostCredibility;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildHostImage(host),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hostName(host) ?? 'Host #${host.id}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      host.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
              ),
              if (credibility?.trusted == true) _buildVerifiedRibbon(),
            ],
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.76),
                height: 1.45,
              ),
            ),
          ],
          if (websiteUrl != null && websiteUrl.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.language,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.65),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    websiteUrl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          _buildCredibilitySummary(
            rating: credibility?.rating,
            reviewCount: credibility?.reviewCount,
            trusted: credibility?.trusted,
          ),
        ],
      ),
    );
  }

  Widget _buildEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.event_available, color: Color(0xFFC084FC)),
            SizedBox(width: 8),
            Text(
              'Other hosted events',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_hostedEvents.isEmpty)
          _buildEmptyCard('This host has no other events yet.')
        else
          ..._hostedEvents.map(_buildEventCard),
      ],
    );
  }

  Widget _buildCredibilitySummary({
    required double? rating,
    required int? reviewCount,
    required bool? trusted,
  }) {
    final roundedRating = rating ?? 0;
    return Row(
      children: [
        Icon(
          trusted == true ? Icons.verified : Icons.shield_outlined,
          color: trusted == true ? const Color(0xFF22D3EE) : Colors.white54,
          size: 18,
        ),
        const SizedBox(width: 8),
        ...List.generate(5, (index) {
          final filled = index < roundedRating.round().clamp(0, 5);
          return Icon(
            filled ? Icons.star : Icons.star_border,
            color: const Color(0xFFFACC15),
            size: 18,
          );
        }),
        const SizedBox(width: 8),
        Text(
          roundedRating.toStringAsFixed(1),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 6),
        Text(
          '(${reviewCount ?? 0} reviews)',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
      ],
    );
  }

  Widget _buildHostImage(User host) {
    final imageUrl = host.businessProfile?.logoUrl?.trim().isNotEmpty == true
        ? host.businessProfile!.logoUrl
        : host.avatarUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildImageFallback(host);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildImageFallback(host),
      ),
    );
  }

  Widget _buildImageFallback(User host) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF22D3EE).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          _initials(_hostName(host) ?? host.displayName),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildVerifiedRibbon() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF22D3EE).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF22D3EE).withValues(alpha: 0.4),
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: Color(0xFF22D3EE)),
          SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(
              color: Color(0xFF22D3EE),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Text(message, style: TextStyle(color: Colors.white.withValues(alpha: 0.65))),
    );
  }

  Widget _buildEventCard(Event event) {
    return InkWell(
      onTap: () {
        widget.onEventTap?.call(context, event);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                event.coverImageUrl,
                width: 62,
                height: 62,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 62,
                  height: 62,
                  color: Colors.white.withValues(alpha: 0.08),
                  child: const Icon(Icons.image_not_supported, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _eventMeta(
                    Icons.calendar_month,
                    DateFormat('MMM d, h:mm a').format(event.startAt),
                  ),
                  const SizedBox(height: 4),
                  _eventMeta(
                    Icons.place,
                    event.location.venueName?.isNotEmpty == true
                        ? event.location.venueName!
                        : event.location.address,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _eventMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF1A1B1F),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
    );
  }

  String? _hostName(User? host) {
    final businessName = host?.businessProfile?.name;
    if (businessName != null && businessName.isNotEmpty) {
      return businessName;
    }
    final displayName = host?.displayName;
    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }
    return null;
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  bool get _canReportHost {
    final host = _host;
    return host != null &&
        MainWrapper.loggedInUser.role != UserRole.admin &&
        host.id != MainWrapper.loggedInUser.id;
  }
}
