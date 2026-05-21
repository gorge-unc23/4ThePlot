from fastapi import APIRouter, Depends, File, Request, Response, UploadFile, status, HTTPException
from sqlalchemy import or_
from sqlalchemy.orm import Session, joinedload
from typing import Optional,List
from pathlib import Path
from uuid import uuid4
from schemas.event import EventCreate, ShowEvent
from schemas.user import UserShow
from models.event import Event
from models.event_location import EventLocation
from models.event_capacity import EventCapacity
from models.recurrence import RecurrenceRule, RecurrenceWeekday
from models.registration import Registration
from models.category import Category
from models.tag import Tag
from database import get_db
from math import radians, sin, cos, sqrt, atan2
from authentication.oauth2 import get_current_user


router = APIRouter(
    prefix='/events',
    tags=['Events']
)

PHOTOS_DIR = Path('photos')
ALLOWED_IMAGE_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.webp'}

def haversine(lat1, lon1, lat2, lon2):
    R = 6371
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1
    a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
    c = 2 * atan2(sqrt(a), sqrt(1-a))
    return R * c


def get_or_create_category(name: str, db: Session) -> Category:
    category = db.query(Category).filter(Category.name == name).first()
    if category:
        return category
    category = Category(name=name)
    db.add(category)
    db.flush()
    return category


def get_or_create_tag(name: str, db: Session) -> Tag:
    tag = db.query(Tag).filter(Tag.name == name).first()
    if tag:
        return tag
    tag = Tag(name=name)
    db.add(tag)
    db.flush()
    return tag


def build_photo_url(request: Request, filename: str) -> str:
    return str(request.base_url).rstrip('/') + f'/photos/{filename}'

#Get all events
@router.get('/',response_model=List[ShowEvent])
def all(db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    events = (
        db.query(Event)
        .options(
            joinedload(Event.location),
            joinedload(Event.capacity),
            joinedload(Event.recurrence).joinedload(RecurrenceRule.weekdays),
            joinedload(Event.category_links),
            joinedload(Event.tag_links),
        )
        .all()
    )
    return events


#Get trending events
@router.get('/trending', response_model=List[ShowEvent])
def trending_events(db: Session = Depends(get_db), current_user: UserShow = Depends(get_current_user)):
    events = (
        db.query(Event)
        .options(
            joinedload(Event.location),
            joinedload(Event.capacity),
            joinedload(Event.recurrence).joinedload(RecurrenceRule.weekdays),
            joinedload(Event.category_links),
            joinedload(Event.tag_links),
        )
        .filter(Event.trending == True)
        .all()
    )
    return events


#Upload an event photo
@router.post('/photos', status_code=status.HTTP_201_CREATED)
async def upload_event_photo(request: Request, photo: UploadFile = File(...), current_user: UserShow = Depends(get_current_user)):
    extension = Path(photo.filename or '').suffix.lower()
    if extension not in ALLOWED_IMAGE_EXTENSIONS:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail='Only jpg, jpeg, png, and webp images are allowed',
        )

    if photo.content_type and not photo.content_type.startswith('image/'):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Uploaded file must be an image')

    PHOTOS_DIR.mkdir(parents=True, exist_ok=True)
    filename = f'{uuid4().hex}{extension}'
    file_path = PHOTOS_DIR / filename

    contents = await photo.read()
    file_path.write_bytes(contents)

    return {'coverImageUrl': build_photo_url(request, filename)}


#Search events by title, venue, or city
@router.get('/search', response_model=List[ShowEvent])
def search_events(q: str, db: Session = Depends(get_db), current_user: UserShow = Depends(get_current_user)):
    search_text = q.strip()
    if not search_text:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Search query cannot be empty')

    pattern = f'%{search_text}%'
    events = (
        db.query(Event)
        .outerjoin(Event.location)
        .options(
            joinedload(Event.location),
            joinedload(Event.capacity),
            joinedload(Event.recurrence).joinedload(RecurrenceRule.weekdays),
            joinedload(Event.category_links),
            joinedload(Event.tag_links),
        )
        .filter(
            or_(
                Event.title.ilike(pattern),
                EventLocation.venue_name.ilike(pattern),
                EventLocation.city.ilike(pattern),
            )
        )
        .all()
    )
    return events


