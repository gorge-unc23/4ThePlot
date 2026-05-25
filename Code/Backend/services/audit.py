import logging
import os
from datetime import date, datetime
from decimal import Decimal
from fastapi import BackgroundTasks, Request
from jose import JWTError, jwt
from database import SessionLocal
from authentication import token
from models.audit import AuditLog
from models.user import User


logger = logging.getLogger(__name__)
AUDIT_LOG_ENABLED = os.getenv('AUDIT_LOG_ENABLED', 'true').lower() == 'true'
AUDIT_LOG_RETENTION_DAYS = int(os.getenv('AUDIT_LOG_RETENTION_DAYS', '365'))
SENSITIVE_FIELDS = {
    'password',
    'hashed_password',
    'access_token',
    'token',
    'secret',
}


def serialize_value(value):
    if isinstance(value, datetime):
        return value.isoformat()
    if isinstance(value, date):
        return value.isoformat()
    if isinstance(value, Decimal):
        return float(value)
    return value


def serialize_model(instance) -> dict:
    if instance is None:
        return {}

    data = {}
    for column in instance.__table__.columns:
        if column.name in SENSITIVE_FIELDS:
            data[column.name] = '[REDACTED]'
        else:
            data[column.name] = serialize_value(getattr(instance, column.name))
    return data


def write_audit_log(payload: dict):
    if not AUDIT_LOG_ENABLED:
        return

    db = SessionLocal()
    try:
        db.add(AuditLog(**payload))
        db.commit()
    except Exception:
        db.rollback()
        logger.exception('Failed to write audit log')
    finally:
        db.close()


def get_optional_actor(request: Request):
    authorization = request.headers.get('authorization')
    if not authorization:
        return None

    scheme, _, raw_token = authorization.partition(' ')
    if scheme.lower() != 'bearer' or not raw_token:
        return None

    db = SessionLocal()
    try:
        payload = jwt.decode(raw_token, token.SECRET_KEY, algorithms=[token.ALGORITHM])
        email = payload.get('sub')
        if not email:
            return None
        return db.query(User).filter(User.email == email).first()
    except JWTError:
        return None
    finally:
        db.close()


class AuditLogger:
    def __init__(self, request: Request, background_tasks: BackgroundTasks, current_user=None):
        self.request = request
        self.background_tasks = background_tasks
        self.current_user = current_user

    def log(
        self,
        action: str,
        model_name: str,
        model_id: str | int | None,
        old_values: dict | None = None,
        new_values: dict | None = None,
    ):
        payload = {
            'actor_user_id': getattr(self.current_user, 'id', None),
            'actor_role': getattr(self.current_user, 'role', None),
            'action': action,
            'model_name': model_name,
            'model_id': str(model_id) if model_id is not None else None,
            'old_values': old_values,
            'new_values': new_values,
            'route': self.request.url.path,
            'method': self.request.method,
            'ip_address': self.request.client.host if self.request.client else None,
        }
        self.background_tasks.add_task(write_audit_log, payload)


def get_audit_logger(request: Request, background_tasks: BackgroundTasks):
    return AuditLogger(request, background_tasks, get_optional_actor(request))
