from fastapi import APIRouter, status
from app.schemas.donation import InKindDonationIntent, MonetaryDonationIntent

router = APIRouter(prefix="/donations", tags=["donations"])


@router.post("/monetary/intent", status_code=status.HTTP_202_ACCEPTED)
def create_monetary_intent(payload: MonetaryDonationIntent) -> dict:
    # Prototipo: aquí se conectará el SDK/API oficial del proveedor desde el backend.
    # Nunca se recibirán ni almacenarán datos de tarjeta en este endpoint.
    return {
        "status": "provider_not_configured",
        "provider": payload.provider,
        "amount_mxn": payload.amount_mxn,
    }


@router.post("/in-kind", status_code=status.HTTP_201_CREATED)
def register_in_kind_intent(payload: InKindDonationIntent) -> dict:
    return {"status": "registered_for_prototype", "donation": payload.model_dump()}
