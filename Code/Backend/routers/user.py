from fastapi import APIRouter,Depends,File,Request,Response,UploadFile,status,HTTPException
from typing import List, Optional
from pathlib import Path
from uuid import uuid4
from sqlalchemy import or_
from sqlalchemy.orm import Session, joinedload
from schemas.user import UserCreate,UserLogin,UserShow,UserUpdate
from models.user import User
from models.category import Category
from models.goer_preferences import GoerPreferences
from models.business_profile import BusinessProfile
from models.host_credibility import HostCredibility
from models.admin import HostVerificationDocument, HostVerificationRequest
from database import get_db
from passlib.context import CryptContext
from schemas.admin import HostVerificationDocumentShow, HostVerificationDocumentUserCreate, HostVerificationRequestShow
from schemas.user import UserShow
from authentication.oauth2 import get_current_user
from services.audit import AuditLogger, get_audit_logger, serialize_model


router = APIRouter(
    prefix='/user',
    tags=['User']
)

pwd_cxt = CryptContext(schemes=['bcrypt_sha256'], deprecated='auto')
DOCUMENTS_DIR = Path('documents')
ALLOWED_DOCUMENT_EXTENSIONS = {'.pdf'}


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


def host_verification_load_options():
    return (
        joinedload(HostVerificationRequest.host).options(*user_load_options()),
        joinedload(HostVerificationRequest.documents),
    )


def build_document_url(request: Request, filename: str) -> str:
    return str(request.base_url).rstrip('/') + f'/documents/{filename}'


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


# Get all non-admin users
@router.get('/non-admins', status_code=200, response_model=List[UserShow])
def get_non_admin_users(db: Session = Depends(get_db), current_user: UserShow = Depends(get_current_user)):
    users = (
        db.query(User)
        .options(*user_load_options())
        .filter(User.role != 'admin')
        .all()
    )
    return users


# Create current host user's verification request
@router.post('/host-verification', status_code=status.HTTP_201_CREATED, response_model=HostVerificationRequestShow)
def create_my_host_verification_request(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    audit: AuditLogger = Depends(get_audit_logger),
):
    active_request = (
        db.query(HostVerificationRequest)
        .filter(
            HostVerificationRequest.host_user_id == current_user.id,
            HostVerificationRequest.status.in_(['pending', 'pending_documents']),
        )
        .first()
    )
    if active_request:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='You already have an active host verification request')

    verification_request = HostVerificationRequest(
        host_user_id=current_user.id,
        status='pending',
    )
    db.add(verification_request)
    db.commit()
    db.refresh(verification_request)
    audit.log('create', 'HostVerificationRequest', verification_request.id, new_values=serialize_model(verification_request))

    return (
        db.query(HostVerificationRequest)
        .options(*host_verification_load_options())
        .filter(HostVerificationRequest.id == verification_request.id)
        .first()
    )


# Get current host user's verification requests
@router.get('/host-verification', status_code=200, response_model=List[HostVerificationRequestShow])
def get_my_host_verification_requests(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    requests = (
        db.query(HostVerificationRequest)
        .options(*host_verification_load_options())
        .filter(HostVerificationRequest.host_user_id == current_user.id)
        .order_by(HostVerificationRequest.submitted_at.desc())
        .all()
    )
    return requests


@router.post('/host-verification/documents/upload', status_code=status.HTTP_201_CREATED)
async def upload_my_host_verification_document(
    request: Request,
    document: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    audit: AuditLogger = Depends(get_audit_logger),
):
    extension = Path(document.filename or '').suffix.lower()
    if extension not in ALLOWED_DOCUMENT_EXTENSIONS:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Only pdf documents are allowed')

    if document.content_type and document.content_type != 'application/pdf':
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail='Uploaded file must be a PDF')

    DOCUMENTS_DIR.mkdir(parents=True, exist_ok=True)
    filename = f'{uuid4().hex}{extension}'
    file_path = DOCUMENTS_DIR / filename

    contents = await document.read()
    file_path.write_bytes(contents)

    document_url = build_document_url(request, filename)
    audit.log(
        'create',
        'HostVerificationDocumentFile',
        filename,
        new_values={'filename': filename, 'document_url': document_url, 'uploaded_by_user_id': current_user.id},
    )
    return {'documentUrl': document_url}


