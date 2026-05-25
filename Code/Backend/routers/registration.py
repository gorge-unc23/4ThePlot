from fastapi import APIRouter,Depends,Request,Response,status,HTTPException
from sqlalchemy.orm import Session, joinedload
from typing import List, Optional
from schemas.registration import RegistrationCreate,ShowRegistration
from models.registration import Registration
from models.event import Event
from models.event_capacity import EventCapacity
from models.recurrence import RecurrenceRule
from database import get_db
from schemas.user import UserShow
from authentication.oauth2 import get_current_user
from services.audit import AuditLogger, get_audit_logger, serialize_model


router = APIRouter(
    prefix='/registration',
    tags=['Registrations']
)


def registration_load_options():
    return (
        joinedload(Registration.user),
        joinedload(Registration.event).joinedload(Event.location),
        joinedload(Registration.event).joinedload(Event.capacity),
        joinedload(Registration.event).joinedload(Event.recurrence).joinedload(RecurrenceRule.weekdays),
        joinedload(Registration.event).joinedload(Event.category_links),
        joinedload(Registration.event).joinedload(Event.tag_links),
    )

#Create Registration
@router.post('/', status_code=status.HTTP_201_CREATED,response_model=ShowRegistration)
def create_registration(request : RegistrationCreate, db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user), audit: AuditLogger = Depends(get_audit_logger)):
    event = db.query(Event).filter(Event.id == request.event_id).first()
    if not event:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Event with id:{request.event_id} does not exist')

    capacity = db.query(EventCapacity).filter(EventCapacity.event_id == request.event_id).first()
    if capacity is None:
        capacity = EventCapacity(event_id=request.event_id, confirmed_attendees=0)
        db.add(capacity)

    confirmed_attendees = capacity.confirmed_attendees or 0
    if capacity.max_attendees is not None and confirmed_attendees >= capacity.max_attendees:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail='Event capacity is full',
        )

    capacity.confirmed_attendees = confirmed_attendees + 1

    new_registration = Registration(
        user_id       = request.user_id,
        event_id      = request.event_id
    )
    db.add(new_registration)
    db.commit()
    db.refresh(new_registration)
    audit.log('create', 'Registration', new_registration.id, new_values=serialize_model(new_registration))
    return (
        db.query(Registration)
        .options(*registration_load_options())
        .filter(Registration.id == new_registration.id)
        .first()
    )


#Get all registrations of a user
@router.get('/user/{user_id}', response_model=List[ShowRegistration])
def get_user_registrations(user_id: int, db: Session = Depends(get_db), current_user: UserShow = Depends(get_current_user)):
    registrations = (
        db.query(Registration)
        .options(*registration_load_options())
        .filter(Registration.user_id == user_id)
        .all()
    )
    return registrations


#Get registrations for a user and event
@router.get('/user/{user_id}/event/{event_id}', response_model=List[ShowRegistration])
def get_user_event_registration(user_id: int, event_id: int, db: Session = Depends(get_db), current_user: UserShow = Depends(get_current_user)):
    registrations = (
        db.query(Registration)
        .options(*registration_load_options())
        .filter(
            Registration.user_id == user_id,
            Registration.event_id == event_id,
        )
        .all()
    )
    return registrations


@router.delete('/{registration_id}',status_code=status.HTTP_204_NO_CONTENT)
def delete_event(registration_id:int, db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user), audit: AuditLogger = Depends(get_audit_logger)):
    registration = db.query(Registration).filter(Registration.id == registration_id).first()
    if not registration:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Registration with id:{registration_id} does not exist')
    old_values = serialize_model(registration)

    capacity = db.query(EventCapacity).filter(EventCapacity.event_id == registration.event_id).first()
    if capacity:
        capacity.confirmed_attendees = max((capacity.confirmed_attendees or 0) - 1, 0)

    db.delete(registration)
    db.commit()
    audit.log('delete', 'Registration', registration_id, old_values=old_values)
