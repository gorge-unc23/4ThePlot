enum UserRole {
    goer,
    business,
    admin,
}

UserRole userRoleFromString(String value) {
    switch (value) {
        case 'goer':
            return UserRole.goer;
        case 'business':
            return UserRole.business;
        case 'admin':
            return UserRole.admin;
        default:
            return UserRole.goer;
    }
}

String userRoleToString(UserRole role) {
    switch (role) {
        case UserRole.goer:
            return 'goer';
        case UserRole.business:
            return 'business';
        case UserRole.admin:
            return 'admin';
    }
}

enum UserStatus {
    active,
    suspended,
    closed,
}

UserStatus userStatusFromString(String value) {
    switch (value) {
        case 'active':
            return UserStatus.active;
        case 'suspended':
            return UserStatus.suspended;
        case 'closed':
            return UserStatus.closed;
        default:
            return UserStatus.active;
    }
}

String userStatusToString(UserStatus status) {
    switch (status) {
        case UserStatus.active:
            return 'active';
        case UserStatus.suspended:
            return 'suspended';
        case UserStatus.closed:
            return 'closed';
    }
}

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
            logoUrl: json['logoUrl'] as String?,
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

class User {
    final String id;
    final String displayName;
    final String email;
    final String? phone;
    final String? avatarUrl;
    final List<UserRole> roles;
    final UserStatus status;
    final GoerPreferences? goerPreferences;
    final BusinessProfileSummary? businessProfile;
    final HostCredibilitySummary? hostCredibility;
    final DateTime createdAt;
    final DateTime updatedAt;

    const User({
        required this.id,
        required this.displayName,
        required this.email,
        this.phone,
        this.avatarUrl,
        required this.roles,
        required this.status,
        this.goerPreferences,
        this.businessProfile,
        this.hostCredibility,
        required this.createdAt,
        required this.updatedAt,
    });

    User copyWith({
        String? id,
        String? displayName,
        String? email,
        String? phone,
        String? avatarUrl,
        List<UserRole>? roles,
        UserStatus? status,
        GoerPreferences? goerPreferences,
        BusinessProfileSummary? businessProfile,
        HostCredibilitySummary? hostCredibility,
        DateTime? createdAt,
        DateTime? updatedAt,
    }) {
        return User(
            id: id ?? this.id,
            displayName: displayName ?? this.displayName,
            email: email ?? this.email,
            phone: phone ?? this.phone,
            avatarUrl: avatarUrl ?? this.avatarUrl,
            roles: roles ?? this.roles,
            status: status ?? this.status,
            goerPreferences: goerPreferences ?? this.goerPreferences,
            businessProfile: businessProfile ?? this.businessProfile,
            hostCredibility: hostCredibility ?? this.hostCredibility,
            createdAt: createdAt ?? this.createdAt,
            updatedAt: updatedAt ?? this.updatedAt,
        );
    }

    factory User.fromJson(Map<String, dynamic> json) {
        return User(
            id: (json['id'] as String?) ?? '',
            displayName: (json['displayName'] as String?) ?? '',
            email: (json['email'] as String?) ?? '',
            phone: json['phone'] as String?,
            avatarUrl: json['avatarUrl'] as String?,
            roles: (json['roles'] as List<dynamic>?)
                            ?.map((e) => userRoleFromString(e as String))
                            .toList() ??
                    const [],
            status: userStatusFromString((json['status'] as String?) ?? 'active'),
            goerPreferences: json['goerPreferences'] != null
                    ? GoerPreferences.fromJson(
                            json['goerPreferences'] as Map<String, dynamic>,
                    )
                    : null,
            businessProfile: json['businessProfile'] != null
                    ? BusinessProfileSummary.fromJson(
                            json['businessProfile'] as Map<String, dynamic>,
                    )
                    : null,
            hostCredibility: json['hostCredibility'] != null
                    ? HostCredibilitySummary.fromJson(
                            json['hostCredibility'] as Map<String, dynamic>,
                    )
                    : null,
            createdAt: DateTime.parse(json['createdAt'] as String),
            updatedAt: DateTime.parse(json['updatedAt'] as String),
        );
    }

    Map<String, dynamic> toJson() {
        return {
            'id': id,
            'displayName': displayName,
            'email': email,
            'phone': phone,
            'avatarUrl': avatarUrl,
            'roles': roles.map(userRoleToString).toList(),
            'status': userStatusToString(status),
            'goerPreferences': goerPreferences?.toJson(),
            'businessProfile': businessProfile?.toJson(),
            'hostCredibility': hostCredibility?.toJson(),
            'createdAt': createdAt.toIso8601String(),
            'updatedAt': updatedAt.toIso8601String(),
        };
    }
}