from sqlalchemy import Column, Integer, String, Table, ForeignKey
from sqlalchemy.orm import relationship
from database import Base


event_categories = Table(
    'event_categories',
    Base.metadata,
    Column('event_id', Integer, ForeignKey('events.id'), primary_key=True),
    Column('category_id', Integer, ForeignKey('categories.id'), primary_key=True),
)


class Category(Base):
    __tablename__ = 'categories'

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False, index=True)

    events = relationship('Event', secondary=event_categories, back_populates='category_links')
