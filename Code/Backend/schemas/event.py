from pydantic import BaseModel
from datetime import datetime

class EventCreate(BaseModel):
    title: str
    description: str
    category: str
    status: str
    image_url: str
    address: str
    latitude: float
    longitude: float
    city: str
    event_date: datetime
    price: float
    max_attendees: int
    organizer_id: int
    
class ShowEvent(BaseModel):
    id: int
    title: str
    description: str
    category: str
    status: str
    image_url: str
    address: str
    latitude: float
    longitude: float
    city: str
    event_date: datetime
    price: float
    max_attendees: int
    organizer_id: int
    created_at: datetime
    
    
    class Config:
        from_attributes = True
    
    
    
