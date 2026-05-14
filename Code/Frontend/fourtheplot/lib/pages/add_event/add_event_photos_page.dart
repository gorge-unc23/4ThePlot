import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fourtheplot/common/colors.dart';
import 'package:fourtheplot/pages/add_event/add_event_draft.dart';
import 'package:fourtheplot/pages/add_event/add_event_summary.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddEventPhotosPage extends StatefulWidget {
	const AddEventPhotosPage({super.key});

	@override
	State<AddEventPhotosPage> createState() => _AddEventPhotosPageState();
}

class _AddEventPhotosPageState extends State<AddEventPhotosPage> {
	final ImagePicker _picker = ImagePicker();

	Future<void> _pickCoverImage(AddEventDraft draft) async {
		final file = await _picker.pickImage(source: ImageSource.gallery);
		if (file == null) {
			return;
		}
		draft.setCoverImage(file);
	}

	Future<void> _pickGalleryImages(AddEventDraft draft) async {
		final files = await _picker.pickMultiImage();
		if (files.isEmpty) {
			return;
		}
		draft.addGalleryImages(files);
	}

	void _handleNext(AddEventDraft draft) {
		if (!draft.hasTitleImage) {
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					content: Text('Please select a title image.'),
					behavior: SnackBarBehavior.floating,
				),
			);
			return;
		}
		Navigator.of(context).push(
			MaterialPageRoute(
				builder: (context) => ChangeNotifierProvider.value(
					value: draft,
					child: const AddEventSummaryPage(),
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		final draft = context.watch<AddEventDraft>();

		return Scaffold(
			backgroundColor: backgroundColor,
			appBar: AppBar(
				backgroundColor: backgroundColor,
				elevation: 0,
				title: const Text('Add photos'),
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
									'Title image',
									style: TextStyle(
										color: Colors.white,
										fontSize: 18,
										fontWeight: FontWeight.w600,
									),
								),
								const SizedBox(height: 10),
								_CoverImagePreview(
									image: draft.coverImage,
									onRemove: () => draft.setCoverImage(null),
								),
								const SizedBox(height: 12),
								_PrimaryButton(
									label: draft.coverImage == null ? 'Select title image' : 'Replace title image',
									onPressed: () => _pickCoverImage(draft),
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
										'Add extra images to highlight your event.',
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
			bottomNavigationBar: SafeArea(
				top: false,
				child: _BottomActionBar(
					label: 'Next',
					onPressed: draft.hasTitleImage ? () => _handleNext(draft) : null,
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

class _CoverImagePreview extends StatelessWidget {
	final XFile? image;
	final VoidCallback onRemove;

	const _CoverImagePreview({required this.image, required this.onRemove});

	@override
	Widget build(BuildContext context) {
		if (image == null) {
			return Container(
				height: 180,
				width: double.infinity,
				decoration: BoxDecoration(
					color: Colors.white.withValues(alpha: 0.06),
					borderRadius: BorderRadius.circular(16),
					border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
				),
				child: Center(
					child: Text(
						'No title image selected',
						style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
					),
				),
			);
		}

		return Stack(
			children: [
				ClipRRect(
					borderRadius: BorderRadius.circular(16),
					child: SizedBox(
						height: 180,
						width: double.infinity,
						child: _ImagePreview(image: image!, fit: BoxFit.cover),
					),
				),
				Positioned(
					top: 8,
					right: 8,
					child: IconButton(
						onPressed: onRemove,
						icon: const Icon(Icons.close, color: Colors.white),
						style: IconButton.styleFrom(
							backgroundColor: Colors.black.withValues(alpha: 0.5),
						),
					),
				),
			],
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
						child: _ImagePreview(image: image, fit: BoxFit.cover),
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
	final VoidCallback? onPressed;

	const _BottomActionBar({required this.label, required this.onPressed});

	@override
	Widget build(BuildContext context) {
		final isEnabled = onPressed != null;
		return Container(
			padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
			decoration: BoxDecoration(
				gradient: const LinearGradient(
					colors: [Color(0xFF171C38), Color(0xFF101428)],
				),
				border: Border(
					top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
				),
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
