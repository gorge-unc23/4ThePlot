from sqlalchemy import Column, Integer, String, Float, ForeignKey
from sqlalchemy.orm import relationship
from database import Base


class EventLocation(Base):
    __tablename__ = 'event_locations'

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(Integer, ForeignKey('events.id'), unique=True, nullable=False)
    address = Column(String, nullable=False)
    venue_name = Column(String)
    latitude = Column(Float)
    longitude = Column(Float)
    city = Column(String)

    event = relationship('Event', back_populates='location')
