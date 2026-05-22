from datetime import date, datetime, time, timedelta
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func
from sqlalchemy.orm import Session, joinedload
from database import get_db
from authentication.oauth2 import get_current_admin_user
from models.admin import (
    AdminAuditLog,
    DisputeCase,
    DisputeEvidence,
    GlobalNotification,
    HostVerificationDocument,
    HostVerificationRequest,
    ModerationAction,
    SafetyReport,
)
from models.comments import Comment
from models.event import Event
from models.event_capacity import EventCapacity
from models.host_credibility import HostCredibility
from models.registration import Registration
from models.recurrence import RecurrenceRule
from models.user import User
from schemas.admin import (
    AdminAuditLogShow,
    ChatLogsResponse,
    DailyMetrics,
    DailyMetricsResponse,
    DisputeCaseShow,
    DisputeDecisionUpdate,
    GlobalNotificationCreate,
    GlobalNotificationShow,
    GlobalNotificationUpdate,
    HostVerificationDocumentCreate,
    HostVerificationDocumentShow,
    HostVerificationRequestShow,
    HostVerificationReview,
    MetricsOverview,
    ModerationActionCreate,
    ModerationActionShow,
    SafetyReportShow,
    SafetyReportStatusUpdate,
)
from schemas.user import UserShow


router = APIRouter(
    prefix='/admin',
    tags=['Admin']
)

VALID_MODERATION_ACTIONS = {
    'warn_user',
    'suspend_user',
    'deactivate_event',
    'delete_comment',
    'dismiss_report',
}
HOST_VERIFICATION_STATUSES = {
    'pending',
    'pending_documents',
    'approved',
    'rejected',
    'suspected_fraud',
}
DISPUTE_STATUSES = {
    'open',
    'needs_evidence',
    'escalated',
    'resolved',
    'pending_communication',
}


def event_load_options():
    return (
        joinedload(Event.location),
        joinedload(Event.capacity),
        joinedload(Event.recurrence).joinedload(RecurrenceRule.weekdays),
        joinedload(Event.category_links),
        joinedload(Event.tag_links),
    )


def user_load_options():
    return (
        joinedload(User.goer_preferences),
        joinedload(User.business_profile),
        joinedload(User.host_credibility),
    )


def report_load_options():
    return (
        joinedload(SafetyReport.reporter).options(*user_load_options()),
        joinedload(SafetyReport.reported_user).options(*user_load_options()),
        joinedload(SafetyReport.reported_event).options(*event_load_options()),
        joinedload(SafetyReport.reported_comment).joinedload(Comment.author).options(*user_load_options()),
        joinedload(SafetyReport.reported_comment).joinedload(Comment.event).options(*event_load_options()),
        joinedload(SafetyReport.evidence),
        joinedload(SafetyReport.moderation_actions),
    )


def host_verification_load_options():
    return (
        joinedload(HostVerificationRequest.host).options(*user_load_options()),
        joinedload(HostVerificationRequest.documents),
    )


def dispute_load_options():
    return (
        joinedload(DisputeCase.event).options(*event_load_options()),
        joinedload(DisputeCase.host).options(*user_load_options()),
        joinedload(DisputeCase.goer).options(*user_load_options()),
        joinedload(DisputeCase.evidence),
    )


def write_audit_log(
    db: Session,
    admin: User,
    action: str,
    reason: str,
    target_type: str | None = None,
    target_id: int | None = None,
):
    db.add(AdminAuditLog(
        admin_id=admin.id,
        action=action,
        target_type=target_type,
        target_id=target_id,
        reason=reason,
    ))


def date_range_bounds(start_date: date | None, end_date: date | None):
    end = end_date or date.today()
    start = start_date or (end - timedelta(days=30))
    if start > end:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='startDate must be before endDate')
    if (end - start).days > 366:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Date range cannot exceed 366 days')
    return (
        datetime.combine(start, time.min),
        datetime.combine(end, time.max),
        start,
        end,
    )


@router.get('/reports', response_model=list[SafetyReportShow])
def get_reports(
    status_filter: str | None = Query(default=None, alias='status'),
    severity: str | None = None,
    db: Session = Depends(get_db),
    current_admin: UserShow = Depends(get_current_admin_user),
):
    query = db.query(SafetyReport).options(*report_load_options())
    if status_filter:
        query = query.filter(SafetyReport.status == status_filter)
    if severity:
        query = query.filter(SafetyReport.severity == severity)
    return query.order_by(SafetyReport.created_at.desc()).all()


