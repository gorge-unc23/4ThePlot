import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:fourtheplot/pages/event_details/event_details_page.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';
import 'package:intl/intl.dart';

class AdminEventsPage extends StatefulWidget {
  const AdminEventsPage({super.key});

  @override
  State<AdminEventsPage> createState() => _AdminEventsPageState();
}

class _AdminEventsPageState extends State<AdminEventsPage> {
  List<Event> _events = const [];
  bool _isLoading = true;
  bool _isDeleting = false;
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

    final result = await DatabaseHelper.instance.getAllEvents(useCache: false);
    if (!mounted) {
      return;
    }

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

  Future<void> _confirmDelete(Event event) async {
    final eventId = int.tryParse(event.id);
    if (eventId == null || _isDeleting) {
      _showSnackBar('Could not delete event: invalid event id.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete event?'),
        content: Text('This will remove "${event.title}" from the platform.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });
    final result = await DatabaseHelper.instance.deleteEvent(eventId);
    if (!mounted) {
      return;
    }
    setState(() {
      _isDeleting = false;
    });

    if (!result.success) {
      _showSnackBar('Could not delete event: ${result.message}');
      return;
    }

    setState(() {
      _events = _events.where((item) => item.id != event.id).toList();
    });
    _showSnackBar('Event deleted.');
    MainWrapper.refreshFrom(context);
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
            onRefresh: _loadEvents,
            child: ListView(
              children: [
                const SizedBox(height: 6),
                const Text(
                  'Events',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Inspect and moderate platform events',
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
              'Could not load events: $_errorMessage',
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
          'There are no events to moderate.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.65)),
        ),
      );
    }

    return Column(children: _events.map(_buildEventCard).toList());
  }

  Widget _buildEventCard(Event event) {
    final location = event.location.city?.isNotEmpty == true
        ? event.location.city!
        : event.location.venueName?.isNotEmpty == true
            ? event.location.venueName!
            : event.location.address;

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
            MaterialPageRoute(builder: (context) => EventDetailsPage(event: event)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                    _buildMetaRow(Icons.place, location),
                    if (event.hostName?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      _buildMetaRow(Icons.storefront, event.hostName!),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: _isDeleting ? null : () => _confirmDelete(event),
                tooltip: 'Delete event',
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),
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
