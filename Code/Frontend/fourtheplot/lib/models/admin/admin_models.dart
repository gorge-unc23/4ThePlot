import 'package:fourtheplot/models/comment.dart';
import 'package:fourtheplot/models/event.dart';
import 'package:fourtheplot/models/user.dart';

Map<String, dynamic>? _map(dynamic value) {
  return value is Map<String, dynamic> ? value : null;
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  return (value as List<dynamic>? ?? const []).whereType<Map<String, dynamic>>().toList();
}

DateTime? _date(dynamic value) {
  return value == null ? null : DateTime.tryParse(value.toString());
}

int _int(dynamic value) {
  return value is int ? value : int.tryParse(value?.toString() ?? '') ?? 0;
}

String _string(dynamic value, [String fallback = '']) {
  return value?.toString() ?? fallback;
}

Map<String, dynamic> _normalizeUserJson(Map<String, dynamic> json) {
  return {
    ...json,
    'displayName': json['displayName'] ?? json['display_name'] ?? json['username'] ?? '',
    'avatarUrl': json['avatarUrl'] ?? json['avatar_url'],
    'goerPreferences': json['goerPreferences'] ?? json['goer_preferences'],
    'businessProfile': json['businessProfile'] ?? json['business_profile'],
    'hostCredibility': json['hostCredibility'] ?? json['host_credibility'],
    'createdAt': json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String(),
    'updatedAt': json['updatedAt'] ?? json['updated_at'] ?? DateTime.now().toIso8601String(),
  };
}

User? adminUserFromJson(dynamic value) {
  final json = _map(value);
  if (json == null) {
    return null;
  }
  try {
    return User.fromJson(_normalizeUserJson(json));
  } catch (_) {
    return null;
  }
}

Event? adminEventFromJson(dynamic value) {
  final json = _map(value);
  if (json == null) {
    return null;
  }
  try {
    return Event.fromJson(json);
  } catch (_) {
    return null;
  }
}

Comment? adminCommentFromJson(dynamic value) {
  final json = _map(value);
  if (json == null) {
    return null;
  }
  try {
    return Comment.fromJson(json);
  } catch (_) {
    return null;
  }
}

class AdminReportEvidence {
  final int id;
  final int reportId;
  final String evidenceType;
  final String? contentUrl;
  final String? contentText;
  final DateTime? createdAt;

  const AdminReportEvidence({
    required this.id,
    required this.reportId,
    required this.evidenceType,
    this.contentUrl,
    this.contentText,
    this.createdAt,
  });

  factory AdminReportEvidence.fromJson(Map<String, dynamic> json) {
    return AdminReportEvidence(
      id: _int(json['id']),
      reportId: _int(json['reportId'] ?? json['report_id']),
      evidenceType: _string(json['evidenceType'] ?? json['evidence_type'], 'text'),
      contentUrl: json['contentUrl'] as String? ?? json['content_url'] as String?,
      contentText: json['contentText'] as String? ?? json['content_text'] as String?,
      createdAt: _date(json['createdAt'] ?? json['created_at']),
    );
  }
}

class AdminModerationAction {
  final int id;
  final int reportId;
  final int adminId;
  final String action;
  final String reason;
  final DateTime? createdAt;

  const AdminModerationAction({
    required this.id,
    required this.reportId,
    required this.adminId,
    required this.action,
    required this.reason,
    this.createdAt,
  });

  factory AdminModerationAction.fromJson(Map<String, dynamic> json) {
    return AdminModerationAction(
      id: _int(json['id']),
      reportId: _int(json['reportId'] ?? json['report_id']),
      adminId: _int(json['adminId'] ?? json['admin_id']),
      action: _string(json['action']),
      reason: _string(json['reason']),
      createdAt: _date(json['createdAt'] ?? json['created_at']),
    );
  }
}

class AdminSafetyReport {
  final int id;
  final int? reporterUserId;
  final int? reportedUserId;
  final int? reportedEventId;
  final int? reportedCommentId;
  final String reason;
  final String severity;
  final String status;
  final bool evidenceComplete;
  final DateTime? resolvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User? reporter;
  final User? reportedUser;
  final Event? reportedEvent;
  final Comment? reportedComment;
  final List<AdminReportEvidence> evidence;
  final List<AdminModerationAction> moderationActions;