@router.get('/reports/{report_id}', response_model=SafetyReportShow)
def get_report(report_id: int, db: Session = Depends(get_db), current_admin: UserShow = Depends(get_current_admin_user)):
    report = db.query(SafetyReport).options(*report_load_options()).filter(SafetyReport.id == report_id).first()
    if not report:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Report with id:{report_id} does not exist')
    return report


@router.post('/reports/{report_id}/moderation-actions', status_code=status.HTTP_201_CREATED, response_model=ModerationActionShow)
def apply_moderation_action(
    report_id: int,
    request: ModerationActionCreate,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user),
):
    if request.action not in VALID_MODERATION_ACTIONS:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Unsupported moderation action')

    report = db.query(SafetyReport).filter(SafetyReport.id == report_id).first()
    if not report:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Report with id:{report_id} does not exist')

    if request.action == 'suspend_user':
        if not report.reported_user_id:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Report has no reported user')
        user = db.query(User).filter(User.id == report.reported_user_id).first()
        if not user:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Reported user does not exist')
        user.status = 'suspended'
        user.is_active = False
    elif request.action == 'deactivate_event':
        if not report.reported_event_id:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Report has no reported event')
        event = db.query(Event).filter(Event.id == report.reported_event_id).first()
        if not event:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Reported event does not exist')
        event.status = 'inactive'
    elif request.action == 'delete_comment':
        if not report.reported_comment_id:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Report has no reported comment')
        comment = db.query(Comment).filter(Comment.id == report.reported_comment_id).first()
        if not comment:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Reported comment does not exist')
        db.delete(comment)

    moderation_action = ModerationAction(
        report_id=report.id,
        admin_id=current_admin.id,
        action=request.action,
        reason=request.reason,
    )
    report.status = 'resolved'
    report.resolved_at = datetime.utcnow()
    db.add(moderation_action)
    write_audit_log(db, current_admin, request.action, request.reason, 'safety_report', report.id)
    db.commit()
    db.refresh(moderation_action)
    return moderation_action


@router.patch('/reports/{report_id}/status', response_model=SafetyReportShow)
def update_report_status(
    report_id: int,
    request: SafetyReportStatusUpdate,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user),
):
    report = db.query(SafetyReport).filter(SafetyReport.id == report_id).first()
    if not report:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Report with id:{report_id} does not exist')

    report.status = request.status
    if request.status == 'resolved':
        report.resolved_at = datetime.utcnow()
    write_audit_log(db, current_admin, 'update_report_status', request.reason, 'safety_report', report.id)
    db.commit()
    return db.query(SafetyReport).options(*report_load_options()).filter(SafetyReport.id == report_id).first()


@router.get('/host-verifications', response_model=list[HostVerificationRequestShow])
def get_host_verifications(
    status_filter: str | None = Query(default=None, alias='status'),
    db: Session = Depends(get_db),
    current_admin: UserShow = Depends(get_current_admin_user),
):
    query = db.query(HostVerificationRequest).options(*host_verification_load_options())
    if status_filter:
        query = query.filter(HostVerificationRequest.status == status_filter)
    return query.order_by(HostVerificationRequest.submitted_at.desc()).all()


@router.get('/host-verifications/{request_id}', response_model=HostVerificationRequestShow)
def get_host_verification(request_id: int, db: Session = Depends(get_db), current_admin: UserShow = Depends(get_current_admin_user)):
    verification = (
        db.query(HostVerificationRequest)
        .options(*host_verification_load_options())
        .filter(HostVerificationRequest.id == request_id)
        .first()
    )
    if not verification:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Host verification with id:{request_id} does not exist')
    return verification


@router.post('/host-verifications/{request_id}/documents', status_code=status.HTTP_201_CREATED, response_model=HostVerificationDocumentShow)
def add_host_verification_document(
    request_id: int,
    request: HostVerificationDocumentCreate,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user),
):
    verification = db.query(HostVerificationRequest).filter(HostVerificationRequest.id == request_id).first()
    if not verification:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Host verification with id:{request_id} does not exist')

    document = HostVerificationDocument(
        request_id=request_id,
        document_type=request.document_type,
        document_url=request.document_url,
        status=request.status,
    )
    db.add(document)
    write_audit_log(db, current_admin, 'add_host_verification_document', request.reason, 'host_verification_request', request_id)
    db.commit()
    db.refresh(document)
    return document


