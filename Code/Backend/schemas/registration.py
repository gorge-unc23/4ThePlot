from pydantic import BaseModel, ConfigDict, Field
from datetime import datetime
from typing import Optional
from schemas.user import UserShow
from schemas.event import ShowEvent


def to_camel(value: str) -> str:
    parts = value.split('_')
    return parts[0] + ''.join(word.capitalize() for word in parts[1:])


class CamelModel(BaseModel):
    model_config = ConfigDict(
        validate_by_name=True,
        alias_generator=to_camel,
        from_attributes=True,
    )


class RegistrationCreate(CamelModel):
    user_id: int = Field(alias='userId')
    event_id: int = Field(alias='eventId')


class ShowRegistration(CamelModel):
    id: int
    user_id: int = Field(alias='userId')
    event_id: int = Field(alias='eventId')
    registered_at: Optional[datetime] = Field(default=None, alias='registeredAt')
    user: Optional[UserShow] = None
    event: Optional[ShowEvent] = None
    
