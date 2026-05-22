import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fourtheplot/common/colors.dart';
import 'package:fourtheplot/pages/edit_event/edit_event_draft.dart';
import 'package:fourtheplot/pages/edit_event/edit_event_summary.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditEventPhotosPage extends StatefulWidget {
  const EditEventPhotosPage({super.key});

  @override
  State<EditEventPhotosPage> createState() => _EditEventPhotosPageState();
}

class _EditEventPhotosPageState extends State<EditEventPhotosPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickCoverImage(EditEventDraft draft) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    draft.setReplacementCoverImage(file);
  }

  Future<void> _pickGalleryImages(EditEventDraft draft) async {
    final files = await _picker.pickMultiImage();
    if (files.isEmpty) return;
    draft.addGalleryImages(files);
  }

  void _handleNext(EditEventDraft draft) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChangeNotifierProvider.value(
          value: draft,
          child: const EditEventSummaryPage(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = context.watch<EditEventDraft>();
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: const Text('Edit photos'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(
            'Step 2 of 3',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cover image',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _CoverImagePreview(draft: draft),
                const SizedBox(height: 12),
                _PrimaryButton(
                  label: draft.hasReplacementCover
                      ? 'Replace selected image'
                      : 'Replace cover image',
                  onPressed: () => _pickCoverImage(draft),
                ),
                if (draft.hasReplacementCover) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => draft.setReplacementCoverImage(null),
                    child: const Text('Keep current cover instead'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gallery (optional)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                if (draft.galleryImages.isEmpty)
                  Text(
                    'Gallery uploads are not sent yet. Selected images stay in this draft.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(
                      draft.galleryImages.length,
                      (index) => _GalleryThumbnail(
                        image: draft.galleryImages[index],
                        onRemove: () => draft.removeGalleryImageAt(index),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                _PrimaryButton(
                  label: 'Add gallery photos',
                  onPressed: () => _pickGalleryImages(draft),
                ),
              ],
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
}

class _CoverImagePreview extends StatelessWidget {
  final EditEventDraft draft;

  const _CoverImagePreview({required this.draft});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: draft.replacementCoverImage != null
            ? _LocalImagePreview(image: draft.replacementCoverImage!, fit: BoxFit.cover)
            : Image.network(
                draft.coverImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.white.withValues(alpha: 0.08),
                  child: const Icon(Icons.image_not_supported, color: Colors.white54),
                ),
              ),
      ),
    );
  }
}

class _GalleryThumbnail extends StatelessWidget {
  final XFile image;
  final VoidCallback onRemove;

  const _GalleryThumbnail({required this.image, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 90,
            width: 90,
            child: _LocalImagePreview(image: image, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _LocalImagePreview extends StatelessWidget {
  final XFile image;
  final BoxFit fit;

  const _LocalImagePreview({required this.image, required this.fit});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return Image.network(image.path, fit: fit);
    return Image.file(File(image.path), fit: fit);
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

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label, style: const TextStyle(color: Colors.white)),
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
