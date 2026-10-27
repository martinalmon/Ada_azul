from datetime import datetime
from pydantic import BaseModel, Field


class ShelterEventOut(BaseModel):
    id: int
    title: str
    starts_at: datetime
    location: str
    description: str
    event_type: str


class EventRegistrationIn(BaseModel):
    event_id: int = Field(gt=0)
