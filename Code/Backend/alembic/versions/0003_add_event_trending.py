"""add event trending

Revision ID: 0003_add_event_trending
Revises: 0002_user_comment_registration_updates
Create Date: 2026-05-21
"""
from alembic import op
import sqlalchemy as sa


revision = '0003_add_event_trending'
down_revision = '0002_user_comment_registration_updates'
branch_labels = None
depends_on = None


def has_column(inspector, table_name: str, column_name: str) -> bool:
    return column_name in {col['name'] for col in inspector.get_columns(table_name)}


def upgrade():
    bind = op.get_bind()
    inspector = sa.inspect(bind)

    if not has_column(inspector, 'events', 'trending'):
        op.add_column(
            'events',
            sa.Column('trending', sa.Boolean(), nullable=False, server_default='0'),
        )

    bind.execute(sa.text('UPDATE events SET trending = 0 WHERE trending IS NULL'))


def downgrade():
    bind = op.get_bind()
    inspector = sa.inspect(bind)

    if has_column(inspector, 'events', 'trending'):
        op.drop_column('events', 'trending')
