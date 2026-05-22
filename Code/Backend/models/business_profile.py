from sqlalchemy import Column, Integer, String, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from database import Base


class BusinessProfile(Base):
    __tablename__ = 'business_profiles'

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), unique=True, nullable=False)
    name = Column(String, nullable=False)
    description = Column(String)
    website_url = Column(String)
    logo_url = Column(String)
    is_published = Column(Boolean, default=False)

    user = relationship('User', back_populates='business_profile')
