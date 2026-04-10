from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class RegistrationCreate(BaseModel):
    user_id: int
    event_id: int
    
class ShowRegistration(BaseModel):
    id: int
    user_id: int
    event_id: int
    registered_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True
    