  const AdminSafetyReport({
    required this.id,
    this.reporterUserId,
    this.reportedUserId,
    this.reportedEventId,
    this.reportedCommentId,
    required this.reason,
    required this.severity,
    required this.status,
    required this.evidenceComplete,
    this.resolvedAt,
    this.createdAt,
    this.updatedAt,
    this.reporter,
    this.reportedUser,
    this.reportedEvent,
    this.reportedComment,
    required this.evidence,
    required this.moderationActions,
  });

  factory AdminSafetyReport.fromJson(Map<String, dynamic> json) {
    return AdminSafetyReport(
      id: _int(json['id']),
      reporterUserId: json['reporterUserId'] as int? ?? json['reporter_user_id'] as int?,
      reportedUserId: json['reportedUserId'] as int? ?? json['reported_user_id'] as int?,
      reportedEventId: json['reportedEventId'] as int? ?? json['reported_event_id'] as int?,
      reportedCommentId: json['reportedCommentId'] as int? ?? json['reported_comment_id'] as int?,
      reason: _string(json['reason']),
      severity: _string(json['severity'], 'medium'),
      status: _string(json['status'], 'open'),
      evidenceComplete: (json['evidenceComplete'] ?? json['evidence_complete']) == true,
      resolvedAt: _date(json['resolvedAt'] ?? json['resolved_at']),
      createdAt: _date(json['createdAt'] ?? json['created_at']),
      updatedAt: _date(json['updatedAt'] ?? json['updated_at']),
      reporter: adminUserFromJson(json['reporter']),
      reportedUser: adminUserFromJson(json['reportedUser'] ?? json['reported_user']),
      reportedEvent: adminEventFromJson(json['reportedEvent'] ?? json['reported_event']),
      reportedComment: adminCommentFromJson(
        json['reportedComment'] ?? json['reported_comment'],
      ),
      evidence: _mapList(json['evidence']).map(AdminReportEvidence.fromJson).toList(),
      moderationActions:
          _mapList(json['moderationActions'] ?? json['moderation_actions'])
              .map(AdminModerationAction.fromJson)
              .toList(),
    );
  }
}

class AdminHostVerificationDocument {
  final int id;
  final int requestId;
  final String documentType;
  final String documentUrl;
  final String status;
  final DateTime? uploadedAt;

  const AdminHostVerificationDocument({
    required this.id,
    required this.requestId,
    required this.documentType,
    required this.documentUrl,
    required this.status,
    this.uploadedAt,
  });

  factory AdminHostVerificationDocument.fromJson(Map<String, dynamic> json) {
    return AdminHostVerificationDocument(
      id: _int(json['id']),
      requestId: _int(json['requestId'] ?? json['request_id']),
      documentType: _string(json['documentType'] ?? json['document_type']),
      documentUrl: _string(json['documentUrl'] ?? json['document_url']),
      status: _string(json['status'], 'submitted'),
      uploadedAt: _date(json['uploadedAt'] ?? json['uploaded_at']),
    );
  }
}

class AdminHostVerificationRequest {
  final int id;
  final int hostUserId;
  final String status;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final int? reviewedByAdminId;
  final String? reviewReason;
  final User? host;
  final List<AdminHostVerificationDocument> documents;

  const AdminHostVerificationRequest({
    required this.id,
    required this.hostUserId,
    required this.status,
    this.submittedAt,
    this.reviewedAt,
    this.reviewedByAdminId,
    this.reviewReason,
    this.host,
    required this.documents,
  });

  factory AdminHostVerificationRequest.fromJson(Map<String, dynamic> json) {
    return AdminHostVerificationRequest(
      id: _int(json['id']),
      hostUserId: _int(json['hostUserId'] ?? json['host_user_id']),
      status: _string(json['status'], 'pending'),
      submittedAt: _date(json['submittedAt'] ?? json['submitted_at']),
      reviewedAt: _date(json['reviewedAt'] ?? json['reviewed_at']),
      reviewedByAdminId: json['reviewedByAdminId'] as int? ?? json['reviewed_by_admin_id'] as int?,
      reviewReason: json['reviewReason'] as String? ?? json['review_reason'] as String?,
      host: adminUserFromJson(json['host']),
      documents: _mapList(json['documents'])
          .map(AdminHostVerificationDocument.fromJson)
          .toList(),
    );
  }
}

