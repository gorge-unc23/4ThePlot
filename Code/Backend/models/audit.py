from sqlalchemy import Column, DateTime, ForeignKey, Integer, JSON, String
from sqlalchemy.orm import relationship
from database import Base
from models.user import User
import datetime


class AuditLog(Base):
    __tablename__ = 'audit_logs'

    id = Column(Integer, primary_key=True, index=True)
    actor_user_id = Column(Integer, ForeignKey('users.id'), nullable=True)
    actor_role = Column(String, nullable=True)
    action = Column(String, nullable=False)
    model_name = Column(String, nullable=False)
    model_id = Column(String, nullable=True)
    old_values = Column(JSON, nullable=True)
    new_values = Column(JSON, nullable=True)
    route = Column(String, nullable=True)
    method = Column(String, nullable=True)
    ip_address = Column(String, nullable=True)
    created_at = Column(DateTime, default=datetime.datetime.utcnow, index=True)

    actor = relationship(User)
