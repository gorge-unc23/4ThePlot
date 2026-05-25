from sqlalchemy import Column, Integer, DateTime, ForeignKey, Table
from sqlalchemy.orm import relationship
from database import Base
import datetime


goer_preference_categories = Table(
    'goer_preference_categories',
    Base.metadata,
    Column('preference_id', Integer, ForeignKey('goer_preferences.id'), primary_key=True),
    Column('category_id', Integer, ForeignKey('categories.id'), primary_key=True),
)


class GoerPreferences(Base):
    __tablename__ = 'goer_preferences'

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), unique=True, nullable=False)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow)

    user = relationship('User', back_populates='goer_preferences')
    categories = relationship('Category', secondary=goer_preference_categories)
