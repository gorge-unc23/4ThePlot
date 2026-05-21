import 'package:fourtheplot/models/business_profile_summary.dart';
import 'package:fourtheplot/models/goer_preferences.dart';
import 'package:fourtheplot/models/host_credibility_summary.dart';

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

class User {
    final int id;
    final String displayName;
    final String email;
    final String? phone;
    final String? avatarUrl;
    final UserRole role;
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
        required this.role,
        required this.status,
        this.goerPreferences,
        this.businessProfile,
        this.hostCredibility,
        required this.createdAt,
        required this.updatedAt,
    });

    User copyWith({
        int? id,
        String? displayName,
        String? email,
        String? phone,
        String? avatarUrl,
        UserRole? role,
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
            role: role ?? this.role,
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
            id: json['id'],
            displayName: (json['displayName'] as String?) ?? '',
            email: (json['email'] as String?) ?? '',
            phone: json['phone'] as String?,
            avatarUrl: json['avatarUrl'] as String?,
            role: userRoleFromString(json['role'] as String),
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
            'role': userRoleToString(role),
            'status': userStatusToString(status),
            'goerPreferences': goerPreferences?.toJson(),
            'businessProfile': businessProfile?.toJson(),
            'hostCredibility': hostCredibility?.toJson(),
            'createdAt': createdAt.toIso8601String(),
            'updatedAt': updatedAt.toIso8601String(),
        };
    }
}