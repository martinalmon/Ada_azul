from fastapi import FastAPI
from pydantic import BaseModel, EmailStr

app = FastAPI(title="Ada Azul API", version="0.3.0")

class AdoptionApplicationIn(BaseModel):
    dog_id: int
    full_name: str
    phone: str
    reason: str

class ProfileIn(BaseModel):
    housing_type: str
    daily_time: str
    enjoys_walks: bool
    activity_level: str
    has_other_dogs: bool
    has_cats: bool
    has_children: bool

@app.get('/health')
def health():
    return {'status':'ok'}

@app.post('/profiles')
def save_profile(profile: ProfileIn):
    return {'status':'prototype', 'profile': profile.model_dump()}

@app.post('/adoption-applications')
def create_application(application: AdoptionApplicationIn):
    return {'status':'received', 'application': application.model_dump()}

@app.get('/events')
def events():
    return []

@app.post('/donations/monetary/intent')
def donation_intent():
    return {'status':'provider_pending'}

@app.post('/donations/in-kind')
def in_kind_donation():
    return {'status':'received'}
