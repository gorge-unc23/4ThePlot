import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fourtheplot/common/colors.dart';
import 'package:fourtheplot/pages/edit_event/edit_event_draft.dart';
import 'package:fourtheplot/pages/edit_event/edit_event_photos_page.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class EditEventDetailsPage extends StatefulWidget {
  const EditEventDetailsPage({super.key});

  @override
  State<EditEventDetailsPage> createState() => _EditEventDetailsPageState();
}

class _EditEventDetailsPageState extends State<EditEventDetailsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _cityController;
  late final TextEditingController _venueController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoriesController;
  late final TextEditingController _tagsController;
  late final TextEditingController _capacityController;

  @override
  void initState() {
    super.initState();
    final draft = context.read<EditEventDraft>();
    _titleController = TextEditingController(text: draft.title);
    _descriptionController = TextEditingController(text: draft.description);
    _locationController = TextEditingController(text: draft.locationAddress);
    _cityController = TextEditingController(text: draft.city);
    _venueController = TextEditingController(text: draft.venueName);
    _priceController = TextEditingController(
      text: draft.price > 0 ? draft.price.toStringAsFixed(2) : '',
    );
    _categoriesController = TextEditingController(text: draft.categoriesText());
    _tagsController = TextEditingController(text: draft.tagsText());
    _capacityController = TextEditingController(
      text: draft.capacityMax?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _cityController.dispose();
    _venueController.dispose();
    _priceController.dispose();
    _categoriesController.dispose();
    _tagsController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate(EditEventDraft draft) async {
    final picked = await _pickDateTime(draft.startAt ?? DateTime.now());
    if (picked == null) return;
    if (draft.endAt != null && picked.isAfter(draft.endAt!)) {
      _showMessage('Start time must be before end time.');
      return;
    }
    draft.setStartAt(picked);
  }

  Future<void> _pickEndDate(EditEventDraft draft) async {
    final base = draft.startAt ?? DateTime.now();
    final picked = await _pickDateTime(draft.endAt ?? base);
    if (picked == null) return;
    if (draft.startAt != null && picked.isBefore(draft.startAt!)) {
      _showMessage('End time must be after start time.');
      return;
    }
    draft.setEndAt(picked);
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      initialDate: initial,
    );
    if (date == null || !mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickLocationOnMap(EditEventDraft draft) async {
    final selected = await showDialog<LatLng>(
      context: context,
      builder: (context) {
        return _LocationPickerDialog(
          initialPosition: draft.latitude != null && draft.longitude != null
              ? LatLng(draft.latitude!, draft.longitude!)
              : _cityCenter(draft.city),
        );
      },
    );
    if (selected == null) return;
    draft.setLocationCoordinates(
      latitude: selected.latitude,
      longitude: selected.longitude,
    );
  }

  LatLng _cityCenter(String city) {
    switch (city.trim().toLowerCase()) {
      case 'durres':
      case 'durrës':
      case 'durrÃ«s':
        return LatLng(41.3231, 19.4414);
      case 'vlore':
      case 'vlorë':
      case 'vlorÃ«':
        return LatLng(40.4667, 19.4897);
      case 'shkoder':
      case 'shkodër':
      case 'shkodÃ«r':
        return LatLng(42.0683, 19.5126);
      case 'tirana':
      default:
        return LatLng(41.3275, 19.8189);
    }
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return 'Select date & time';
    return DateFormat('EEE, MMM d • h:mm a').format(value);
  }

  String _formatCoordinates(EditEventDraft draft) {
    if (draft.latitude == null || draft.longitude == null) {
      return 'No exact map point selected';
    }
    return '${draft.latitude!.toStringAsFixed(5)}, ${draft.longitude!.toStringAsFixed(5)}';
  }

  void _handleNext(EditEventDraft draft) {
    if (!_formKey.currentState!.validate()) return;
    if (draft.startAt == null || draft.endAt == null) {
      _showMessage('Please pick a start and end time.');
      return;
    }
    if (draft.endAt!.isBefore(draft.startAt!)) {
      _showMessage('End time must be after start time.');
      return;
    }
    if (draft.isPaid && draft.price <= 0) {
      _showMessage('Enter a price greater than 0.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: draft,
          child: const EditEventPhotosPage(),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<EditEventDraft>();
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Edit event'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 24),
        children: [
          Text(
            'Step 1 of 3',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 12),
          _buildSectionCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _textField(
                    controller: _titleController,
                    label: 'Event title',
                    icon: Icons.event,
                    onChanged: draft.setTitle,
                    requiredMessage: 'Title is required.',
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _descriptionController,
                    label: 'Description',
                    icon: Icons.text_snippet,
                    onChanged: draft.setDescription,
                    requiredMessage: 'Description is required.',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _locationController,
                    label: 'Location address',
                    icon: Icons.place,
                    onChanged: draft.setLocationAddress,
                    requiredMessage: 'Location is required.',
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _cityController,
                    label: 'City',
                    icon: Icons.location_city,
                    onChanged: draft.setCity,
                    requiredMessage: 'City is required.',
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _venueController,
                    label: 'Venue name (optional)',
                    icon: Icons.location_city,
                    onChanged: draft.setVenueName,
                  ),
                  const SizedBox(height: 12),
                  _MapPickerField(
                    value: _formatCoordinates(draft),
                    hasSelection: draft.latitude != null && draft.longitude != null,
                    onPick: () => _pickLocationOnMap(draft),
                    onClear: draft.latitude != null && draft.longitude != null
                        ? draft.clearLocationCoordinates
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _DateTimeField(
                    label: 'Start date & time',
                    value: _formatDateTime(draft.startAt),
                    onTap: () => _pickStartDate(draft),
                  ),
                  const SizedBox(height: 12),
                  _DateTimeField(
                    label: 'End date & time',
                    value: _formatDateTime(draft.endAt),
                    onTap: () => _pickEndDate(draft),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    value: draft.isPaid,
                    onChanged: (value) {
                      draft.setIsPaid(value);
                      if (!value) _priceController.text = '';
                    },
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Paid event',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      'Toggle on to charge for tickets.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                    ),
                    activeThumbColor: accentBlue,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _priceController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: draft.isPaid,
                    decoration: _inputDecoration(
                      'Price (EUR)',
                      icon: Icons.sell,
                      helper: draft.isPaid ? 'Enter ticket price' : 'Free event',
                    ),
                    onChanged: (value) => draft.setPrice(double.tryParse(value) ?? 0),
                    validator: (value) {
                      if (!draft.isPaid) return null;
                      final parsed = double.tryParse(value ?? '') ?? 0;
                      return parsed <= 0 ? 'Price must be greater than 0.' : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _categoriesController,
                    label: 'Categories (comma separated)',
                    icon: Icons.category,
                    onChanged: draft.setCategoriesFromText,
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _tagsController,
                    label: 'Tags (comma separated)',
                    icon: Icons.tag,
                    onChanged: draft.setTagsFromText,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _capacityController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      'Capacity (optional)',
                      icon: Icons.groups,
                    ),
                    onChanged: (value) => draft.setCapacityMax(int.tryParse(value)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 110),
        ],
      ),
      bottomNavigationBar: _BottomActionBar(
        label: 'Next',
        onPressed: () => _handleNext(draft),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
    String? requiredMessage,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: _inputDecoration(label, icon: icon),
      onChanged: onChanged,
      validator: requiredMessage == null
          ? null
          : (value) => value == null || value.trim().isEmpty ? requiredMessage : null,
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(
    String label, {
    required IconData icon,
    String? helper,
  }) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      helperStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
      prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.7)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: accentBlue.withValues(alpha: 0.8), width: 1.5),
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTimeField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.white.withValues(alpha: 0.7)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

class _MapPickerField extends StatelessWidget {
  final String value;
  final bool hasSelection;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  const _MapPickerField({
    required this.value,
    required this.hasSelection,
    required this.onPick,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.map, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: hasSelection ? Colors.white : Colors.white.withValues(alpha: 0.55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onClear != null)
            IconButton(
              tooltip: 'Clear point',
              onPressed: onClear,
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          TextButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.add_location_alt, size: 18),
            label: Text(hasSelection ? 'Change' : 'Pick'),
          ),
        ],
      ),
    );
  }
}

class _LocationPickerDialog extends StatefulWidget {
  final LatLng initialPosition;

  const _LocationPickerDialog({required this.initialPosition});

  @override
  State<_LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<_LocationPickerDialog> {
  late LatLng _selectedPosition;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 520,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                color: const Color(0xFF171C38),
                child: const Text(
                  'Tap the map to pinpoint the event location',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: widget.initialPosition,
                    initialZoom: 15,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onTap: (_, point) => setState(() => _selectedPosition = point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.fourtheplot',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedPosition,
                          width: 46,
                          height: 46,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF6EA8FF),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.place, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    RichAttributionWidget(
                      attributions: const [
                        TextSourceAttribution('OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                color: const Color(0xFF101428),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_selectedPosition.latitude.toStringAsFixed(5)}, ${_selectedPosition.longitude.toStringAsFixed(5)}',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_selectedPosition),
                      child: const Text('Use point'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _BottomActionBar({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF171C38), Color(0xFF101428)]),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SizedBox(
        height: 48,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              child: Ink(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF9B6CFF), Color(0xFF6EA8FF)],
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
