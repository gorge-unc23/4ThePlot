from sqlalchemy import Boolean, Column, Integer, String, DateTime, ForeignKey, Float
import datetime
from sqlalchemy.orm import relationship
from database import Base
from models.category import event_categories
from models.tag import event_tags

class Event(Base):
    __tablename__ = 'events'
    
    id            = Column(Integer, primary_key=True, index=True)
    title         = Column(String)
    description   = Column(String)
    status        = Column(String)
    image_url     = Column(String)
    start_at      = Column(DateTime)
    end_at        = Column(DateTime)
    price         = Column(Float)
    currency      = Column(String, default='EUR')
    trending      = Column(Boolean, default=False, nullable=False)
    organizer_id  = Column(Integer, ForeignKey("users.id"))
    host_name     = Column(String)
    created_at    = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at    = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    organizer     = relationship("User", back_populates="events")
    registrations = relationship("Registration", back_populates="event")
    comments      = relationship("Comment", back_populates="event")
    location      = relationship("EventLocation", back_populates="event", uselist=False, cascade="all, delete-orphan")
    capacity      = relationship("EventCapacity", back_populates="event", uselist=False, cascade="all, delete-orphan")
    recurrence    = relationship("RecurrenceRule", back_populates="event", uselist=False, cascade="all, delete-orphan")
    category_links = relationship("Category", secondary=event_categories, back_populates="events")
    tag_links     = relationship("Tag", secondary=event_tags, back_populates="events")

    @property
    def categories(self):
        return [category.name for category in self.category_links]

    @property
    def tags(self):
        return [tag.name for tag in self.tag_links]
    
