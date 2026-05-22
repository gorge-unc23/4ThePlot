import 'package:flutter/foundation.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:image_picker/image_picker.dart';

class EditEventDraft extends ChangeNotifier {
  final Event originalEvent;

  late String title;
  late String description;
  late String locationAddress;
  late String venueName;
  late String city;
  late double? latitude;
  late double? longitude;
  late DateTime? startAt;
  late DateTime? endAt;
  late bool isPaid;
  late double price;
  late String currency;
  late List<String> categories;
  late List<String> tags;
  late int? capacityMax;
  late String coverImageUrl;
  XFile? replacementCoverImage;
  final List<XFile> galleryImages = [];

  EditEventDraft.fromEvent(this.originalEvent) {
    title = originalEvent.title;
    description = originalEvent.description;
    locationAddress = originalEvent.location.address;
    venueName = originalEvent.location.venueName ?? '';
    city = originalEvent.location.city ?? '';
    latitude = originalEvent.location.latitude;
    longitude = originalEvent.location.longitude;
    startAt = originalEvent.startAt;
    endAt = originalEvent.endAt;
    isPaid = originalEvent.price > 0;
    price = originalEvent.price;
    currency = originalEvent.currency;
    categories = List<String>.from(originalEvent.categories);
    tags = List<String>.from(originalEvent.tags);
    capacityMax = originalEvent.capacity.maxAttendees;
    coverImageUrl = originalEvent.coverImageUrl;
  }

  bool get isFree => !isPaid || price <= 0;
  bool get hasReplacementCover => replacementCoverImage != null;

  bool get hasRequiredDetails {
    return title.isNotEmpty &&
        description.isNotEmpty &&
        locationAddress.isNotEmpty &&
        city.isNotEmpty &&
        startAt != null &&
        endAt != null &&
        (!isPaid || price > 0);
  }

  void setTitle(String value) {
    title = value.trim();
    notifyListeners();
  }

  void setDescription(String value) {
    description = value.trim();
    notifyListeners();
  }

  void setLocationAddress(String value) {
    locationAddress = value.trim();
    notifyListeners();
  }

  void setVenueName(String value) {
    venueName = value.trim();
    notifyListeners();
  }

  void setCity(String value) {
    city = value.trim();
    notifyListeners();
  }

  void setLocationCoordinates({required double latitude, required double longitude}) {
    this.latitude = latitude;
    this.longitude = longitude;
    notifyListeners();
  }

  void clearLocationCoordinates() {
    latitude = null;
    longitude = null;
    notifyListeners();
  }

  void setStartAt(DateTime value) {
    startAt = value;
    notifyListeners();
  }

  void setEndAt(DateTime value) {
    endAt = value;
    notifyListeners();
  }

  void setIsPaid(bool value) {
    isPaid = value;
    if (!isPaid) {
      price = 0.0;
    }
    notifyListeners();
  }

  void setPrice(double value) {
    price = value;
    notifyListeners();
  }

  void setCategoriesFromText(String value) {
    categories = _splitList(value);
    notifyListeners();
  }

  void setTagsFromText(String value) {
    tags = _splitList(value);
    notifyListeners();
  }

  void setCapacityMax(int? value) {
    capacityMax = value;
    notifyListeners();
  }

  void setReplacementCoverImage(XFile? file) {
    replacementCoverImage = file;
    notifyListeners();
  }

  void addGalleryImages(List<XFile> files) {
    galleryImages.addAll(files);
    notifyListeners();
  }

  void removeGalleryImageAt(int index) {
    if (index < 0 || index >= galleryImages.length) return;
    galleryImages.removeAt(index);
    notifyListeners();
  }

  String categoriesText() => categories.join(', ');
  String tagsText() => tags.join(', ');

  Map<String, dynamic> toUpdatePayload({required String coverImageUrl}) {
    return {
      'title': title,
      'description': description,
      'hostId': int.tryParse(originalEvent.hostId) ?? originalEvent.hostId,
      'status': eventStatusToString(originalEvent.status),
      'startAt': startAt!.toIso8601String(),
      'endAt': endAt!.toIso8601String(),
      'location': {
        'address': locationAddress,
        'venueName': venueName.isEmpty ? null : venueName,
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
      },
      'capacity': {
        'maxAttendees': capacityMax,
        'confirmedAttendees': originalEvent.capacity.confirmedAttendees,
        'waitlistEnabled': originalEvent.capacity.waitlistEnabled,
      },
      'categories': categories,
      'tags': tags,
      'price': isFree ? 0.0 : price,
      'currency': currency,
      'coverImageUrl': coverImageUrl,
      'trending': originalEvent.trending,
    };
  }

  static List<String> _splitList(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