@router.post('/host-verification/{request_id}/documents', status_code=status.HTTP_201_CREATED, response_model=HostVerificationDocumentShow)
def add_my_host_verification_document(
    request_id: int,
    request: HostVerificationDocumentUserCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    audit: AuditLogger = Depends(get_audit_logger),
):
    verification_request = (
        db.query(HostVerificationRequest)
        .filter(
            HostVerificationRequest.id == request_id,
            HostVerificationRequest.host_user_id == current_user.id,
        )
        .first()
    )
    if not verification_request:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Host verification request with id:{request_id} does not exist')

    document = HostVerificationDocument(
        request_id=request_id,
        document_type=request.document_type,
        document_url=request.document_url,
        status=request.status,
    )
    db.add(document)
    db.commit()
    db.refresh(document)
    audit.log('create', 'HostVerificationDocument', document.id, new_values=serialize_model(document))
    return document


# Delete current host user's verification request
@router.delete('/host-verification/{request_id}', status_code=status.HTTP_204_NO_CONTENT)
def delete_my_host_verification_request(
    request_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    audit: AuditLogger = Depends(get_audit_logger),
):
    verification_request = (
        db.query(HostVerificationRequest)
        .options(joinedload(HostVerificationRequest.documents))
        .filter(
            HostVerificationRequest.id == request_id,
            HostVerificationRequest.host_user_id == current_user.id,
        )
        .first()
    )
    if not verification_request:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Host verification request with id:{request_id} does not exist')

    old_values = serialize_model(verification_request)
    old_values['documents'] = [
        serialize_model(document) for document in verification_request.documents
    ]

    db.delete(verification_request)
    db.commit()
    audit.log('delete', 'HostVerificationRequest', request_id, old_values=old_values)


# Get a specific user
@router.get('/{user_id}', status_code=200, response_model=UserShow)
def get_user(user_id: int, db: Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    user = db.query(User).options(*user_load_options()).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'User with id:{user_id} does not exist!')
    return user

#Create User
@router.post('/',status_code=status.HTTP_201_CREATED)
def create_user(request:UserCreate,db:Session=Depends(get_db), audit: AuditLogger = Depends(get_audit_logger)):
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
    audit.log('create', 'User', new_user.id, new_values=serialize_model(new_user))
    return new_user
    
#Update User
@router.put('/{user_id}',status_code=status.HTTP_202_ACCEPTED)
def update_user(user_id:int,request:UserUpdate, db : Session = Depends(get_db),current_user: UserShow = Depends(get_current_user), audit: AuditLogger = Depends(get_audit_logger)):
    user_record = db.query(User).filter(User.id == user_id).first()
    if not user_record:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'The User with id:{user_id} does not exist')
    old_values = serialize_model(user_record)

    update_data = request.model_dump(exclude_unset=True)
    relationship_updates = {
        'goer_preferences',
        'business_profile',
        'host_credibility',
    }
    for key in relationship_updates:
        update_data.pop(key, None)

    if 'password' in update_data:
        update_data['hashed_password'] = pwd_cxt.hash(update_data.pop('password'))

    if 'status' in update_data:
        update_data['is_active'] = update_data['status'] == 'active'

    for key, value in update_data.items():
        setattr(user_record, key, value)

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
    db.refresh(user_record)
    audit.log('update', 'User', user_record.id, old_values=old_values, new_values=serialize_model(user_record))
    return 'User is updated'
    
#Delete User
@router.delete('/{user_id}',status_code=status.HTTP_204_NO_CONTENT)
def delete_user(user_id:int, db : Session = Depends(get_db),current_user: UserShow = Depends(get_current_user), audit: AuditLogger = Depends(get_audit_logger)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'User with id:{user_id} does not exist!')
    old_values = serialize_model(user)
    db.delete(user)
    db.commit()
    audit.log('delete', 'User', user_id, old_values=old_values)
    
