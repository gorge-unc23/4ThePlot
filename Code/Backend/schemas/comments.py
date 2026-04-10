from pydantic import BaseModel

class CommentCreate(BaseModel):
    user_id: int
    event_id: int
    text: str
    
class ShowComment(BaseModel):
    user_id: int 
    event_id: int
    text: str
    
    class Config:
        from_attributes = True