#Events near a location
@router.get('/nearby/search', response_model=List[ShowEvent])
def get_events_near_location(lat: float, lng: float, radius: float = 10, db: Session = Depends(get_db), current_user: UserShow = Depends(get_current_user)):
    all_events = (
        db.query(Event)
        .options(
            joinedload(Event.location),
            joinedload(Event.capacity),
            joinedload(Event.recurrence).joinedload(RecurrenceRule.weekdays),
            joinedload(Event.category_links),
            joinedload(Event.tag_links),
        )
        .all()
    )
    nearby = []
    for event in all_events:
        if not event.location or event.location.latitude is None or event.location.longitude is None:
            continue
        distance = haversine(lat, lng, event.location.latitude, event.location.longitude)
        if distance <= radius:
            nearby.append(event)
    return nearby


#Get events in a city
@router.get('/city/{city}', response_model=List[ShowEvent])
def get_events_by_city(city: str, db: Session = Depends(get_db), current_user: UserShow = Depends(get_current_user)):
    city_text = city.strip()
    if not city_text:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='City cannot be empty')

    events = (
        db.query(Event)
        .join(Event.location)
        .options(
            joinedload(Event.location),
            joinedload(Event.capacity),
            joinedload(Event.recurrence).joinedload(RecurrenceRule.weekdays),
            joinedload(Event.category_links),
            joinedload(Event.tag_links),
        )
        .filter(EventLocation.city.ilike(city_text))
        .all()
    )
    return events


#Get events a user registered to
@router.get('/registered/{user_id}', response_model=List[ShowEvent])
def get_registered_events(user_id: int, db: Session = Depends(get_db), current_user: UserShow = Depends(get_current_user)):
    events = (
        db.query(Event)
        .join(Registration, Registration.event_id == Event.id)
        .options(
            joinedload(Event.location),
            joinedload(Event.capacity),
            joinedload(Event.recurrence).joinedload(RecurrenceRule.weekdays),
            joinedload(Event.category_links),
            joinedload(Event.tag_links),
        )
        .filter(Registration.user_id == user_id)
        .all()
    )
    return events


#Get events created by a host
@router.get('/host/{host_id}', response_model=List[ShowEvent])
def get_events_by_host(host_id: int, db: Session = Depends(get_db), current_user: UserShow = Depends(get_current_user)):
    events = (
        db.query(Event)
        .options(
            joinedload(Event.location),
            joinedload(Event.capacity),
            joinedload(Event.recurrence).joinedload(RecurrenceRule.weekdays),
            joinedload(Event.category_links),
            joinedload(Event.tag_links),
        )
        .filter(Event.organizer_id == host_id)
        .all()
    )
    return events


#Get events created by a host in a city
@router.get('/host/{host_id}/city/{city}', response_model=List[ShowEvent])
def get_events_by_host_and_city(host_id: int, city: str, db: Session = Depends(get_db), current_user: UserShow = Depends(get_current_user)):
    city_text = city.strip()
    if not city_text:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='City cannot be empty')

    events = (
        db.query(Event)
        .join(Event.location)
        .options(
            joinedload(Event.location),
            joinedload(Event.capacity),
            joinedload(Event.recurrence).joinedload(RecurrenceRule.weekdays),
            joinedload(Event.category_links),
            joinedload(Event.tag_links),
        )
        .filter(
            Event.organizer_id == host_id,
            EventLocation.city.ilike(city_text),
        )
        .all()
    )
    return events


