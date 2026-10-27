from datetime import datetime
from fastapi import APIRouter, status
from app.schemas.event import EventRegistrationIn, ShelterEventOut

router = APIRouter(prefix="/events", tags=["events"])

_SAMPLE_EVENTS = [
    ShelterEventOut(
        id=1,
        title="Jornada de adopción",
        starts_at=datetime(2026, 10, 10, 11, 0),
        location="Ubicación por confirmar",
        description="Conoce a algunos de nuestros perritos disponibles.",
        event_type="Adopción",
    ),
    ShelterEventOut(
        id=2,
        title="Colecta de alimento",
        starts_at=datetime(2026, 10, 17, 10, 0),
        location="Punto de colecta por confirmar",
        description="Recepción de alimento e insumos para el albergue.",
        event_type="Donación",
    ),
]


@router.get("", response_model=list[ShelterEventOut])
def list_events() -> list[ShelterEventOut]:
    return _SAMPLE_EVENTS


@router.post("/register", status_code=status.HTTP_201_CREATED)
def register_for_event(payload: EventRegistrationIn) -> dict:
    return {"status": "registered_for_prototype", "event_id": payload.event_id}
