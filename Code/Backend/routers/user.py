from fastapi import APIRouter,Depends,Request,Response,status,HTTPException
from typing import Optional
from sqlalchemy.orm import Session
from schemas.user import UserCreate,UserLogin,UserShow,UserUpdate
from models.user import User
from database import get_db
from passlib.context import CryptContext
from schemas.user import UserShow
from authentication.oauth2 import get_current_user


router = APIRouter(
    prefix='/user',
    tags=['User']
)

pwd_cxt = CryptContext(schemes=['bcrypt'], deprecated = 'auto')

# Get a specific user
@router.get('/{user_id}', status_code=200, response_model=UserShow)
def get_user(user_id: int, db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'User with id:{user_id} does not exist!')
    return user

#Create User
@router.post('/',status_code=status.HTTP_201_CREATED)
def create_user(request:UserCreate,db:Session=Depends(get_db)):
    hashedPassword = pwd_cxt.hash(request.password)
    new_user = User(
        username = request.username,
        email = request.email,
        hashed_password=hashedPassword
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user
    
#Update User
@router.put('/{user_id}',status_code=status.HTTP_202_ACCEPTED)
def update_user(user_id:int,request:UserUpdate, db : Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    user = db.query(User).filter(User.id == user_id)
    if not user.first():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'The User with id:{user_id} does not exist')
    user.update(request.model_dump())
    db.commit()
    return 'Event is updated'
    
#Delete User
@router.delete('/{user_id}',status_code=status.HTTP_204_NO_CONTENT)
def delete_user(user_id:int, db : Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    user = db.query(User).filter(User.id == user_id)
    if not user.first():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'User with id:{user_id} does not exist!')
    user.delete(synchronize_session=False)
    db.commit()
    

