class HostCredibilitySummary {
    final double? rating;
    final int? reviewCount;
    final bool? trusted;

    const HostCredibilitySummary({
        this.rating,
        this.reviewCount,
        this.trusted,
    });

    factory HostCredibilitySummary.fromJson(Map<String, dynamic> json) {
        return HostCredibilitySummary(
            rating: (json['rating'] as num?)?.toDouble(),
            reviewCount: json['reviewCount'] as int?,
            trusted: json['trusted'] as bool?,
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'rating': rating,
            'reviewCount': reviewCount,
            'trusted': trusted,
        };
    }
}