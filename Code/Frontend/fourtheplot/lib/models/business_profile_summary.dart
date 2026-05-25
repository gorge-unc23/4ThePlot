import 'package:fourtheplot/services/photo_url_service.dart';

class BusinessProfileSummary {
    final String name;
    final String? description;
    final String? websiteUrl;
    final String? logoUrl;
    final bool isPublished;

    const BusinessProfileSummary({
        required this.name,
        this.description,
        this.websiteUrl,
        this.logoUrl,
        required this.isPublished,
    });

    factory BusinessProfileSummary.fromJson(Map<String, dynamic> json) {
        return BusinessProfileSummary(
            name: (json['name'] as String?) ?? '',
            description: json['description'] as String?,
            websiteUrl: json['websiteUrl'] as String?,
            logoUrl: PhotoUrlService.normalizePhotoUrl(json['logoUrl'] as String?),
            isPublished: (json['isPublished'] as bool?) ?? false,
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'name': name,
            'description': description,
            'websiteUrl': websiteUrl,
            'logoUrl': logoUrl,
            'isPublished': isPublished,
        };
    }
}
