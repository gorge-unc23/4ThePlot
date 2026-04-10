from fastapi import APIRouter,Depends,Request,Response,status,HTTPException
from schemas.comments import CommentCreate,ShowComment
from models.comments import Comment
from sqlalchemy.orm import Session
from database import get_db
from typing import Optional
from schemas.user import UserShow
from authentication.oauth2 import get_current_user


router = APIRouter(
    prefix='/comments',
    tags=['Comments']
)

#Get comment
@router.get('/{comment_id}',status_code=status.HTTP_200_OK,response_model=ShowComment)
def get_comments(comment_id:int,db : Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    comment = db.query(Comment).filter(Comment.id == comment_id)
    if not comment.first():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,detail=f'Comment with id:{comment_id} is not found')
    return comment.first()

@router.post('/',status_code=status.HTTP_201_CREATED, response_model=ShowComment)
def post_comment(request:CommentCreate, db : Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    new_comment = Comment(
        user_id = request.user_id,
        event_id = request.event_id,
        text = request.text
    )
    db.add(new_comment)
    db.commit()
    db.refresh(new_comment)
    return new_comment

@router.delete('/{comment_id}',status_code=status.HTTP_204_NO_CONTENT)
def delete_comment(comment_id:int, db : Session = Depends(get_db),current_user: UserShow = Depends(get_current_user)):
    comment = db.query(Comment).filter(Comment.id == comment_id)
    if not comment.first():
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f'Comment with id:{comment_id} is not found!')
    comment.delete(synchronize_session=False)
    db.commit()