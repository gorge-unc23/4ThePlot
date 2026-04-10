from fastapi import APIRouter, Depends, Request, Response, status, HTTPException
from sqlalchemy.orm import Session
from typing import Optional,List
from schemas.event import EventCreate,ShowEvent
from schemas.user import UserShow
from models.event import Event
from database import get_db
from math import radians, sin, cos, sqrt, atan2
from authentication.oauth2 import get_current_user


router = APIRouter(
    prefix='/events',
    tags=['Events']
)

def haversine(lat1, lon1, lat2, lon2):
    R = 6371
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * atan2(sqrt(a), sqrt(1-a))
    return R * c

#Get all events
@router.get('/',response_model=List[ShowEvent])
def all(db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    events = db.query(Event).all()
    return events

#Get an event with a particular ID
@router.get('/{event_id}', status_code=200,response_model=ShowEvent,)
def show(event_id: int, response: Response, db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    event = db.query(Event).filter(Event.id == event_id).first()
    if not event:
        response.status_code = status.HTTP_404_NOT_FOUND
        return {'detail': f'Event with id {event_id} is not available'}
    return event

#Create an Event
@router.post('/', status_code=201,response_model=ShowEvent)
def create_event(request: EventCreate, db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    new_event = Event(
        title=request.title,
        description=request.description,
        category=request.category,
        status=request.status,
        image_url=request.image_url,
        address=request.address,
        latitude=request.latitude,
        longitude=request.longitude,
        city=request.city,
        event_date=request.event_date,
        price=request.price,
        max_attendees=request.max_attendees,
        organizer_id=request.organizer_id,
    )
    db.add(new_event)
    db.commit()
    db.refresh(new_event)
    return new_event


#Update Event
@router.put('/{event_id}', status_code=status.HTTP_202_ACCEPTED)
def update_event(event_id: int, request: EventCreate, db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    event = db.query(Event).filter(Event.id == event_id)
    if not event.first():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Event with id {event_id} does not exist.')
    event.update(request.model_dump())
    db.commit()
    return 'The event is updated.'

#Delete Event
@router.delete('/{event_id}', status_code=status.HTTP_204_NO_CONTENT)
def delete_event(event_id: int, db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    event = db.query(Event).filter(Event.id == event_id)
    if not event.first():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Event with id {event_id} does not exist.')
    event.delete(synchronize_session=False)
    db.commit()

#Events near a location
@router.get('/nearby/search',response_model=List[ShowEvent])
def get_events_near_location(lat: float, lng: float, radius: float = 10, db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    all_events = db.query(Event).all()
    nearby = []
    for event in all_events:
        distance = haversine(lat, lng, event.latitude, event.longitude)
        if distance <= radius:
            nearby.append(event)
    return nearby