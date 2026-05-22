from sqlalchemy import Column, Integer, String, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from database import Base
import datetime

class Comment(Base):
    __tablename__ = 'comments'
    
    id         = Column(Integer, primary_key=True, index=True)
    user_id    = Column(Integer, ForeignKey("users.id"))    
    event_id   = Column(Integer, ForeignKey("events.id"))   
    text       = Column(String)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    author = relationship("User", back_populates="comments")  
    event  = relationship("Event", back_populates="comments")
    