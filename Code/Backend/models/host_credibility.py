from sqlalchemy import Column, Integer, Boolean, ForeignKey, Float
from sqlalchemy.orm import relationship
from database import Base


class HostCredibility(Base):
    __tablename__ = 'host_credibility'

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey('users.id'), unique=True, nullable=False)
    rating = Column(Float)
    review_count = Column(Integer)
    trusted = Column(Boolean)

    user = relationship('User', back_populates='host_credibility')
