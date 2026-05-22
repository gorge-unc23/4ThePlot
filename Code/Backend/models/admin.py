from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from database import Base
import datetime


class AdminAuditLog(Base):
    __tablename__ = 'admin_audit_logs'

    id = Column(Integer, primary_key=True, index=True)
    admin_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    action = Column(String, nullable=False)
    target_type = Column(String)
    target_id = Column(Integer)
    reason = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    admin = relationship('User')


class SafetyReport(Base):
    __tablename__ = 'safety_reports'

    id = Column(Integer, primary_key=True, index=True)
    reporter_user_id = Column(Integer, ForeignKey('users.id'))
    reported_user_id = Column(Integer, ForeignKey('users.id'))
    reported_event_id = Column(Integer, ForeignKey('events.id'))
    reported_comment_id = Column(Integer, ForeignKey('comments.id'))
    reason = Column(Text, nullable=False)
    severity = Column(String, default='medium')
    status = Column(String, default='open')
    evidence_complete = Column(Boolean, default=False)
    resolved_at = Column(DateTime)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    reporter = relationship('User', foreign_keys=[reporter_user_id])
    reported_user = relationship('User', foreign_keys=[reported_user_id])
    reported_event = relationship('Event')
    reported_comment = relationship('Comment')
    evidence = relationship('ReportEvidence', back_populates='report', cascade='all, delete-orphan')
    moderation_actions = relationship('ModerationAction', back_populates='report', cascade='all, delete-orphan')


class ReportEvidence(Base):
    __tablename__ = 'report_evidence'

    id = Column(Integer, primary_key=True, index=True)
    report_id = Column(Integer, ForeignKey('safety_reports.id'), nullable=False)
    evidence_type = Column(String, default='text')
    content_url = Column(String)
    content_text = Column(Text)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    report = relationship('SafetyReport', back_populates='evidence')


class ModerationAction(Base):
    __tablename__ = 'moderation_actions'

    id = Column(Integer, primary_key=True, index=True)
    report_id = Column(Integer, ForeignKey('safety_reports.id'), nullable=False)
    admin_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    action = Column(String, nullable=False)
    reason = Column(Text, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    report = relationship('SafetyReport', back_populates='moderation_actions')
    admin = relationship('User')


class HostVerificationRequest(Base):
    __tablename__ = 'host_verification_requests'

    id = Column(Integer, primary_key=True, index=True)
    host_user_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    status = Column(String, default='pending')
    submitted_at = Column(DateTime, default=datetime.datetime.utcnow)
    reviewed_at = Column(DateTime)
    reviewed_by_admin_id = Column(Integer, ForeignKey('users.id'))
    review_reason = Column(Text)

    host = relationship('User', foreign_keys=[host_user_id])
    reviewed_by = relationship('User', foreign_keys=[reviewed_by_admin_id])
    documents = relationship('HostVerificationDocument', back_populates='request', cascade='all, delete-orphan')


class HostVerificationDocument(Base):
    __tablename__ = 'host_verification_documents'

    id = Column(Integer, primary_key=True, index=True)
    request_id = Column(Integer, ForeignKey('host_verification_requests.id'), nullable=False)
    document_type = Column(String, nullable=False)
    document_url = Column(String, nullable=False)
    status = Column(String, default='submitted')
    uploaded_at = Column(DateTime, default=datetime.datetime.utcnow)

    request = relationship('HostVerificationRequest', back_populates='documents')


class GlobalNotification(Base):
    __tablename__ = 'global_notifications'

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    message = Column(Text, nullable=False)
    status = Column(String, default='draft')
    starts_at = Column(DateTime)
    ends_at = Column(DateTime)
    created_by_admin_id = Column(Integer, ForeignKey('users.id'), nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    created_by = relationship('User')


class DisputeCase(Base):
    __tablename__ = 'dispute_cases'

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(Integer, ForeignKey('events.id'))
    host_user_id = Column(Integer, ForeignKey('users.id'))
    goer_user_id = Column(Integer, ForeignKey('users.id'))
    status = Column(String, default='open')
    reason = Column(Text)
    decision = Column(String)
    decision_reason = Column(Text)
    resolved_at = Column(DateTime)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    event = relationship('Event')
    host = relationship('User', foreign_keys=[host_user_id])
    goer = relationship('User', foreign_keys=[goer_user_id])
    evidence = relationship('DisputeEvidence', back_populates='dispute', cascade='all, delete-orphan')


class DisputeEvidence(Base):
    __tablename__ = 'dispute_evidence'

    id = Column(Integer, primary_key=True, index=True)
    dispute_id = Column(Integer, ForeignKey('dispute_cases.id'), nullable=False)
    evidence_type = Column(String, default='text')
    content_url = Column(String)
    content_text = Column(Text)
    complete = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    dispute = relationship('DisputeCase', back_populates='evidence')
