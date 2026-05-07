import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(41.3275, 19.8189),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Map page")),
      body: GoogleMap(
        // Set your Map ID.
        mapId: 'my-map-id',
        mapType: MapType.normal,
        // markerType: GoogleMapMarkerType.advancedMarker,
        initialCameraPosition: _kGooglePlex,
      ),
    );
  }
}
