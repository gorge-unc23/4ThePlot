from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import events, comments as comments_router, registration as registration_router, user as user_router, authentication as authentication_router
from models import event, comments, registration, user
from database import engine, Base

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)

@app.get('/')
def main_page():
    return {'data': 'main-page'}

app.include_router(events.router)
app.include_router(comments_router.router)
app.include_router(registration_router.router)
app.include_router(user_router.router)
app.include_router(authentication_router.router)