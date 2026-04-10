from sqlalchemy import Column, Integer, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from database import Base

class Registration(Base):
    __tablename__ = 'registrations' 
    
    id            = Column(Integer, primary_key=True, index=True)
    user_id       = Column(Integer, ForeignKey("users.id"))
    event_id      = Column(Integer, ForeignKey("events.id"))   
    registered_at = Column(DateTime)

    user  = relationship("User", back_populates="registrations")
    event = relationship("Event", back_populates="registrations")
    