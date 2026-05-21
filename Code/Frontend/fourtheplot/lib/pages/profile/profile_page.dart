import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:fourtheplot/pages/event_details/event_details_page.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';
import 'package:fourtheplot/pages/settings/settings_page.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Event> _hostedEvents = const [];
  List<Event> _upcomingJoinedEvents = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileEvents();
  }

  Future<void> _loadProfileEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userId = MainWrapper.loggedInUser.id;
    final results = await Future.wait([
      DatabaseHelper.instance.getEventsByHostId(userId),
      DatabaseHelper.instance.getRegisteredEvents(userId),
    ]);
    if (!mounted) {
      return;
    }

    final hostedResult = results[0];
    final registeredResult = results[1];
    if (!hostedResult.success || !registeredResult.success) {
      setState(() {
        _isLoading = false;
        _errorMessage = !hostedResult.success
            ? hostedResult.message
            : registeredResult.message;
      });
      return;
    }

    final now = DateTime.now();
    final hostedEvents = _eventsFromResult(hostedResult)..sort(_sortByStartDate);
    final upcomingJoinedEvents = _eventsFromResult(
      registeredResult,
    ).where((event) => !event.startAt.isBefore(now)).toList()..sort(_sortByStartDate);

    setState(() {
      _hostedEvents = hostedEvents;
      _upcomingJoinedEvents = upcomingJoinedEvents;
      _isLoading = false;
    });
  }

  List<Event> _eventsFromResult(ApiResult result) {
    return (result.data as List<dynamic>? ?? const []).whereType<Event>().toList();
  }

  int _sortByStartDate(Event a, Event b) {
    return a.startAt.compareTo(b.startAt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: _loadProfileEvents,
          child: ListView(
            children: [
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildSettingsButton(),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MainWrapper.loggedInUser.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          MainWrapper.loggedInUser.email,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildStatsPill(),
              const SizedBox(height: 20),
              _buildContent(),
            ],
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
              'Could not load profile events: $_errorMessage',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _loadProfileEvents, child: const Text('Try again')),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildEventSection(
          icon: Icons.storefront,
          iconColor: const Color.fromARGB(255, 238, 187, 34),
          title: 'Hosted Events',
          emptyText: 'You are not hosting any events yet.',
          events: _hostedEvents,
        ),
        const SizedBox(height: 20),
        _buildEventSection(
          icon: Icons.event_available,
          iconColor: const Color(0xFFC084FC),
          title: 'Upcoming Events',
          emptyText: 'You have not joined any upcoming events.',
          events: _upcomingJoinedEvents,
        ),
      ],
    );
  }

  Widget _buildEventSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String emptyText,
    required List<Event> events,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (events.isEmpty)
          _buildEmptyCard(emptyText)
        else
          ...events.map(_buildProfileEventCard),
      ],
    );
  }

  Widget _buildSettingsButton() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: IconButton(
        onPressed: () {
          Navigator.of(
            context,
            rootNavigator: true,
          ).push(MaterialPageRoute(builder: (context) => SettingsPage()));
        },
        icon: const Icon(Icons.settings, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Color(0xFF48C6EF), Color(0xFF6F86FF)]),
      ),
      child: Center(
        child: Text(
          _initials(MainWrapper.loggedInUser.displayName),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
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

  Widget _buildStatsPill() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          _buildStatItem(
            _isLoading ? '-' : _hostedEvents.length.toString(),
            'Events hosted',
            const Color(0xFF22D3EE),
          ),
          _buildDivider(),
          _buildStatItem(
            _isLoading ? '-' : _upcomingJoinedEvents.length.toString(),
            'Events upcoming',
            const Color(0xFFC084FC),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: Colors.white.withValues(alpha: 0.06),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
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
      decoration: BoxDecoration(
        color: const Color(0xFF1A1B1F),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Text(message, style: TextStyle(color: Colors.white.withValues(alpha: 0.65))),
    );
  }

  Widget _buildProfileEventCard(Event event) {
    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => EventDetailsPage(event: event)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1B1F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
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
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM d, h:mm a').format(event.startAt),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.place,
                        size: 14,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location.venueName?.isNotEmpty == true
                              ? event.location.venueName!
                              : event.location.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
