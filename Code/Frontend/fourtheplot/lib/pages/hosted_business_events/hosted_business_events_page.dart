import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:fourtheplot/pages/event_details/event_details_page.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';
import 'package:intl/intl.dart';

class HostedBusinessEventsPage extends StatefulWidget {
  const HostedBusinessEventsPage({super.key});

  @override
  State<HostedBusinessEventsPage> createState() => _HostedBusinessEventsPageState();
}

class _HostedBusinessEventsPageState extends State<HostedBusinessEventsPage> {
  List<Event> _events = const [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await DatabaseHelper.instance.getEventsByHostId(
      MainWrapper.loggedInUser.id,
    );
    if (!mounted) return;

    if (!result.success || result.data is! List<Event>) {
      setState(() {
        _events = const [];
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }

    final events = List<Event>.from(result.data as List<Event>)
      ..sort((a, b) => a.startAt.compareTo(b.startAt));
    setState(() {
      _events = events;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: _loadEvents,
          child: ListView(
            children: [
              const SizedBox(height: 6),
              const Text(
                'Hosted Events',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Manage events hosted by your business',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
              ),
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
              'Could not load hosted events: $_errorMessage',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _loadEvents, child: const Text('Try again')),
          ],
        ),
      );
    }

    if (_events.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1B1F),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Text(
          'Your business is not hosting any events yet.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
        ),
      );
    }

    return Column(children: _events.map(_buildEventCard).toList());
  }

  Widget _buildEventCard(Event event) {
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
                width: 68,
                height: 68,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 68,
                  height: 68,
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
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildMetaRow(
                    Icons.calendar_month,
                    DateFormat('MMM d, h:mm a').format(event.startAt),
                  ),
                  const SizedBox(height: 4),
                  _buildMetaRow(
                    Icons.place,
                    event.location.venueName?.isNotEmpty == true
                        ? event.location.venueName!
                        : event.location.address,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ),
      ],
    );
  }
}
