import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class AddEventDraft extends ChangeNotifier {
  String title = '';
  String description = '';
  String locationAddress = '';
  String venueName = '';
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

  static List<String> _splitList(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
