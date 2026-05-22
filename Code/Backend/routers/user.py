from fastapi import APIRouter,Depends,Request,Response,status,HTTPException
from typing import List, Optional
from sqlalchemy import or_
from sqlalchemy.orm import Session, joinedload
from schemas.user import UserCreate,UserLogin,UserShow,UserUpdate
from models.user import User
from models.category import Category
from models.goer_preferences import GoerPreferences
from models.business_profile import BusinessProfile
from models.host_credibility import HostCredibility
from database import get_db
from passlib.context import CryptContext
from schemas.user import UserShow
from authentication.oauth2 import get_current_user


router = APIRouter(
    prefix='/user',
    tags=['User']
)

pwd_cxt = CryptContext(schemes=['bcrypt_sha256'], deprecated='auto')


def get_or_create_category(name: str, db: Session) -> Category:
    category = db.query(Category).filter(Category.name == name).first()
    if category:
        return category
    category = Category(name=name)
    db.add(category)
    db.flush()
    return category


def user_load_options():
    return (
        joinedload(User.goer_preferences),
        joinedload(User.business_profile),
        joinedload(User.host_credibility),
    )


# Get not trusted users
@router.get('/not-trusted', status_code=200, response_model=List[UserShow])
def get_not_trusted_users(db: Session = Depends(get_db), current_user: UserShow = Depends(get_current_user)):
    users = (
        db.query(User)
        .outerjoin(User.host_credibility)
        .options(*user_load_options())
        .filter(
            or_(
                HostCredibility.trusted == False,
                HostCredibility.trusted.is_(None),
            )
        )
        .all()
    )
    return users


# Get a specific user
@router.get('/{user_id}', status_code=200, response_model=UserShow)
def get_user(user_id: int, db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    user = db.query(User).options(*user_load_options()).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'User with id:{user_id} does not exist!')
    return user

#Create User
@router.post('/',status_code=status.HTTP_201_CREATED)
def create_user(request:UserCreate,db:Session=Depends(get_db)):
    hashedPassword = pwd_cxt.hash(request.password)
    display_name = request.display_name or request.username
    user_data = {
        'username': request.username,
        'display_name': display_name,
        'email': request.email,
        'hashed_password': hashedPassword,
        'phone': request.phone,
        'avatar_url': request.avatar_url,
        'role': request.role,
        'status': request.status,
        'is_active': request.status == 'active',
    }
    user_data = {key: value for key, value in user_data.items() if value is not None}
    new_user = User(**user_data)

    if request.goer_preferences:
        preference = GoerPreferences()
        preference.categories = [
            get_or_create_category(name, db) for name in request.goer_preferences.categories
        ]
        new_user.goer_preferences = preference

    if request.business_profile:
        profile = request.business_profile
        new_user.business_profile = BusinessProfile(
            name=profile.name,
            description=profile.description,
            website_url=profile.website_url,
            logo_url=profile.logo_url,
            is_published=profile.is_published,
        )

    if request.host_credibility:
        credibility = request.host_credibility
        new_user.host_credibility = HostCredibility(
            rating=credibility.rating,
            review_count=credibility.review_count,
            trusted=credibility.trusted,
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
    update_data = request.model_dump(exclude_unset=True)
    if 'password' in update_data:
        update_data['hashed_password'] = pwd_cxt.hash(update_data.pop('password'))

    if 'status' in update_data:
        update_data['is_active'] = update_data['status'] == 'active'

    user.update(update_data)
    user_record = user.first()

    if request.goer_preferences is not None:
        if user_record.goer_preferences is None:
            user_record.goer_preferences = GoerPreferences(user_id=user_id)
        user_record.goer_preferences.categories = [
            get_or_create_category(name, db) for name in request.goer_preferences.categories
        ]

    if request.business_profile is not None:
        if user_record.business_profile is None:
            user_record.business_profile = BusinessProfile(user_id=user_id, name=request.business_profile.name)
        user_record.business_profile.name = request.business_profile.name
        user_record.business_profile.description = request.business_profile.description
        user_record.business_profile.website_url = request.business_profile.website_url
        user_record.business_profile.logo_url = request.business_profile.logo_url
        user_record.business_profile.is_published = request.business_profile.is_published

    if request.host_credibility is not None:
        if user_record.host_credibility is None:
            user_record.host_credibility = HostCredibility(user_id=user_id)
        user_record.host_credibility.rating = request.host_credibility.rating
        user_record.host_credibility.review_count = request.host_credibility.review_count
        user_record.host_credibility.trusted = request.host_credibility.trusted

    db.commit()
    return 'User is updated'
    
#Delete User
@router.delete('/{user_id}',status_code=status.HTTP_204_NO_CONTENT)
def delete_user(user_id:int, db : Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    user = db.query(User).filter(User.id == user_id)
    if not user.first():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'User with id:{user_id} does not exist!')
    user.delete(synchronize_session=False)
    db.commit()
    

