import 'package:flutter/material.dart';
import 'package:fourtheplot/common/colors.dart';
import 'package:fourtheplot/pages/add_event/add_event_draft.dart';
import 'package:fourtheplot/pages/add_event/add_event_photos_page.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddEventDetailsPage extends StatefulWidget {
  const AddEventDetailsPage({super.key});

  @override
  State<AddEventDetailsPage> createState() => _AddEventDetailsPageState();
}

class _AddEventDetailsPageState extends State<AddEventDetailsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _venueController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoriesController;
  late final TextEditingController _tagsController;
  late final TextEditingController _capacityController;

  @override
  void initState() {
    super.initState();
    final draft = context.read<AddEventDraft>();
    _titleController = TextEditingController(text: draft.title);
    _descriptionController = TextEditingController(text: draft.description);
    _locationController = TextEditingController(text: draft.locationAddress);
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
    _venueController.dispose();
    _priceController.dispose();
    _categoriesController.dispose();
    _tagsController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate(AddEventDraft draft) async {
    final picked = await _pickDateTime(draft.startAt ?? DateTime.now());
    if (picked == null) {
      return;
    }
    if (draft.endAt != null && picked.isAfter(draft.endAt!)) {
      _showMessage('Start time must be before end time.');
      return;
    }
    draft.setStartAt(picked);
  }

  Future<void> _pickEndDate(AddEventDraft draft) async {
    final base = draft.startAt ?? DateTime.now();
    final picked = await _pickDateTime(draft.endAt ?? base);
    if (picked == null) {
      return;
    }
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
    if (date == null) {
      return null;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return 'Select date & time';
    }
    return DateFormat('EEE, MMM d • h:mm a').format(value);
  }

  void _handleNext(AddEventDraft draft) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
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
        builder: (context) =>
            ChangeNotifierProvider.value(value: draft, child: const AddEventPhotosPage()),
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
    final draft = context.watch<AddEventDraft>();

    return Scaffold(
      backgroundColor: backgroundColor,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(10, 12, 10, 24),
        children: [
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create Event",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                  ),
                  Text("Step 1 of 3", style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          _buildSectionCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    onTapOutside: (PointerDownEvent event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Event title', icon: Icons.event),
                    onChanged: draft.setTitle,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onTapOutside: (PointerDownEvent event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: _inputDecoration('Description', icon: Icons.text_snippet),
                    onChanged: draft.setDescription,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onTapOutside: (PointerDownEvent event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    controller: _locationController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Location address', icon: Icons.place),
                    onChanged: draft.setLocationAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Location is required.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onTapOutside: (PointerDownEvent event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    controller: _venueController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Venue name (optional)',
                      icon: Icons.location_city,
                    ),
                    onChanged: draft.setVenueName,
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
                      if (!value) {
                        _priceController.text = '';
                      }
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
                    onTapOutside: (PointerDownEvent event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    controller: _priceController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    enabled: draft.isPaid,
                    decoration: _inputDecoration(
                      'Price (EUR)',
                      icon: Icons.sell,
                      helper: draft.isPaid ? 'Enter ticket price' : 'Free event',
                    ),
                    onChanged: (value) {
                      final parsed = double.tryParse(value) ?? 0.0;
                      draft.setPrice(parsed);
                    },
                    validator: (value) {
                      if (!draft.isPaid) {
                        return null;
                      }
                      final parsed = double.tryParse(value ?? '') ?? 0.0;
                      if (parsed <= 0) {
                        return 'Price must be greater than 0.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onTapOutside: (PointerDownEvent event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    controller: _categoriesController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Categories (comma separated)',
                      icon: Icons.category,
                    ),
                    onChanged: draft.setCategoriesFromText,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onTapOutside: (PointerDownEvent event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    controller: _tagsController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      'Tags (comma separated)',
                      icon: Icons.tag,
                    ),
                    onChanged: draft.setTagsFromText,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    onTapOutside: (PointerDownEvent event) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    },
                    controller: _capacityController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      'Capacity (optional)',
                      icon: Icons.groups,
                    ),
                    onChanged: (value) {
                      final parsed = int.tryParse(value);
                      draft.setCapacityMax(parsed);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 110),
        ],
      ),
      bottomNavigationBar: _BottomActionBar(label: 'Next', onPressed: () => _handleNext(draft)),
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
