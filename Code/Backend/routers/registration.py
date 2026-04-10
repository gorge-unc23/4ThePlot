from fastapi import APIRouter,Depends,Request,Response,status,HTTPException
from sqlalchemy.orm import Session
from typing import Optional
from schemas.registration import RegistrationCreate,ShowRegistration
from models.registration import Registration
from database import get_db
from schemas.user import UserShow
from authentication.oauth2 import get_current_user


router = APIRouter(
    prefix='/registration',
    tags=['Registrations']
)

#Create Registration
@router.post('/', status_code=status.HTTP_201_CREATED,response_model=ShowRegistration)
def create_registration(request : RegistrationCreate, db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    new_registration = Registration(
        user_id       = request.user_id,
        event_id      = request.event_id
    )
    db.add(new_registration)
    db.commit()
    db.refresh(new_registration)
    return new_registration

@router.delete('/{registration_id}',status_code=status.HTTP_204_NO_CONTENT)
def delete_event(registration_id:int, db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    registration = db.query(Registration).filter(Registration.id == registration_id)
    if not registration.first():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Registration with id:{registration_id} does not exist')
    registration.delete(synchronize_session=False)
    db.commit()
