from datetime import date, datetime
from typing import List, Optional
from pydantic import BaseModel, ConfigDict, Field, field_validator
from schemas.user import UserShow
from schemas.event import ShowEvent
from schemas.comments import ShowComment


def to_camel(value: str) -> str:
    parts = value.split('_')
    return parts[0] + ''.join(word.capitalize() for word in parts[1:])


class CamelModel(BaseModel):
    model_config = ConfigDict(
        validate_by_name=True,
        alias_generator=to_camel,
        from_attributes=True,
    )


class AdminAuditLogShow(CamelModel):
    id: int
    admin_id: int
    action: str
    target_type: Optional[str] = None
    target_id: Optional[int] = None
    reason: str
    created_at: datetime


class ReportEvidenceShow(CamelModel):
    id: int
    report_id: int
    evidence_type: str
    content_url: Optional[str] = None
    content_text: Optional[str] = None
    created_at: datetime


class ModerationActionCreate(CamelModel):
    action: str
    reason: str


class ModerationActionShow(CamelModel):
    id: int
    report_id: int
    admin_id: int
    action: str
    reason: str
    created_at: datetime


class SafetyReportStatusUpdate(CamelModel):
    status: str
    reason: str


class SafetyReportShow(CamelModel):
    id: int
    reporter_user_id: Optional[int] = None
    reported_user_id: Optional[int] = None
    reported_event_id: Optional[int] = None
    reported_comment_id: Optional[int] = None
    reason: str
    severity: str
    status: str
    evidence_complete: bool
    resolved_at: Optional[datetime] = None
    created_at: datetime
    updated_at: Optional[datetime] = None
    reporter: Optional[UserShow] = None
    reported_user: Optional[UserShow] = None
    reported_event: Optional[ShowEvent] = None
    reported_comment: Optional[ShowComment] = None
    evidence: List[ReportEvidenceShow] = Field(default_factory=list)
    moderation_actions: List[ModerationActionShow] = Field(default_factory=list)


class HostVerificationDocumentCreate(CamelModel):
    document_type: str
    document_url: str
    reason: str
    status: str = 'submitted'


class HostVerificationDocumentShow(CamelModel):
    id: int
    request_id: int
    document_type: str
    document_url: str
    status: str
    uploaded_at: datetime


class HostVerificationReview(CamelModel):
    status: str
    reason: str


class HostVerificationRequestShow(CamelModel):
    id: int
    host_user_id: int
    status: str
    submitted_at: datetime
    reviewed_at: Optional[datetime] = None
    reviewed_by_admin_id: Optional[int] = None
    review_reason: Optional[str] = None
    host: Optional[UserShow] = None
    documents: List[HostVerificationDocumentShow] = Field(default_factory=list)


class GlobalNotificationCreate(CamelModel):
    title: str
    message: str
    status: str = 'published'
    starts_at: Optional[datetime] = None
    ends_at: Optional[datetime] = None
    reason: str

    @field_validator('ends_at')
    def validate_end_after_start(cls, value, info):
        starts_at = info.data.get('starts_at')
        if value and starts_at and value <= starts_at:
            raise ValueError('endsAt must be after startsAt')
        return value


class GlobalNotificationUpdate(CamelModel):
    title: Optional[str] = None
    message: Optional[str] = None
    status: Optional[str] = None
    starts_at: Optional[datetime] = None
    ends_at: Optional[datetime] = None
    reason: str


class GlobalNotificationShow(CamelModel):
    id: int
    title: str
    message: str
    status: str
    starts_at: Optional[datetime] = None
    ends_at: Optional[datetime] = None
    created_by_admin_id: int
    created_at: datetime
    updated_at: Optional[datetime] = None


class MetricsOverview(CamelModel):
    total_users: int
    new_users: int
    total_events: int
    new_events: int
    registrations: int
    comments: int
    pending_reports: int
    pending_host_verifications: int
    provisional: bool = True


class DailyMetrics(CamelModel):
    date: date
    new_users: int = 0
    new_events: int = 0
    registrations: int = 0
    comments: int = 0


class DailyMetricsResponse(CamelModel):
    provisional: bool = True
    days: List[DailyMetrics]


class DisputeEvidenceShow(CamelModel):
    id: int
    dispute_id: int
    evidence_type: str
    content_url: Optional[str] = None
    content_text: Optional[str] = None
    complete: bool
    created_at: datetime


class DisputeDecisionUpdate(CamelModel):
    decision: str
    status: str = 'resolved'
    reason: str


class DisputeCaseShow(CamelModel):
    id: int
    event_id: Optional[int] = None
    host_user_id: Optional[int] = None
    goer_user_id: Optional[int] = None
    status: str
    reason: Optional[str] = None
    decision: Optional[str] = None
    decision_reason: Optional[str] = None
    resolved_at: Optional[datetime] = None
    created_at: datetime
    updated_at: Optional[datetime] = None
    event: Optional[ShowEvent] = None
    host: Optional[UserShow] = None
    goer: Optional[UserShow] = None
    evidence: List[DisputeEvidenceShow] = Field(default_factory=list)


class ChatLogsResponse(CamelModel):
    complete: bool
    evidence: List[DisputeEvidenceShow]