class AdminGlobalNotification {
  final int id;
  final String title;
  final String message;
  final String status;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final int createdByAdminId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const AdminGlobalNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.status,
    this.startsAt,
    this.endsAt,
    required this.createdByAdminId,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminGlobalNotification.fromJson(Map<String, dynamic> json) {
    return AdminGlobalNotification(
      id: _int(json['id']),
      title: _string(json['title']),
      message: _string(json['message']),
      status: _string(json['status'], 'draft'),
      startsAt: _date(json['startsAt'] ?? json['starts_at']),
      endsAt: _date(json['endsAt'] ?? json['ends_at']),
      createdByAdminId: _int(json['createdByAdminId'] ?? json['created_by_admin_id']),
      createdAt: _date(json['createdAt'] ?? json['created_at']),
      updatedAt: _date(json['updatedAt'] ?? json['updated_at']),
    );
  }
}

class AdminMetricsOverview {
  final int totalUsers;
  final int newUsers;
  final int totalEvents;
  final int newEvents;
  final int registrations;
  final int comments;
  final int pendingReports;
  final int pendingHostVerifications;

  const AdminMetricsOverview({
    required this.totalUsers,
    required this.newUsers,
    required this.totalEvents,
    required this.newEvents,
    required this.registrations,
    required this.comments,
    required this.pendingReports,
    required this.pendingHostVerifications,
  });

  factory AdminMetricsOverview.fromJson(Map<String, dynamic> json) {
    return AdminMetricsOverview(
      totalUsers: _int(json['totalUsers'] ?? json['total_users']),
      newUsers: _int(json['newUsers'] ?? json['new_users']),
      totalEvents: _int(json['totalEvents'] ?? json['total_events']),
      newEvents: _int(json['newEvents'] ?? json['new_events']),
      registrations: _int(json['registrations']),
      comments: _int(json['comments']),
      pendingReports: _int(json['pendingReports'] ?? json['pending_reports']),
      pendingHostVerifications: _int(
        json['pendingHostVerifications'] ?? json['pending_host_verifications'],
      ),
    );
  }
}

class AdminDailyMetrics {
  final DateTime? date;
  final int newUsers;
  final int newEvents;
  final int registrations;
  final int comments;

  const AdminDailyMetrics({
    this.date,
    required this.newUsers,
    required this.newEvents,
    required this.registrations,
    required this.comments,
  });

  factory AdminDailyMetrics.fromJson(Map<String, dynamic> json) {
    return AdminDailyMetrics(
      date: _date(json['date']),
      newUsers: _int(json['newUsers'] ?? json['new_users']),
      newEvents: _int(json['newEvents'] ?? json['new_events']),
      registrations: _int(json['registrations']),
      comments: _int(json['comments']),
    );
  }
}

class AdminDisputeEvidence {
  final int id;
  final int disputeId;
  final String evidenceType;
  final String? contentUrl;
  final String? contentText;
  final bool complete;
  final DateTime? createdAt;

  const AdminDisputeEvidence({
    required this.id,
    required this.disputeId,
    required this.evidenceType,
    this.contentUrl,
    this.contentText,
    required this.complete,
    this.createdAt,
  });

  factory AdminDisputeEvidence.fromJson(Map<String, dynamic> json) {
    return AdminDisputeEvidence(
      id: _int(json['id']),
      disputeId: _int(json['disputeId'] ?? json['dispute_id']),
      evidenceType: _string(json['evidenceType'] ?? json['evidence_type'], 'text'),
      contentUrl: json['contentUrl'] as String? ?? json['content_url'] as String?,
      contentText: json['contentText'] as String? ?? json['content_text'] as String?,
      complete: (json['complete'] as bool?) ?? true,
      createdAt: _date(json['createdAt'] ?? json['created_at']),
    );
  }
}

