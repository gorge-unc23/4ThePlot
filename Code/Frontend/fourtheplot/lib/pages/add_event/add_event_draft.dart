import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class AddEventDraft extends ChangeNotifier {
  String title = '';
  String description = '';
  String locationAddress = '';
  String venueName = '';
  String city = '';
  double? latitude;
  double? longitude;
  DateTime? startAt;
  DateTime? endAt;
  bool isPaid = false;
  double price = 0.0;
  String currency = 'EUR';
  List<String> categories = [];
  List<String> tags = [];
  int? capacityMax;
  XFile? coverImage;
  final List<XFile> galleryImages = [];

  bool get isFree => !isPaid || price <= 0;

  bool get hasRequiredDetails {
    return title.isNotEmpty &&
        description.isNotEmpty &&
        locationAddress.isNotEmpty &&
        city.isNotEmpty &&
        startAt != null &&
        endAt != null &&
        (!isPaid || price > 0);
  }

  bool get hasTitleImage => coverImage != null;

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

  void setCurrency(String value) {
    currency = value;
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

  void setCoverImage(XFile? file) {
    coverImage = file;
    notifyListeners();
  }

  void addGalleryImages(List<XFile> files) {
    galleryImages.addAll(files);
    notifyListeners();
  }

  void removeGalleryImageAt(int index) {
    if (index < 0 || index >= galleryImages.length) {
      return;
    }
    galleryImages.removeAt(index);
    notifyListeners();
  }

  void reset() {
    title = '';
    description = '';
    locationAddress = '';
    venueName = '';
    city = '';
    latitude = null;
    longitude = null;
    startAt = null;
    endAt = null;
    isPaid = false;
    price = 0.0;
    currency = 'EUR';
    categories = [];
    tags = [];
    capacityMax = null;
    coverImage = null;
    galleryImages.clear();
    notifyListeners();
  }

  String categoriesText() => categories.join(', ');
  String tagsText() => tags.join(', ');

  Map<String, dynamic> toCreatePayload({
    required int hostId,
    required String coverImageUrl,
  }) {
    return {
      'title': title,
      'description': description,
      'hostId': hostId,
      'status': 'published',
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
        'confirmedAttendees': 0,
        'waitlistEnabled': false,
      },
      'categories': categories,
      'tags': tags,
      'price': isFree ? 0.0 : price,
      'currency': currency,
      'coverImageUrl': coverImageUrl,
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
