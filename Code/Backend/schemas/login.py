from pydantic import BaseModel
from datetime import datetime

class Login(BaseModel):
    username: str
    password: str