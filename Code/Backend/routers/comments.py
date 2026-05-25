from fastapi import APIRouter,Depends,Request,Response,status,HTTPException
from schemas.comments import CommentCreate,ShowComment
from models.comments import Comment
from sqlalchemy.orm import Session, joinedload
from database import get_db
from typing import List, Optional
from schemas.user import UserShow
from authentication.oauth2 import get_current_user
from models.event import Event
from models.recurrence import RecurrenceRule
from services.audit import AuditLogger, get_audit_logger, serialize_model


router = APIRouter(
    prefix='/comments',
    tags=['Comments']
)


def comment_load_options():
    return (
        joinedload(Comment.author),
        joinedload(Comment.event).joinedload(Event.location),
        joinedload(Comment.event).joinedload(Event.capacity),
        joinedload(Comment.event).joinedload(Event.recurrence).joinedload(RecurrenceRule.weekdays),
        joinedload(Comment.event).joinedload(Event.category_links),
        joinedload(Comment.event).joinedload(Event.tag_links),
    )


#Get comments by event
@router.get('/event/{event_id}', status_code=status.HTTP_200_OK, response_model=List[ShowComment])
def get_comments_by_event(event_id: int, db: Session = Depends(get_db), current_user: UserShow = Depends(get_current_user)):
    comments = (
        db.query(Comment)
        .options(*comment_load_options())
        .filter(Comment.event_id == event_id)
        .all()
    )
    return comments


#Get comment
@router.get('/{comment_id}',status_code=status.HTTP_200_OK,response_model=ShowComment)
def get_comments(comment_id:int,db : Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    comment = (
        db.query(Comment)
        .options(*comment_load_options())
        .filter(Comment.id == comment_id)
    )
    if not comment.first():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f'Comment with id:{comment_id} is not found')
    return comment.first()

@router.post('/',status_code=status.HTTP_201_CREATED, response_model=ShowComment)
def post_comment(request:CommentCreate, db : Session = Depends(get_db),current_user: UserShow = Depends(get_current_user), audit: AuditLogger = Depends(get_audit_logger)):
    new_comment = Comment(
        user_id = request.user_id,
        event_id = request.event_id,
        text = request.text
    )
    db.add(new_comment)
    db.commit()
    db.refresh(new_comment)
    audit.log('create', 'Comment', new_comment.id, new_values=serialize_model(new_comment))
    return (
        db.query(Comment)
        .options(*comment_load_options())
        .filter(Comment.id == new_comment.id)
        .first()
    )

@router.delete('/{comment_id}',status_code=status.HTTP_204_NO_CONTENT)
def delete_comment(comment_id:int, db : Session = Depends(get_db),current_user: UserShow = Depends(get_current_user), audit: AuditLogger = Depends(get_audit_logger)):
    comment = db.query(Comment).filter(Comment.id == comment_id).first()
    if not comment:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Comment with id:{comment_id} is not found!')
    old_values = serialize_model(comment)
    db.delete(comment)
    db.commit()
    audit.log('delete', 'Comment', comment_id, old_values=old_values)