class AdminDisputeCase {
  final int id;
  final int? eventId;
  final int? hostUserId;
  final int? goerUserId;
  final String status;
  final String? reason;
  final String? decision;
  final String? decisionReason;
  final DateTime? resolvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Event? event;
  final User? host;
  final User? goer;
  final List<AdminDisputeEvidence> evidence;

  const AdminDisputeCase({
    required this.id,
    this.eventId,
    this.hostUserId,
    this.goerUserId,
    required this.status,
    this.reason,
    this.decision,
    this.decisionReason,
    this.resolvedAt,
    this.createdAt,
    this.updatedAt,
    this.event,
    this.host,
    this.goer,
    required this.evidence,
  });

  factory AdminDisputeCase.fromJson(Map<String, dynamic> json) {
    return AdminDisputeCase(
      id: _int(json['id']),
      eventId: json['eventId'] as int? ?? json['event_id'] as int?,
      hostUserId: json['hostUserId'] as int? ?? json['host_user_id'] as int?,
      goerUserId: json['goerUserId'] as int? ?? json['goer_user_id'] as int?,
      status: _string(json['status'], 'open'),
      reason: json['reason'] as String?,
      decision: json['decision'] as String?,
      decisionReason: json['decisionReason'] as String? ?? json['decision_reason'] as String?,
      resolvedAt: _date(json['resolvedAt'] ?? json['resolved_at']),
      createdAt: _date(json['createdAt'] ?? json['created_at']),
      updatedAt: _date(json['updatedAt'] ?? json['updated_at']),
      event: adminEventFromJson(json['event']),
      host: adminUserFromJson(json['host']),
      goer: adminUserFromJson(json['goer']),
      evidence: _mapList(json['evidence']).map(AdminDisputeEvidence.fromJson).toList(),
    );
  }
}

class AdminChatLogsResponse {
  final bool complete;
  final List<AdminDisputeEvidence> evidence;

  const AdminChatLogsResponse({required this.complete, required this.evidence});

  factory AdminChatLogsResponse.fromJson(Map<String, dynamic> json) {
    return AdminChatLogsResponse(
      complete: (json['complete'] as bool?) ?? false,
      evidence: _mapList(json['evidence']).map(AdminDisputeEvidence.fromJson).toList(),
    );
  }
}

class AdminAuditLog {
  final int id;
  final int actorUserId;
  final String actorRole;
  final String action;
  final String model;
  final String modelId;
  final Map<String, dynamic> oldValues;
  final Map<String, dynamic> newValues;
  final String route;
  final String method;
  final String? ipAddress;
  final DateTime? createdAt;

  const AdminAuditLog({
    required this.id,
    required this.actorUserId,
    required this.actorRole,
    required this.action,
    required this.model,
    required this.modelId,
    required this.oldValues,
    required this.newValues,
    required this.route,
    required this.method,
    this.ipAddress,
    this.createdAt,
  });

  factory AdminAuditLog.fromJson(Map<String, dynamic> json) {
    return AdminAuditLog(
      id: _int(json['id']),
      actorUserId: _int(json['actorUserId'] ?? json['actor_user_id']),
      actorRole: _string(json['actorRole'] ?? json['actor_role']),
      action: _string(json['action']),
      model: _string(json['model']),
      modelId: _string(json['modelId'] ?? json['model_id']),
      oldValues: _map(json['oldValues'] ?? json['old_values']) ?? const {},
      newValues: _map(json['newValues'] ?? json['new_values']) ?? const {},
      route: _string(json['route']),
      method: _string(json['method']),
      ipAddress: json['ipAddress'] as String? ?? json['ip_address'] as String?,
      createdAt: _date(json['createdAt'] ?? json['created_at']),
    );
  }
}

class AdminAuditLogPage {
  final int total;
  final int page;
  final int pageSize;
  final List<AdminAuditLog> items;

  const AdminAuditLogPage({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.items,
  });

  factory AdminAuditLogPage.fromJson(Map<String, dynamic> json) {
    return AdminAuditLogPage(
      total: _int(json['total']),
      page: _int(json['page']),
      pageSize: _int(json['pageSize'] ?? json['page_size']),
      items: _mapList(json['items']).map(AdminAuditLog.fromJson).toList(),
    );
  }
}
