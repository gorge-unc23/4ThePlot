import 'package:flutter/material.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:fourtheplot/widgets/trending_event.dart';
import 'package:location/location.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final GlobalKey<FormState> _searchFormKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();

  List<Event> _trendingEvents = const [];
  List<Event> _nearbyEvents = const [];
  bool _isLoading = true;
  String? _errorMessage;

  bool _isSearching = false;
  bool _isSearchLoading = false;
  String? _searchErrorMessage;
  String _searchQuery = '';
  List<Event> _searchResults = const [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    _loadEvents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  late LocationData _locationData;
  bool _allowedNearEvents = false;

  Future<void> _loadEvents() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    _allowedNearEvents = true;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final resultTrending = await DatabaseHelper.instance.getTrendingEvents();
    final resultNearby = await DatabaseHelper.instance.getNearbyEvents(
      _locationData.latitude!,
      _locationData.longitude!,
    );

    if (!mounted) {
      return;
    }

    if (!resultTrending.success || resultTrending.data is! List<Event>) {
      setState(() {
        _trendingEvents = const [];
        _isLoading = false;
        _errorMessage = resultTrending.message;
      });
      return;
    }

    if (!resultNearby.success || resultNearby.data is! List<Event>) {
      setState(() {
        _trendingEvents = const [];
        _isLoading = false;
        _errorMessage = resultNearby.message;
      });
      return;
    }

    setState(() {
      _trendingEvents = resultTrending.data as List<Event>;
      _nearbyEvents = resultNearby.data as List<Event>;
      _isLoading = false;
    });
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchQuery = '';
        _searchResults = const [];
        _searchErrorMessage = null;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isSearchLoading = true;
      _searchQuery = trimmed;
      _searchErrorMessage = null;
      _searchResults = const [];
    });

    final result = await DatabaseHelper.instance.getSearchedEvents(trimmed);
    if (!mounted) {
      return;
    }

    if (!result.success || result.data is! List<Event>) {
      setState(() {
        _searchResults = const [];
        _isSearchLoading = false;
        _searchErrorMessage = result.message;
      });
      return;
    }

    setState(() {
      _searchResults = result.data as List<Event>;
      _isSearchLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: () async {
            if (_isSearching) {
              await _performSearch(_searchQuery);
            } else {
              await _loadEvents();
            }
            setState(() {});
          },
          child: ListView(
            children: [
              const SizedBox(height: 6),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Discover Events",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                      ),
                      Text(
                        "Find amazing experiences near you",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Form(
                key: _searchFormKey,
                child: TextFormField(
                  controller: _searchController,
                  onTapOutside: (PointerDownEvent event) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onFieldSubmitted: (value) {
                    _performSearch(value);
                  },
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    hintText: "Search events, venues...",
                    suffixIcon: _searchController.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              _performSearch('');
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _isSearching ? _buildSearchContent() : _buildEventsContent(),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventsContent() {
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
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _loadEvents, child: const Text('Try again')),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "✨ Trending Events",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        const SizedBox(height: 12),
        if (_trendingEvents.isEmpty) ...[
          Center(
            child: Text('No trending events found', style: TextStyle(color: Colors.grey)),
          ),
        ] else ...[
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, index) {
                return SizedBox(
                  width: 320,
                  child: TrendingEvent(event: _trendingEvents[index]),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemCount: _trendingEvents.length,
            ),
          ),
        ],
        const SizedBox(height: 12),
        const Text(
          "Events near you",
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
        ),
        const SizedBox(height: 12),
        if (_allowedNearEvents) ...[
          if (_nearbyEvents.isEmpty) ...[
            Center(
              child: Text("No nearby events found", style: TextStyle(color: Colors.grey)),
            ),
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TrendingEvent(event: _nearbyEvents[index]),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemCount: _nearbyEvents.length,
            ),
          ],
        ] else ...[
          Center(
            child: Text(
              "Location permission not granted.\nGive location permission to view.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSearchContent() {
    if (_isSearchLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_searchErrorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Text(
              'Search failed: $_searchErrorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _performSearch(_searchQuery),
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Showing results for "$_searchQuery"',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        const SizedBox(height: 12),
        if (_searchResults.isEmpty)
          const Center(
            child: Text('No results found', style: TextStyle(color: Colors.grey)),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TrendingEvent(event: _searchResults[index]),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemCount: _searchResults.length,
          ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            _searchController.clear();
            _performSearch('');
          },
          child: const Text('Back to discover'),
        ),
      ],
    );
  }
}