@router.patch('/host-verifications/{request_id}/review', response_model=HostVerificationRequestShow)
def review_host_verification(
    request_id: int,
    request: HostVerificationReview,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user),
):
    if request.status not in HOST_VERIFICATION_STATUSES:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Unsupported host verification status')

    verification = db.query(HostVerificationRequest).filter(HostVerificationRequest.id == request_id).first()
    if not verification:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Host verification with id:{request_id} does not exist')

    credibility = db.query(HostCredibility).filter(HostCredibility.user_id == verification.host_user_id).first()
    if credibility is None:
        credibility = HostCredibility(user_id=verification.host_user_id, review_count=0)
        db.add(credibility)

    verification.status = request.status
    verification.reviewed_at = datetime.utcnow()
    verification.reviewed_by_admin_id = current_admin.id
    verification.review_reason = request.reason
    if request.status == 'approved':
        credibility.trusted = True
    elif request.status in {'rejected', 'suspected_fraud'}:
        credibility.trusted = False

    write_audit_log(db, current_admin, 'review_host_verification', request.reason, 'host_verification_request', request_id)
    db.commit()
    return (
        db.query(HostVerificationRequest)
        .options(*host_verification_load_options())
        .filter(HostVerificationRequest.id == request_id)
        .first()
    )


@router.post('/notifications', status_code=status.HTTP_201_CREATED, response_model=GlobalNotificationShow)
def create_notification(
    request: GlobalNotificationCreate,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user),
):
    notification = GlobalNotification(
        title=request.title,
        message=request.message,
        status=request.status,
        starts_at=request.starts_at,
        ends_at=request.ends_at,
        created_by_admin_id=current_admin.id,
    )
    db.add(notification)
    write_audit_log(db, current_admin, 'create_global_notification', request.reason, 'global_notification')
    db.commit()
    db.refresh(notification)
    return notification


@router.get('/notifications', response_model=list[GlobalNotificationShow])
def get_notifications(db: Session = Depends(get_db), current_admin: UserShow = Depends(get_current_admin_user)):
    return db.query(GlobalNotification).order_by(GlobalNotification.created_at.desc()).all()


@router.patch('/notifications/{notification_id}', response_model=GlobalNotificationShow)
def update_notification(
    notification_id: int,
    request: GlobalNotificationUpdate,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user),
):
    notification = db.query(GlobalNotification).filter(GlobalNotification.id == notification_id).first()
    if not notification:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Notification with id:{notification_id} does not exist')

    update_data = request.model_dump(exclude_unset=True)
    reason = update_data.pop('reason')
    starts_at = update_data.get('starts_at', notification.starts_at)
    ends_at = update_data.get('ends_at', notification.ends_at)
    if starts_at and ends_at and ends_at <= starts_at:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='endsAt must be after startsAt')

    for key, value in update_data.items():
        setattr(notification, key, value)
    write_audit_log(db, current_admin, 'update_global_notification', reason, 'global_notification', notification.id)
    db.commit()
    db.refresh(notification)
    return notification


@router.get('/metrics/overview', response_model=MetricsOverview)
def get_metrics_overview(
    start_date: date | None = Query(default=None, alias='startDate'),
    end_date: date | None = Query(default=None, alias='endDate'),
    db: Session = Depends(get_db),
    current_admin: UserShow = Depends(get_current_admin_user),
):
    start_dt, end_dt, _, _ = date_range_bounds(start_date, end_date)
    return MetricsOverview(
        total_users=db.query(User).count(),
        new_users=db.query(User).filter(User.created_at >= start_dt, User.created_at <= end_dt).count(),
        total_events=db.query(Event).count(),
        new_events=db.query(Event).filter(Event.created_at >= start_dt, Event.created_at <= end_dt).count(),
        registrations=db.query(Registration).filter(Registration.registered_at >= start_dt, Registration.registered_at <= end_dt).count(),
        comments=db.query(Comment).filter(Comment.created_at >= start_dt, Comment.created_at <= end_dt).count(),
        pending_reports=db.query(SafetyReport).filter(SafetyReport.status != 'resolved').count(),
        pending_host_verifications=db.query(HostVerificationRequest).filter(HostVerificationRequest.status.in_(['pending', 'pending_documents'])).count(),
    )


