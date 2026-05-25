"""add generic audit logs

Revision ID: 0005_add_generic_audit_logs
Revises: 0004_admin_mvp
Create Date: 2026-05-23
"""
from alembic import op
import sqlalchemy as sa


revision = '0005_add_generic_audit_logs'
down_revision = '0004_admin_mvp'
branch_labels = None
depends_on = None


def has_table(inspector, table_name: str) -> bool:
    return table_name in set(inspector.get_table_names())


def upgrade():
    bind = op.get_bind()
    inspector = sa.inspect(bind)

    if not has_table(inspector, 'audit_logs'):
        op.create_table(
            'audit_logs',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('actor_user_id', sa.Integer(), sa.ForeignKey('users.id')),
            sa.Column('actor_role', sa.String()),
            sa.Column('action', sa.String(), nullable=False),
            sa.Column('model_name', sa.String(), nullable=False),
            sa.Column('model_id', sa.String()),
            sa.Column('old_values', sa.JSON()),
            sa.Column('new_values', sa.JSON()),
            sa.Column('route', sa.String()),
            sa.Column('method', sa.String()),
            sa.Column('ip_address', sa.String()),
            sa.Column('created_at', sa.DateTime()),
        )
        op.create_index('ix_audit_logs_created_at', 'audit_logs', ['created_at'])


def downgrade():
    op.drop_index('ix_audit_logs_created_at', table_name='audit_logs')
    op.drop_table('audit_logs')