#Get an event with a particular ID
@router.get('/{event_id}', status_code=200,response_model=ShowEvent,)
def show(event_id: int, response: Response, db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    event = (
        db.query(Event)
        .options(
            joinedload(Event.location),
            joinedload(Event.capacity),
            joinedload(Event.recurrence).joinedload(RecurrenceRule.weekdays),
            joinedload(Event.category_links),
            joinedload(Event.tag_links),
        )
        .filter(Event.id == event_id)
        .first()
    )
    if not event:
        response.status_code = status.HTTP_404_NOT_FOUND
        return {'detail': f'Event with id {event_id} is not available'}
    return event

#Create an Event
@router.post('/', status_code=201,response_model=ShowEvent)
def create_event(request: EventCreate, db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    start_at = request.start_at or request.event_date
    if start_at is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='startAt is required')

    end_at = request.end_at or start_at
    if end_at and end_at < start_at:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='endAt must be after startAt')

    new_event = Event(
        title=request.title,
        description=request.description,
        status=request.status,
        image_url=request.image_url,
        start_at=start_at,
        end_at=end_at,
        price=request.price,
        currency=request.currency,
        trending=request.trending,
        organizer_id=request.organizer_id,
        host_name=request.host_name,
    )
    db.add(new_event)
    db.commit()
    db.refresh(new_event)

    location = request.location
    new_event.location = EventLocation(
        event_id=new_event.id,
        address=location.address if location else (request.address or ''),
        venue_name=location.venue_name if location else request.venue_name,
        latitude=location.latitude if location else request.latitude,
        longitude=location.longitude if location else request.longitude,
        city=location.city if location else request.city,
    )

    capacity = request.capacity
    new_event.capacity = EventCapacity(
        event_id=new_event.id,
        max_attendees=capacity.max_attendees if capacity else request.max_attendees,
        confirmed_attendees=capacity.confirmed_attendees if capacity else 0,
        waitlist_enabled=capacity.waitlist_enabled if capacity else False,
    )

    if request.recurrence:
        rule = RecurrenceRule(
            event_id=new_event.id,
            frequency=request.recurrence.frequency,
            interval=request.recurrence.interval,
            end_date=request.recurrence.end_date,
            count=request.recurrence.count,
        )
        if request.recurrence.by_weekday:
            rule.weekdays = [
                RecurrenceWeekday(weekday=weekday) for weekday in request.recurrence.by_weekday
            ]
        new_event.recurrence = rule

    categories = request.categories
    if not categories and request.category:
        categories = [request.category]
    new_event.category_links = [get_or_create_category(name, db) for name in categories]
    new_event.tag_links = [get_or_create_tag(name, db) for name in request.tags]

    db.commit()
    db.refresh(new_event)
    return new_event


#Update Event
@router.put('/{event_id}', status_code=status.HTTP_202_ACCEPTED)
def update_event(event_id: int, request: EventCreate, db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    event = (
        db.query(Event)
        .options(
            joinedload(Event.location),
            joinedload(Event.capacity),
            joinedload(Event.recurrence).joinedload(RecurrenceRule.weekdays),
            joinedload(Event.category_links),
            joinedload(Event.tag_links),
        )
        .filter(Event.id == event_id)
        .first()
    )
    if not event:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Event with id {event_id} does not exist.')

    start_at = request.start_at or request.event_date
    if start_at is None:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='startAt is required')

    end_at = request.end_at or start_at
    if end_at and end_at < start_at:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='endAt must be after startAt')

    event.title = request.title
    event.description = request.description
    event.status = request.status
    event.image_url = request.image_url
    event.start_at = start_at
    event.end_at = end_at
    event.price = request.price
    event.currency = request.currency
    event.trending = request.trending
    event.organizer_id = request.organizer_id
    event.host_name = request.host_name

    location = request.location
    if event.location is None:
        event.location = EventLocation(event_id=event.id, address='')
    event.location.address = location.address if location else (request.address or '')
    event.location.venue_name = location.venue_name if location else request.venue_name
    event.location.latitude = location.latitude if location else request.latitude
    event.location.longitude = location.longitude if location else request.longitude
    event.location.city = location.city if location else request.city

    capacity = request.capacity
    if event.capacity is None:
        event.capacity = EventCapacity(event_id=event.id)
    event.capacity.max_attendees = capacity.max_attendees if capacity else request.max_attendees
    event.capacity.confirmed_attendees = capacity.confirmed_attendees if capacity else 0
    event.capacity.waitlist_enabled = capacity.waitlist_enabled if capacity else False

    if request.recurrence:
        if event.recurrence is None:
            event.recurrence = RecurrenceRule(event_id=event.id)
        event.recurrence.frequency = request.recurrence.frequency
        event.recurrence.interval = request.recurrence.interval
        event.recurrence.end_date = request.recurrence.end_date
        event.recurrence.count = request.recurrence.count
        event.recurrence.weekdays = [
            RecurrenceWeekday(weekday=weekday) for weekday in (request.recurrence.by_weekday or [])
        ]
    else:
        event.recurrence = None

    categories = request.categories
    if not categories and request.category:
        categories = [request.category]
    event.category_links = [get_or_create_category(name, db) for name in categories]
    event.tag_links = [get_or_create_tag(name, db) for name in request.tags]

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

