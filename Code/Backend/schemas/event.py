from pydantic import BaseModel, ConfigDict, Field, field_validator
from datetime import datetime
from typing import List, Optional


def to_camel(value: str) -> str:
    parts = value.split('_')
    return parts[0] + ''.join(word.capitalize() for word in parts[1:])


class CamelModel(BaseModel):
    model_config = ConfigDict(
        validate_by_name=True,
        alias_generator=to_camel,
        from_attributes=True,
    )


class EventLocation(CamelModel):
    address: str
    venue_name: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    city: Optional[str] = None


class EventCapacity(CamelModel):
    max_attendees: Optional[int] = None
    confirmed_attendees: int = 0
    waitlist_enabled: bool = False


class RecurrenceRule(CamelModel):
    frequency: str = 'weekly'
    interval: int = 1
    end_date: Optional[datetime] = None
    count: Optional[int] = None
    by_weekday: Optional[List[int]] = None


class EventCreate(CamelModel):
    title: str
    description: str
    organizer_id: int = Field(alias='hostId')
    host_name: Optional[str] = Field(default=None, alias='hostName')
    status: str
    start_at: Optional[datetime] = Field(default=None, alias='startAt')
    end_at: Optional[datetime] = Field(default=None, alias='endAt')
    location: Optional[EventLocation] = None
    capacity: Optional[EventCapacity] = None
    recurrence: Optional[RecurrenceRule] = None
    categories: List[str] = Field(default_factory=list)
    tags: List[str] = Field(default_factory=list)
    price: float
    currency: str = 'EUR'
    trending: bool = False
    image_url: Optional[str] = Field(default=None, alias='coverImageUrl')

    category: Optional[str] = None
    event_date: Optional[datetime] = Field(default=None, alias='eventDate')
    address: Optional[str] = None
    venue_name: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    city: Optional[str] = None
    max_attendees: Optional[int] = None


class ShowEvent(CamelModel):
    id: int
    title: str
    description: str
    organizer_id: int = Field(alias='hostId')
    host_name: Optional[str] = Field(default=None, alias='hostName')
    status: str
    start_at: Optional[datetime] = Field(default=None, alias='startAt')
    end_at: Optional[datetime] = Field(default=None, alias='endAt')
    location: EventLocation
    capacity: EventCapacity
    recurrence: Optional[RecurrenceRule] = None
    categories: List[str] = Field(default_factory=list)
    tags: List[str] = Field(default_factory=list)
    price: float
    currency: str
    trending: bool = False
    image_url: Optional[str] = Field(default=None, alias='coverImageUrl')
    created_at: datetime = Field(alias='createdAt')
    updated_at: datetime = Field(alias='updatedAt')

    @field_validator('categories', mode='before')
    def normalize_categories(cls, value):
        if value is None:
            return []
        if isinstance(value, list) and value and hasattr(value[0], 'name'):
            return [item.name for item in value]
        return value

    @field_validator('tags', mode='before')
    def normalize_tags(cls, value):
        if value is None:
            return []
        if isinstance(value, list) and value and hasattr(value[0], 'name'):
            return [item.name for item in value]
        return value
    
    
    
