import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:fourtheplot/models/user.dart';
import 'package:fourtheplot/pages/event_details/event_details_page.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static final LatLng _initialCenter = LatLng(41.3275, 19.8189);
  static const double _initialZoom = 13.5;
  static final Map<String, LatLng> _cityCoordinates = {
    'tirana': LatLng(41.3275, 19.8189),
    'durres': LatLng(41.3231, 19.4414),
    'durrës': LatLng(41.3231, 19.4414),
    'vlore': LatLng(40.4667, 19.4897),
    'vlorë': LatLng(40.4667, 19.4897),
    'shkoder': LatLng(42.0683, 19.5126),
    'shkodër': LatLng(42.0683, 19.5126),
  };

  final MapController _mapController = MapController();
  List<Event> _events = const [];
  Event? _selectedEvent;
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

    final isBusiness = MainWrapper.loggedInUser.role == UserRole.business;
    final result = isBusiness
        ? await DatabaseHelper.instance.getEventsByHostId(MainWrapper.loggedInUser.id)
        : await DatabaseHelper.instance.getAllEvents();
    if (!mounted) {
      return;
    }

    if (!result.success || result.data is! List<Event>) {
      setState(() {
        _events = const [];
        _selectedEvent = null;
        _isLoading = false;
        _errorMessage = result.message;
      });
      return;
    }

    final events =
        (result.data as List<Event>)
            .where((event) => _resolveEventPosition(event) != null)
            .toList()
          ..sort((a, b) => a.startAt.compareTo(b.startAt));

    setState(() {
      _events = events;
      _selectedEvent = null;
      _isLoading = false;
    });
  }

  List<Marker> _buildMarkers() {
    return _events.map((event) {
      final position = _resolveEventPosition(event)!;
      final isSelected = _selectedEvent?.id == event.id;
      return Marker(
        point: position,
        width: isSelected ? 52 : 44,
        height: isSelected ? 52 : 44,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedEvent = event;
            });
            _mapController.move(position, _mapController.camera.zoom);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF6EA8FF)
                  : Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              isSelected ? Icons.event_available : Icons.place,
              color: Colors.white,
              size: isSelected ? 25 : 22,
            ),
          ),
        ),
      );
    }).toList();
  }

  LatLng? _resolveEventPosition(Event event) {
    final latitude = event.location.latitude;
    final longitude = event.location.longitude;
    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }
    final city = (event.location.city?.isNotEmpty == true)
        ? event.location.city!
        : _extractCity(event.location.address);
    return _cityCoordinates[city.toLowerCase()];
  }

  String _extractCity(String address) {
    if (address.isEmpty) {
      return '';
    }
    final parts = address.split(RegExp(r'[•,\-]'));
    return parts.isNotEmpty ? parts.first.trim() : address.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _initialZoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onTap: (_, _) {
                setState(() {
                  _selectedEvent = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.fourtheplot',
              ),
              MarkerLayer(markers: _buildMarkers()),
              RichAttributionWidget(
                attributions: const [TextSourceAttribution('OpenStreetMap contributors')],
              ),
            ],
          ),
          Positioned(
            top: 12,
            right: 12,
            child: SafeArea(
              child: Material(
                color: Colors.black.withValues(alpha: 0.55),
                shape: const CircleBorder(),
                elevation: 8,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    _loadEvents();
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.refresh_rounded,
                      size: 26,
                      color: Colors.white.withValues(alpha: 0.92),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading) _buildLoadingOverlay(),
          if (_errorMessage != null) _buildErrorPanel(),
          if (!_isLoading && _errorMessage == null && _events.isEmpty) _buildEmptyPanel(),
          if (_selectedEvent != null) _buildSelectedEventPanel(_selectedEvent!),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.18),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildErrorPanel() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: _MapPanel(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Could not load events: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 10),
            OutlinedButton(onPressed: _loadEvents, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPanel() {
    return const Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: _MapPanel(
        child: Text(
          'No events with map locations found.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSelectedEventPanel(Event event) {
    final place = event.location.venueName?.isNotEmpty == true
        ? event.location.venueName!
        : event.location.address;
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: _MapPanel(
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                event.coverImageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 72,
                  height: 72,
                  color: Colors.white.withValues(alpha: 0.08),
                  child: const Icon(Icons.image_not_supported, color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    DateFormat('MMM d, h:mm a').format(event.startAt),
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    place,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.62)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Event details',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => EventDetailsPage(event: event)),
                );
              },
              icon: const Icon(Icons.chevron_right, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPanel extends StatelessWidget {
  final Widget child;

  const _MapPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
