import os
from typing import Literal
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(title="FitPilot AI API", version="0.1.0")

class Profile(BaseModel):
    name: str = ""
    age: int = Field(ge=13, le=100)
    height_cm: float = Field(gt=0, le=250)
    weight_kg: float = Field(gt=0, le=350)
    daily_food_budget_inr: float = Field(ge=0, le=10000)
    diet_preference: Literal["Vegetarian", "Non-vegetarian", "Vegan", "Eggetarian"]
    goal: str = "General fitness"

@app.get("/health")
def health():
    return {"status": "ok", "service": "FitPilot AI"}

@app.post("/plan")
def create_plan(profile: Profile):
    # Safe starter response: no weight-loss prescriptions, calorie restriction,
    # or body-image judgments. AI provider integration is intentionally opt-in.
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        return {"plan": (
            "Demo starter plan\\n\\n"
            "• Build regular meals around familiar foods and include a protein source.\\n"
            "• Choose enjoyable movement you can do consistently; start gently and learn technique.\\n"
            "• Include rest days, hydration and adequate sleep.\\n"
            "• Use your budget to plan affordable staples such as dal, beans, curd, eggs "
            "(if suitable), seasonal vegetables and grains.\\n\\n"
            "This is general education, not a personalized medical or weight-loss prescription. "
            "For users under 18, involve a parent/guardian and qualified professional."
        )}
    # Connect an AI provider here on the server only. Never put API keys in the Android app.
    return {"plan": "AI key detected. Provider integration is the next implementation step."}

@app.post("/chat")
def chat(payload: dict):
    message = str(payload.get("message", "")).strip()
    if not message:
        raise HTTPException(status_code=400, detail="Message is required")
    return {"reply": "Coach demo: I can explain general nutrition and safe exercise principles. For personal medical advice, consult a qualified professional."}
