from pydantic import BaseModel, ConfigDict, EmailStr, Field, field_validator
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


class GoerPreferences(CamelModel):
    categories: List[str] = Field(default_factory=list)
    updated_at: Optional[datetime] = None

    @field_validator('categories', mode='before')
    def normalize_categories(cls, value):
        if value is None:
            return []
        if isinstance(value, list) and value and hasattr(value[0], 'name'):
            return [item.name for item in value]
        return value


class BusinessProfileSummary(CamelModel):
    name: str
    description: Optional[str] = None
    website_url: Optional[str] = None
    logo_url: Optional[str] = None
    is_published: bool = False


class HostCredibilitySummary(CamelModel):
    rating: Optional[float] = None
    review_count: Optional[int] = None
    trusted: Optional[bool] = None


class UserCreate(CamelModel):
    username: str
    email: EmailStr
    password: str
    display_name: Optional[str] = Field(default=None, alias='displayName')
    phone: Optional[str] = None
    avatar_url: Optional[str] = Field(default=None, alias='avatarUrl')
    role: str = 'goer'
    status: str = 'active'
    goer_preferences: Optional[GoerPreferences] = None
    business_profile: Optional[BusinessProfileSummary] = None
    host_credibility: Optional[HostCredibilitySummary] = None


class UserLogin(CamelModel):
    email: EmailStr
    password: str


class UserShow(CamelModel):
    id: int
    username: str
    display_name: Optional[str] = Field(default=None, alias='displayName')
    email: EmailStr
    phone: Optional[str] = None
    avatar_url: Optional[str] = Field(default=None, alias='avatarUrl')
    role: str = 'goer'
    status: str = 'active'
    goer_preferences: Optional[GoerPreferences] = None
    business_profile: Optional[BusinessProfileSummary] = None
    host_credibility: Optional[HostCredibilitySummary] = None
    is_active: bool
    created_at: datetime
    updated_at: Optional[datetime] = None

    @field_validator('role', mode='before')
    def normalize_role(cls, value):
        return value or 'goer'


class UserUpdate(CamelModel):
    username: Optional[str] = None
    display_name: Optional[str] = Field(default=None, alias='displayName')
    email: Optional[EmailStr] = None
    password: Optional[str] = None
    phone: Optional[str] = None
    avatar_url: Optional[str] = Field(default=None, alias='avatarUrl')
    role: Optional[str] = None
    status: Optional[str] = None
    goer_preferences: Optional[GoerPreferences] = None
    business_profile: Optional[BusinessProfileSummary] = None
    host_credibility: Optional[HostCredibilitySummary] = None
