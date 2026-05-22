"""admin mvp

Revision ID: 0004_admin_mvp
Revises: 0003_add_event_trending
Create Date: 2026-05-22
"""
from alembic import op
import sqlalchemy as sa


revision = '0004_admin_mvp'
down_revision = '0003_add_event_trending'
branch_labels = None
depends_on = None


def has_table(inspector, table_name: str) -> bool:
    return table_name in set(inspector.get_table_names())


def upgrade():
    bind = op.get_bind()
    inspector = sa.inspect(bind)

    if not has_table(inspector, 'admin_audit_logs'):
        op.create_table(
            'admin_audit_logs',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('admin_id', sa.Integer(), sa.ForeignKey('users.id'), nullable=False),
            sa.Column('action', sa.String(), nullable=False),
            sa.Column('target_type', sa.String()),
            sa.Column('target_id', sa.Integer()),
            sa.Column('reason', sa.Text(), nullable=False),
            sa.Column('created_at', sa.DateTime()),
        )

    if not has_table(inspector, 'safety_reports'):
        op.create_table(
            'safety_reports',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('reporter_user_id', sa.Integer(), sa.ForeignKey('users.id')),
            sa.Column('reported_user_id', sa.Integer(), sa.ForeignKey('users.id')),
            sa.Column('reported_event_id', sa.Integer(), sa.ForeignKey('events.id')),
            sa.Column('reported_comment_id', sa.Integer(), sa.ForeignKey('comments.id')),
            sa.Column('reason', sa.Text(), nullable=False),
            sa.Column('severity', sa.String(), server_default='medium'),
            sa.Column('status', sa.String(), server_default='open'),
            sa.Column('evidence_complete', sa.Boolean(), server_default='0'),
            sa.Column('resolved_at', sa.DateTime()),
            sa.Column('created_at', sa.DateTime()),
            sa.Column('updated_at', sa.DateTime()),
        )

    if not has_table(inspector, 'report_evidence'):
        op.create_table(
            'report_evidence',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('report_id', sa.Integer(), sa.ForeignKey('safety_reports.id'), nullable=False),
            sa.Column('evidence_type', sa.String(), server_default='text'),
            sa.Column('content_url', sa.String()),
            sa.Column('content_text', sa.Text()),
            sa.Column('created_at', sa.DateTime()),
        )

    if not has_table(inspector, 'moderation_actions'):
        op.create_table(
            'moderation_actions',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('report_id', sa.Integer(), sa.ForeignKey('safety_reports.id'), nullable=False),
            sa.Column('admin_id', sa.Integer(), sa.ForeignKey('users.id'), nullable=False),
            sa.Column('action', sa.String(), nullable=False),
            sa.Column('reason', sa.Text(), nullable=False),
            sa.Column('created_at', sa.DateTime()),
        )

    if not has_table(inspector, 'host_verification_requests'):
        op.create_table(
            'host_verification_requests',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('host_user_id', sa.Integer(), sa.ForeignKey('users.id'), nullable=False),
            sa.Column('status', sa.String(), server_default='pending'),
            sa.Column('submitted_at', sa.DateTime()),
            sa.Column('reviewed_at', sa.DateTime()),
            sa.Column('reviewed_by_admin_id', sa.Integer(), sa.ForeignKey('users.id')),
            sa.Column('review_reason', sa.Text()),
        )

    if not has_table(inspector, 'host_verification_documents'):
        op.create_table(
            'host_verification_documents',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('request_id', sa.Integer(), sa.ForeignKey('host_verification_requests.id'), nullable=False),
            sa.Column('document_type', sa.String(), nullable=False),
            sa.Column('document_url', sa.String(), nullable=False),
            sa.Column('status', sa.String(), server_default='submitted'),
            sa.Column('uploaded_at', sa.DateTime()),
        )

    if not has_table(inspector, 'global_notifications'):
        op.create_table(
            'global_notifications',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('title', sa.String(), nullable=False),
            sa.Column('message', sa.Text(), nullable=False),
            sa.Column('status', sa.String(), server_default='draft'),
            sa.Column('starts_at', sa.DateTime()),
            sa.Column('ends_at', sa.DateTime()),
            sa.Column('created_by_admin_id', sa.Integer(), sa.ForeignKey('users.id'), nullable=False),
            sa.Column('created_at', sa.DateTime()),
            sa.Column('updated_at', sa.DateTime()),
        )

    if not has_table(inspector, 'dispute_cases'):
        op.create_table(
            'dispute_cases',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('event_id', sa.Integer(), sa.ForeignKey('events.id')),
            sa.Column('host_user_id', sa.Integer(), sa.ForeignKey('users.id')),
            sa.Column('goer_user_id', sa.Integer(), sa.ForeignKey('users.id')),
            sa.Column('status', sa.String(), server_default='open'),
            sa.Column('reason', sa.Text()),
            sa.Column('decision', sa.String()),
            sa.Column('decision_reason', sa.Text()),
            sa.Column('resolved_at', sa.DateTime()),
            sa.Column('created_at', sa.DateTime()),
            sa.Column('updated_at', sa.DateTime()),
        )

    if not has_table(inspector, 'dispute_evidence'):
        op.create_table(
            'dispute_evidence',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('dispute_id', sa.Integer(), sa.ForeignKey('dispute_cases.id'), nullable=False),
            sa.Column('evidence_type', sa.String(), server_default='text'),
            sa.Column('content_url', sa.String()),
            sa.Column('content_text', sa.Text()),
            sa.Column('complete', sa.Boolean(), server_default='1'),
            sa.Column('created_at', sa.DateTime()),
        )


def downgrade():
    op.drop_table('dispute_evidence')
    op.drop_table('dispute_cases')
    op.drop_table('global_notifications')
    op.drop_table('host_verification_documents')
    op.drop_table('host_verification_requests')
    op.drop_table('moderation_actions')
    op.drop_table('report_evidence')
    op.drop_table('safety_reports')
    op.drop_table('admin_audit_logs')
