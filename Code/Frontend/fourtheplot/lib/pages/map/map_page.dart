import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fourtheplot/mock/mock_events.dart';
import 'package:fourtheplot/models/event.dart';
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
    'Tirana': LatLng(41.3275, 19.8189),
    'Durres': LatLng(41.3231, 19.4414),
    'Vlore': LatLng(40.4667, 19.4897),
    'Shkoder': LatLng(42.0683, 19.5126),
  };

  final MapController _mapController = MapController();
  late final List<Marker> _markers;
  String? _selectedTitle;

  @override
  void initState() {
    super.initState();
    _markers = _buildMarkers();
  }

  List<Marker> _buildMarkers() {
    final markers = <Marker>[];
    for (final event in mockEvents) {
      final position = _resolveEventPosition(event);
      if (position == null) {
        continue;
      }
      markers.add(
        Marker(
          point: position,
          width: 44,
          height: 44,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedTitle = event.title;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
              ),
              child: const Icon(Icons.place, color: Colors.white, size: 22),
            ),
          ),
        ),
      );
    }
    return markers;
  }

  LatLng? _resolveEventPosition(Event event) {
    final latitude = event.location.latitude;
    final longitude = event.location.longitude;
    if (latitude != null && longitude != null) {
      return LatLng(latitude, longitude);
    }
    final city = _extractCity(event.location.address);
    return _cityCoordinates[city];
  }

  String _extractCity(String address) {
    if (address.isEmpty) {
      return '';
    }
    final parts = address.split('•');
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
                // Include everything EXCEPT rotate
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onTap: (_, _) {
                setState(() {
                  _selectedTitle = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.fourtheplot',
              ),
              MarkerLayer(markers: _markers),
              RichAttributionWidget(
                attributions: const [TextSourceAttribution('OpenStreetMap contributors')],
              ),
            ],
          ),
          if (_selectedTitle != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Text(
                  _selectedTitle!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
