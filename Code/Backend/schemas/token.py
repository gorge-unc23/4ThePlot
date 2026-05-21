from pydantic import BaseModel
from schemas.user import UserShow

class Token(BaseModel):
    access_token: str
    token_type: str


class LoginResponse(Token):
    user: UserShow


class TokenData(BaseModel):
    email: str | None = None
