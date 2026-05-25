"""normalize schema

Revision ID: 0001_normalize_schema
Revises: 
Create Date: 2026-05-20
"""
from alembic import op
import sqlalchemy as sa


revision = '0001_normalize_schema'
down_revision = None
branch_labels = None
depends_on = None


def has_column(inspector, table_name: str, column_name: str) -> bool:
    return column_name in {col['name'] for col in inspector.get_columns(table_name)}


def upgrade():
    bind = op.get_bind()
    inspector = sa.inspect(bind)
    existing_tables = set(inspector.get_table_names())

    if 'categories' not in existing_tables:
        op.create_table(
            'categories',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('name', sa.String(), nullable=False),
        )
        op.create_index('ix_categories_name', 'categories', ['name'], unique=True)

    if 'tags' not in existing_tables:
        op.create_table(
            'tags',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('name', sa.String(), nullable=False),
        )
        op.create_index('ix_tags_name', 'tags', ['name'], unique=True)

    if 'event_categories' not in existing_tables:
        op.create_table(
            'event_categories',
            sa.Column('event_id', sa.Integer(), sa.ForeignKey('events.id'), primary_key=True),
            sa.Column('category_id', sa.Integer(), sa.ForeignKey('categories.id'), primary_key=True),
        )

    if 'event_tags' not in existing_tables:
        op.create_table(
            'event_tags',
            sa.Column('event_id', sa.Integer(), sa.ForeignKey('events.id'), primary_key=True),
            sa.Column('tag_id', sa.Integer(), sa.ForeignKey('tags.id'), primary_key=True),
        )

    if 'event_locations' not in existing_tables:
        op.create_table(
            'event_locations',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('event_id', sa.Integer(), sa.ForeignKey('events.id'), nullable=False, unique=True),
            sa.Column('address', sa.String(), nullable=False),
            sa.Column('venue_name', sa.String()),
            sa.Column('latitude', sa.Float()),
            sa.Column('longitude', sa.Float()),
            sa.Column('city', sa.String()),
        )

    if 'event_capacities' not in existing_tables:
        op.create_table(
            'event_capacities',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('event_id', sa.Integer(), sa.ForeignKey('events.id'), nullable=False, unique=True),
            sa.Column('max_attendees', sa.Integer()),
            sa.Column('confirmed_attendees', sa.Integer(), server_default='0'),
            sa.Column('waitlist_enabled', sa.Boolean(), server_default='0'),
        )

    if 'recurrence_rules' not in existing_tables:
        op.create_table(
            'recurrence_rules',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('event_id', sa.Integer(), sa.ForeignKey('events.id'), nullable=False, unique=True),
            sa.Column('frequency', sa.String(), nullable=False, server_default='weekly'),
            sa.Column('interval', sa.Integer(), server_default='1'),
            sa.Column('end_date', sa.DateTime()),
            sa.Column('count', sa.Integer()),
        )

    if 'recurrence_weekdays' not in existing_tables:
        op.create_table(
            'recurrence_weekdays',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('rule_id', sa.Integer(), sa.ForeignKey('recurrence_rules.id'), nullable=False),
            sa.Column('weekday', sa.Integer(), nullable=False),
        )

    if 'goer_preferences' not in existing_tables:
        op.create_table(
            'goer_preferences',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id'), nullable=False, unique=True),
            sa.Column('updated_at', sa.DateTime()),
        )

    if 'goer_preference_categories' not in existing_tables:
        op.create_table(
            'goer_preference_categories',
            sa.Column('preference_id', sa.Integer(), sa.ForeignKey('goer_preferences.id'), primary_key=True),
            sa.Column('category_id', sa.Integer(), sa.ForeignKey('categories.id'), primary_key=True),
        )

    if 'business_profiles' not in existing_tables:
        op.create_table(
            'business_profiles',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id'), nullable=False, unique=True),
            sa.Column('name', sa.String(), nullable=False),
            sa.Column('description', sa.String()),
            sa.Column('website_url', sa.String()),
            sa.Column('logo_url', sa.String()),
            sa.Column('is_published', sa.Boolean(), server_default='0'),
        )

    if 'host_credibility' not in existing_tables:
        op.create_table(
            'host_credibility',
            sa.Column('id', sa.Integer(), primary_key=True),
            sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id'), nullable=False, unique=True),
            sa.Column('rating', sa.Float()),
            sa.Column('review_count', sa.Integer()),
            sa.Column('trusted', sa.Boolean()),
        )

    if not has_column(inspector, 'events', 'start_at'):
        op.add_column('events', sa.Column('start_at', sa.DateTime()))
    if not has_column(inspector, 'events', 'end_at'):
        op.add_column('events', sa.Column('end_at', sa.DateTime()))
    if not has_column(inspector, 'events', 'currency'):
        op.add_column('events', sa.Column('currency', sa.String(), server_default='EUR'))
    if not has_column(inspector, 'events', 'host_name'):
        op.add_column('events', sa.Column('host_name', sa.String()))

    if not has_column(inspector, 'users', 'display_name'):
        op.add_column('users', sa.Column('display_name', sa.String()))
    if not has_column(inspector, 'users', 'phone'):
        op.add_column('users', sa.Column('phone', sa.String()))
    if not has_column(inspector, 'users', 'avatar_url'):
        op.add_column('users', sa.Column('avatar_url', sa.String()))
    if not has_column(inspector, 'users', 'role'):
        op.add_column('users', sa.Column('role', sa.String(), server_default='goer'))
    if not has_column(inspector, 'users', 'status'):
        op.add_column('users', sa.Column('status', sa.String(), server_default='active'))

    events_columns = {col['name'] for col in inspector.get_columns('events')}
    events_table = sa.table('events', *[sa.column(name) for name in events_columns])

    location_rows = []
    capacity_rows = []
    category_links = []
    category_map = {}

    select_cols = ['id']
    for name in ['address', 'venue_name', 'latitude', 'longitude', 'city', 'max_attendees', 'category', 'event_date']:
        if name in events_columns:
            select_cols.append(name)

    if len(select_cols) > 1:
        events_table = sa.table('events', *[sa.column(name) for name in select_cols])
        rows = bind.execute(sa.select(*[events_table.c[name] for name in select_cols])).fetchall()
    else:
        rows = []

    if rows:
        for row in rows:
            row_data = dict(row._mapping)
            event_id = row_data['id']
            address = row_data.get('address') or ''
            location_rows.append({
                'event_id': event_id,
                'address': address,
                'venue_name': row_data.get('venue_name'),
                'latitude': row_data.get('latitude'),
                'longitude': row_data.get('longitude'),
                'city': row_data.get('city'),
            })

            capacity_rows.append({
                'event_id': event_id,
                'max_attendees': row_data.get('max_attendees'),
                'confirmed_attendees': 0,
                'waitlist_enabled': False,
            })

            category_name = row_data.get('category')
            if category_name:
                category_id = category_map.get(category_name)
                if category_id is None:
                    result = bind.execute(
                        sa.insert(sa.table('categories', sa.column('name'))).values(name=category_name)
                    )
                    category_id = result.inserted_primary_key[0]
                    category_map[category_name] = category_id
                category_links.append({'event_id': event_id, 'category_id': category_id})

        if location_rows:
            bind.execute(sa.insert(sa.table(
                'event_locations',
                sa.column('event_id'),
                sa.column('address'),
                sa.column('venue_name'),
                sa.column('latitude'),
                sa.column('longitude'),
                sa.column('city'),
            )), location_rows)

        if capacity_rows:
            bind.execute(sa.insert(sa.table(
                'event_capacities',
                sa.column('event_id'),
                sa.column('max_attendees'),
                sa.column('confirmed_attendees'),
                sa.column('waitlist_enabled'),
            )), capacity_rows)

        if category_links:
            bind.execute(sa.insert(sa.table(
                'event_categories',
                sa.column('event_id'),
                sa.column('category_id'),
            )), category_links)

        if 'event_date' in events_columns and 'start_at' in events_columns:
            bind.execute(sa.text(
                'UPDATE events SET start_at = COALESCE(start_at, event_date)'
            ))
        if 'event_date' in events_columns and 'end_at' in events_columns:
            bind.execute(sa.text(
                'UPDATE events SET end_at = COALESCE(end_at, event_date)'
            ))

    if has_column(inspector, 'users', 'display_name'):
        bind.execute(sa.text(
            'UPDATE users SET display_name = COALESCE(display_name, username)'
        ))


def downgrade():
    op.drop_table('host_credibility')
    op.drop_table('business_profiles')
    op.drop_table('goer_preference_categories')
    op.drop_table('goer_preferences')
    op.drop_table('recurrence_weekdays')
    op.drop_table('recurrence_rules')
    op.drop_table('event_capacities')
    op.drop_table('event_locations')
    op.drop_table('event_tags')
    op.drop_table('event_categories')
    op.drop_index('ix_tags_name', table_name='tags')
    op.drop_table('tags')
    op.drop_index('ix_categories_name', table_name='categories')
    op.drop_table('categories')
