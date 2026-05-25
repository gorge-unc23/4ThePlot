from sqlalchemy import Column, Integer, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from database import Base


class EventCapacity(Base):
    __tablename__ = 'event_capacities'

    id = Column(Integer, primary_key=True, index=True)
    event_id = Column(Integer, ForeignKey('events.id'), unique=True, nullable=False)
    max_attendees = Column(Integer)
    confirmed_attendees = Column(Integer, default=0)
    waitlist_enabled = Column(Boolean, default=False)

    event = relationship('Event', back_populates='capacity')
