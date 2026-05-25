from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field


def to_camel(value: str) -> str:
    parts = value.split('_')
    return parts[0] + ''.join(word.capitalize() for word in parts[1:])


class CamelModel(BaseModel):
    model_config = ConfigDict(
        validate_by_name=True,
        alias_generator=to_camel,
        from_attributes=True,
    )


class AuditLogShow(CamelModel):
    id: int
    actor_user_id: Optional[int] = Field(default=None, alias='actorUserId')
    actor_role: Optional[str] = Field(default=None, alias='actorRole')
    action: str
    model_name: str = Field(alias='model')
    model_id: Optional[str] = Field(default=None, alias='modelId')
    old_values: Optional[dict] = Field(default=None, alias='oldValues')
    new_values: Optional[dict] = Field(default=None, alias='newValues')
    route: Optional[str] = None
    method: Optional[str] = None
    ip_address: Optional[str] = Field(default=None, alias='ipAddress')
    created_at: datetime = Field(alias='createdAt')


class AuditLogListResponse(CamelModel):
    total: int
    page: int
    page_size: int = Field(alias='pageSize')
    items: list[AuditLogShow]
