import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fourtheplot/common/colors.dart';
import 'package:fourtheplot/database_manager.dart';
import 'package:fourtheplot/pages/main_wrapper.dart';
import 'package:fourtheplot/pages/add_event/add_event_draft.dart';
import 'package:fourtheplot/widgets/tag_chip.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddEventSummaryPage extends StatefulWidget {
  const AddEventSummaryPage({super.key});

  @override
  State<AddEventSummaryPage> createState() => _AddEventSummaryPageState();
}

class _AddEventSummaryPageState extends State<AddEventSummaryPage> {
  bool _isSubmitting = false;

  Future<void> _handleCreate(AddEventDraft draft) async {
    if (_isSubmitting) {
      return;
    }
    if (!draft.hasRequiredDetails || draft.coverImage == null) {
      _showMessage('Please complete event details and select a title image.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final photoResult = await DatabaseHelper.instance.uploadCoverImage(draft.coverImage!);
    if (!mounted) {
      return;
    }
    if (!photoResult.success || photoResult.data is! String) {
      setState(() {
        _isSubmitting = false;
      });
      _showMessage('Could not upload title image: ${photoResult.message}');
      return;
    }

    final eventResult = await DatabaseHelper.instance.createEvent(
      draft.toCreatePayload(
        hostId: MainWrapper.loggedInUser.id,
        coverImageUrl: photoResult.data as String,
      ),
    );
    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    if (!eventResult.success) {
      _showMessage('Could not create event: ${eventResult.message}');
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AddEventConfirmationPage()),
    );
    Future.microtask(draft.reset);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<AddEventDraft>();
    final dateLabel = _formatDateRange(draft.startAt, draft.endAt);
    final priceLabel = draft.isFree
        ? 'Free'
        : '${draft.currency} ${draft.price.toStringAsFixed(2)}';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Summary'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            'Step 3 of 3',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  draft.description,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
                ),
                const SizedBox(height: 12),
                _SummaryRow(label: 'Location', value: draft.locationAddress),
                _SummaryRow(
                  label: 'Venue',
                  value: draft.venueName.isEmpty ? 'N/A' : draft.venueName,
                ),
                _SummaryRow(label: 'Date & time', value: dateLabel),
                _SummaryRow(label: 'Price', value: priceLabel),
                _SummaryRow(
                  label: 'Capacity',
                  value: draft.capacityMax == null
                      ? 'Unlimited'
                      : draft.capacityMax.toString(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Title image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                if (draft.coverImage != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: _ImagePreview(image: draft.coverImage!, fit: BoxFit.cover),
                    ),
                  )
                else
                  Text(
                    'No title image selected',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (draft.galleryImages.isNotEmpty)
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gallery',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: draft.galleryImages
                        .map(
                          (image) => ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 90,
                              width: 90,
                              child: _ImagePreview(image: image, fit: BoxFit.cover),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
          if (draft.categories.isNotEmpty || draft.tags.isNotEmpty)
            const SizedBox(height: 18),
          if (draft.categories.isNotEmpty || draft.tags.isNotEmpty)
            _SectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories & tags',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...draft.categories.map(
                        (category) => TagChip(label: category, color: accentPurple),
                      ),
                      ...draft.tags.map(
                        (tag) => TagChip(label: '#$tag', color: accentBlue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 110),
        ],
      ),
      bottomNavigationBar: _BottomActionBar(
        label: _isSubmitting ? 'Creating event...' : 'Create event',
        onPressed: _isSubmitting ? null : () => _handleCreate(draft),
      ),
    );
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return 'Not set';
    }
    final startText = DateFormat('EEE, MMM d • h:mm a').format(start);
    final endText = DateFormat('EEE, MMM d • h:mm a').format(end);
    return '$startText - $endText';
  }
}

class AddEventConfirmationPage extends StatelessWidget {
  const AddEventConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Event created'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: panelColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: accentBlue, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Your event is ready to go.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your event has been created on the server.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Done', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
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
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final XFile image;
  final BoxFit fit;

  const _ImagePreview({required this.image, required this.fit});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Image.network(image.path, fit: fit);
    }
    return Image.file(File(image.path), fit: fit);
  }
}

class _BottomActionBar extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _BottomActionBar({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
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
                decoration: BoxDecoration(
                  gradient: isEnabled
                      ? const LinearGradient(
                          colors: [Color(0xFF9B6CFF), Color(0xFF6EA8FF)],
                        )
                      : null,
                  color: isEnabled ? null : Colors.white.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: isEnabled ? 1 : 0.6),
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
