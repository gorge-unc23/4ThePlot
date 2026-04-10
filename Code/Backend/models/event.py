from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
import datetime
from sqlalchemy.orm import relationship
from database import Base

class Event(Base):
    __tablename__ = 'events'
    
    id           = Column(Integer, primary_key=True, index=True)
    title        = Column(String)
    description  = Column(String)
    category     = Column(String)
    status       = Column(String)
    image_url    = Column(String)
    address      = Column(String)
    latitude     = Column(Float)
    longitude    = Column(Float)
    city         = Column(String)
    event_date   = Column(DateTime)
    price        = Column(Float)
    max_attendees = Column(Integer)
    organizer_id = Column(Integer, ForeignKey("users.id")) 
    created_at   = Column(DateTime, default= datetime.datetime.utcnow)

    organizer     = relationship("User", back_populates="events")    
    registrations = relationship("Registration", back_populates="event")
    comments      = relationship("Comment", back_populates="event")
    