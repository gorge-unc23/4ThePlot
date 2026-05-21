class GoerPreferences {
    final List<String> categories;
    final DateTime updatedAt;

    const GoerPreferences({
        required this.categories,
        required this.updatedAt,
    });

    factory GoerPreferences.fromJson(Map<String, dynamic> json) {
        return GoerPreferences(
            categories: (json['categories'] as List<dynamic>?)
                    ?.map((e) => e as String)
                    .toList() ??
                    const [],
            updatedAt: DateTime.parse(json['updatedAt'] as String),
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'categories': categories,
            'updatedAt': updatedAt.toIso8601String(),
        };
    }
}