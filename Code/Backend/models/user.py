from sqlalchemy import Column, Integer, String, Boolean, DateTime
from sqlalchemy.orm import relationship
from database import Base
import datetime


class User(Base):
    __tablename__ = "users"

    id              = Column(Integer, primary_key=True, index=True)
    username        = Column(String, unique=True, nullable=False, index=True)
    display_name    = Column(String)
    email           = Column(String, unique=True, nullable=False, index=True)
    hashed_password = Column(String, nullable=False)
    phone           = Column(String)
    avatar_url      = Column(String)
    role            = Column(String, default='goer')
    status          = Column(String, default='active')
    is_active       = Column(Boolean, default=True)
    created_at      = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at      = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

    events          = relationship("Event", back_populates="organizer")
    registrations   = relationship("Registration", back_populates="user")
    comments        = relationship("Comment", back_populates="author")
    goer_preferences = relationship("GoerPreferences", back_populates="user", uselist=False, cascade="all, delete-orphan")
    business_profile = relationship("BusinessProfile", back_populates="user", uselist=False, cascade="all, delete-orphan")
    host_credibility = relationship("HostCredibility", back_populates="user", uselist=False, cascade="all, delete-orphan")