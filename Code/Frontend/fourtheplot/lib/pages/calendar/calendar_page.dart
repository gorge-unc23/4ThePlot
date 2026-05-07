import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fourtheplot/mock/mock_events.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:intl/intl.dart';

enum CalendarScope { city, my }

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  static const int _initialPage = 1200;
  static const List<String> _cities = [
    'Tirana',
    'Durres',
    'Vlore',
    'Shkoder',
    'Elbasan',
    'Berat',
    'Korca',
    'Gjirokaster',
    'Fier',
    'Lezhe',
  ];

  final _EventRepository _repository = _MockEventRepository();
  final List<Color> _eventColors = [
    Color(0xFF10B981),
    Color(0xFFF97316),
    Color(0xFF6366F1),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
  ];

  late final DateTime _baseMonth;
  late final PageController _pageController;

  CalendarScope _scope = CalendarScope.city;
  String _selectedCity = _cities.first;
  bool _isLoading = false;
  int _pageIndex = _initialPage;
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  List<Event> _events = const [];
  Map<DateTime, List<Event>> _eventsByDate = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _baseMonth = DateTime(now.year, now.month);
    _currentMonth = _baseMonth;
    _selectedDate = _dateKey(now);
    _pageController = PageController(initialPage: _initialPage);
    _loadEvents();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    final events = _scope == CalendarScope.city
        ? await _repository.fetchCityEvents(_selectedCity)
        : await _repository.fetchJoinedEvents();

    if (!mounted) return;
    setState(() {
      _events = events..sort((a, b) => a.startAt.compareTo(b.startAt));
      _eventsByDate = _buildEventsIndex(_events);
      _isLoading = false;
    });
  }

  void _onScopeChanged(CalendarScope? scope) {
    if (scope == null || scope == _scope) return;
    setState(() {
      _scope = scope;
    });
    _loadEvents();
  }

  void _onCityChanged(String? city) {
    if (city == null || city == _selectedCity) return;
    setState(() {
      _selectedCity = city;
    });
    _loadEvents();
  }

  void _onPageChanged(int page) {
    final month = _monthFromPage(page);
    setState(() {
      _pageIndex = page;
      _currentMonth = month;
      if (!_isSameMonth(_selectedDate, month)) {
        _selectedDate = DateTime(month.year, month.month, 1);
      }
    });
  }

  void _goToMonth(int offset) {
    _pageController.animateToPage(
      _pageIndex + offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF0F1012),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: ListView(
            children: [
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Calendar",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                      ),
                      Text(
                        _scope == CalendarScope.city
                            ? "Search in cities for events"
                            : "Showing events you joined",
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CupertinoSlidingSegmentedControl<CalendarScope>(
                groupValue: _scope,
                thumbColor: const Color(0xFF7B5CFF),
                backgroundColor: const Color(0xFF1A1B1F),
                onValueChanged: _onScopeChanged,
                children: const {
                  CalendarScope.city: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('City events', style: TextStyle(color: Colors.white)),
                  ),
                  CalendarScope.my: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('My calendar', style: TextStyle(color: Colors.white)),
                  ),
                },
              ),
              const SizedBox(height: 14),
              if (_scope == CalendarScope.city)
                DropdownButtonFormField<String>(
                  initialValue: _selectedCity,
                  dropdownColor: const Color(0xFF1A1B1F),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'City',
                    labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                    filled: true,
                    fillColor: const Color(0xFF1A1B1F),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                    ),
                  ),
                  items: _cities
                      .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                      .toList(),
                  onChanged: _onCityChanged,
                ),
              const SizedBox(height: 16),
              _buildMonthHeader(),
              const SizedBox(height: 12),
              _buildWeekdayRow(),
              const SizedBox(height: 8),
              SizedBox(
                height: 320,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, index) {
                    final month = _monthFromPage(index);
                    return _buildMonthGrid(month);
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildAgendaHeader(),
              const SizedBox(height: 8),
              Expanded(child: _buildAgendaList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _goToMonth(-1),
          icon: const Icon(CupertinoIcons.chevron_left, color: Colors.white),
        ),
        Text(
          DateFormat('MMMM yyyy').format(_currentMonth),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: () => _goToMonth(1),
          icon: const Icon(CupertinoIcons.chevron_right, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildWeekdayRow() {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      children: labels
          .map(
            (label) => Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildMonthGrid(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final startOffset = (firstDay.weekday + 6) % 7;
    final startDate = firstDay.subtract(Duration(days: startOffset));
    final days = List.generate(42, (index) => startDate.add(Duration(days: index)));

    return Container(
      padding: EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
        ),
        itemCount: days.length,
        itemBuilder: (context, index) => _buildDayCell(days[index], month),
      ),
    );
  }

  Widget _buildDayCell(DateTime date, DateTime month) {
    final isInMonth = date.month == month.month;
    final isSelected = _isSameDate(date, _selectedDate);
    final isToday = _isSameDate(date, _dateKey(DateTime.now()));
    final dotColors = _eventDotColors(date);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = _dateKey(date);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? null
              : isInMonth
              ? const Color(0xFF1B1E23)
              : const Color(0xFF141518),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF7B5CFF), Color(0xFF4FC3FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          borderRadius: BorderRadius.circular(14),
          border: isToday && !isSelected
              ? Border.all(color: Colors.white.withValues(alpha: 0.35))
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                color: isInMonth ? Colors.white : Colors.white.withValues(alpha: 0.35),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            _buildDots(dotColors),
          ],
        ),
      ),
    );
  }

  Widget _buildDots(List<Color> colors) {
    if (colors.isEmpty) {
      return const SizedBox(height: 6);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: colors
          .take(3)
          .map(
            (color) => Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          )
          .toList(),
    );
  }

  Widget _buildAgendaHeader() {
    final label = DateFormat('EEE, MMM d').format(_selectedDate);
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1B1F),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              '${_selectedDate.day}',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildAgendaList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final events = _eventsForDate(_selectedDate);
    if (events.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      itemCount: events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final event = events[index];
        final color = _eventColor(event, index);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimeRange(event),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final message = _scope == CalendarScope.city
        ? 'No events on ${DateFormat('MMM d').format(_selectedDate)} in $_selectedCity.'
        : 'No joined events on ${DateFormat('MMM d').format(_selectedDate)}.';

    return Center(
      child: Text(
        message,
        style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        textAlign: TextAlign.center,
      ),
    );
  }

  DateTime _monthFromPage(int page) {
    return DateTime(_baseMonth.year, _baseMonth.month + (page - _initialPage));
  }

  DateTime _dateKey(DateTime date) => DateTime(date.year, date.month, date.day);

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }

  Map<DateTime, List<Event>> _buildEventsIndex(List<Event> events) {
    final map = <DateTime, List<Event>>{};
    for (final event in events) {
      final key = _dateKey(event.startAt);
      map.putIfAbsent(key, () => []).add(event);
    }
    for (final entry in map.entries) {
      entry.value.sort((a, b) => a.startAt.compareTo(b.startAt));
    }
    return map;
  }

  List<Event> _eventsForDate(DateTime date) {
    return _eventsByDate[_dateKey(date)] ?? const [];
  }

  List<Color> _eventDotColors(DateTime date) {
    final events = _eventsForDate(date);
    if (events.isEmpty) return const [];
    return List.generate(
      events.length.clamp(0, 3),
      (index) => _eventColor(events[index], index),
    );
  }

  Color _eventColor(Event event, int index) {
    final key = event.categories.isNotEmpty ? event.categories.first : event.id;
    final idx = key.hashCode.abs() % _eventColors.length;
    return _eventColors[(idx + index) % _eventColors.length];
  }

  String _formatTimeRange(Event event) {
    final start = DateFormat('hh:mm a').format(event.startAt);
    final end = DateFormat('hh:mm a').format(event.endAt);
    return '$start - $end';
  }
}

abstract class _EventRepository {
  Future<List<Event>> fetchCityEvents(String city);
  Future<List<Event>> fetchJoinedEvents();
}

class _MockEventRepository implements _EventRepository {
  @override
  Future<List<Event>> fetchCityEvents(String city) async {
    final cityLower = city.toLowerCase();
    return mockEvents.where((event) {
      final address = event.location.address.toLowerCase();
      final venue = (event.location.venueName ?? '').toLowerCase();
      return address.contains(cityLower) || venue.contains(cityLower);
    }).toList();
  }

  @override
  Future<List<Event>> fetchJoinedEvents() async {
    return mockEvents.where((event) => joinedEventIds.contains(event.id)).toList();
  }
}
