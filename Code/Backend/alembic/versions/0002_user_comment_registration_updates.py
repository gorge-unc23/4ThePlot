"""user comment registration updates

Revision ID: 0002_user_comment_registration_updates
Revises: 0001_normalize_schema
Create Date: 2026-05-20
"""
from alembic import op
import sqlalchemy as sa


revision = '0002_user_comment_registration_updates'
down_revision = '0001_normalize_schema'
branch_labels = None
depends_on = None


def has_column(inspector, table_name: str, column_name: str) -> bool:
    return column_name in {col['name'] for col in inspector.get_columns(table_name)}


def upgrade():
    bind = op.get_bind()
    inspector = sa.inspect(bind)

    if not has_column(inspector, 'users', 'updated_at'):
        op.add_column('users', sa.Column('updated_at', sa.DateTime()))

    if not has_column(inspector, 'comments', 'created_at'):
        op.add_column('comments', sa.Column('created_at', sa.DateTime()))

    if not has_column(inspector, 'registrations', 'registered_at'):
        op.add_column('registrations', sa.Column('registered_at', sa.DateTime()))

    if has_column(inspector, 'users', 'updated_at'):
        bind.execute(sa.text('UPDATE users SET updated_at = COALESCE(updated_at, created_at)'))

    if has_column(inspector, 'comments', 'created_at'):
        bind.execute(sa.text('UPDATE comments SET created_at = COALESCE(created_at, CURRENT_TIMESTAMP)'))

    if has_column(inspector, 'registrations', 'registered_at'):
        bind.execute(sa.text('UPDATE registrations SET registered_at = COALESCE(registered_at, CURRENT_TIMESTAMP)'))


def downgrade():
    pass
