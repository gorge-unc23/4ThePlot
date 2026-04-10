from fastapi import APIRouter, Depends, Request, Response, status, HTTPException
from sqlalchemy.orm import Session
from typing import Optional, List
from schemas.login import Login
from schemas.token import Token
from database import get_db
from models.user import User
import authentication.token as token
from passlib.context import CryptContext
from fastapi.security import OAuth2PasswordRequestForm

Hash = CryptContext(schemes=['bcrypt'], deprecated='auto')

router = APIRouter(
    prefix='/login',
    tags=['Authentication']
)

@router.post('/')
def login(request: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == request.username).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Invalid Credentials')
    if not Hash.verify(request.password, user.hashed_password):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail='Incorrect password')
    
    access_token =token.create_access_token(data={"sub": user.email})
    return Token(access_token=access_token, token_type="bearer")