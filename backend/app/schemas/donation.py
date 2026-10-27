from pydantic import BaseModel, Field


class MonetaryDonationIntent(BaseModel):
    amount_mxn: float = Field(gt=0, le=1_000_000)
    provider: str = Field(default="paypal", min_length=2, max_length=32)


class InKindDonationIntent(BaseModel):
    item_type: str = Field(min_length=2, max_length=80)
    quantity: str = Field(min_length=1, max_length=80)
    notes: str | None = Field(default=None, max_length=500)