@router.get('/metrics/daily', response_model=DailyMetricsResponse)
def get_daily_metrics(
    start_date: date | None = Query(default=None, alias='startDate'),
    end_date: date | None = Query(default=None, alias='endDate'),
    db: Session = Depends(get_db),
    current_admin: UserShow = Depends(get_current_admin_user),
):
    start_dt, end_dt, start_day, end_day = date_range_bounds(start_date, end_date)
    days = {}
    current_day = start_day
    while current_day <= end_day:
        days[current_day.isoformat()] = DailyMetrics(date=current_day)
        current_day += timedelta(days=1)

    metric_queries = [
        ('new_users', User, User.created_at),
        ('new_events', Event, Event.created_at),
        ('registrations', Registration, Registration.registered_at),
        ('comments', Comment, Comment.created_at),
    ]
    for field_name, model, column in metric_queries:
        rows = (
            db.query(func.date(column), func.count(model.id))
            .filter(column >= start_dt, column <= end_dt)
            .group_by(func.date(column))
            .all()
        )
        for day_text, count in rows:
            if day_text in days:
                setattr(days[day_text], field_name, count)

    return DailyMetricsResponse(days=list(days.values()))


@router.get('/disputes', response_model=list[DisputeCaseShow])
def get_disputes(
    status_filter: str | None = Query(default=None, alias='status'),
    db: Session = Depends(get_db),
    current_admin: UserShow = Depends(get_current_admin_user),
):
    query = db.query(DisputeCase).options(*dispute_load_options())
    if status_filter:
        query = query.filter(DisputeCase.status == status_filter)
    return query.order_by(DisputeCase.created_at.desc()).all()


@router.get('/disputes/{dispute_id}', response_model=DisputeCaseShow)
def get_dispute(dispute_id: int, db: Session = Depends(get_db), current_admin: UserShow = Depends(get_current_admin_user)):
    dispute = db.query(DisputeCase).options(*dispute_load_options()).filter(DisputeCase.id == dispute_id).first()
    if not dispute:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Dispute with id:{dispute_id} does not exist')
    return dispute


@router.patch('/disputes/{dispute_id}/decision', response_model=DisputeCaseShow)
def resolve_dispute(
    dispute_id: int,
    request: DisputeDecisionUpdate,
    db: Session = Depends(get_db),
    current_admin: User = Depends(get_current_admin_user),
):
    if request.status not in DISPUTE_STATUSES:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Unsupported dispute status')

    dispute = db.query(DisputeCase).filter(DisputeCase.id == dispute_id).first()
    if not dispute:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Dispute with id:{dispute_id} does not exist')

    dispute.decision = request.decision
    dispute.decision_reason = request.reason
    dispute.status = request.status
    if request.status == 'resolved':
        dispute.resolved_at = datetime.utcnow()
    write_audit_log(db, current_admin, 'resolve_dispute', request.reason, 'dispute_case', dispute.id)
    db.commit()
    return db.query(DisputeCase).options(*dispute_load_options()).filter(DisputeCase.id == dispute_id).first()


@router.get('/disputes/{dispute_id}/chat-logs', response_model=ChatLogsResponse)
def get_dispute_chat_logs(dispute_id: int, db: Session = Depends(get_db), current_admin: UserShow = Depends(get_current_admin_user)):
    dispute = db.query(DisputeCase).filter(DisputeCase.id == dispute_id).first()
    if not dispute:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Dispute with id:{dispute_id} does not exist')

    evidence = (
        db.query(DisputeEvidence)
        .filter(DisputeEvidence.dispute_id == dispute_id, DisputeEvidence.evidence_type == 'chat_log')
        .all()
    )
    return ChatLogsResponse(
        complete=bool(evidence) and all(item.complete for item in evidence),
        evidence=evidence,
    )


@router.get('/audit-logs', response_model=list[AdminAuditLogShow])
def get_audit_logs(db: Session = Depends(get_db), current_admin: UserShow = Depends(get_current_admin_user)):
    return db.query(AdminAuditLog).order_by(AdminAuditLog.created_at.desc()).all()
