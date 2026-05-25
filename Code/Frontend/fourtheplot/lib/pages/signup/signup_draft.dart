import 'package:fourtheplot/models/user.dart';
import 'package:image_picker/image_picker.dart';

class SignupDraft {
  UserRole role = UserRole.goer;
  String displayName = '';
  String email = '';
  String phone = '';
  String password = '';
  String confirmPassword = '';
  XFile? avatarImage;
  XFile? businessLogoImage;
  String categoriesText = '';
  String businessName = '';
  String businessDescription = '';
  String businessWebsite = '';

  bool get isBusiness => role == UserRole.business;

  List<String> get categories => categoriesText
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();

  String get username {
    final localPart = email.split('@').first.trim();
    if (localPart.isNotEmpty) {
      return localPart;
    }
    return displayName.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }

  Map<String, dynamic> toPayload({
    required String avatarUrl,
    String? businessLogoUrl,
  }) {
    final payload = <String, dynamic>{
      'username': username,
      'display_name': displayName.trim(),
      'email': email.trim(),
      'password': password,
      'phone': phone.trim().isEmpty ? null : phone.trim(),
      'avatar_url': avatarUrl,
      'role': userRoleToString(role),
      'status': 'active',
      'host_credibility': {
        'rating': 0,
        'review_count': 0,
        'trusted': false,
      },
    };

    if (role == UserRole.goer) {
      payload['goer_preferences'] = {'categories': categories};
    } else {
      payload['business_profile'] = {
        'name': businessName.trim(),
        'description': businessDescription.trim(),
        'website_url':
            businessWebsite.trim().isEmpty ? null : businessWebsite.trim(),
        'logo_url': businessLogoUrl,
        'is_published': true,
      };
    }

    return payload;
  }
}
