# app/routers/judgment_predictor.py

import logging
import json
import requests
from fastapi import APIRouter, Depends, HTTPException

# Import models and security dependencies
from app.models.schemas import PredictionInput, PredictionResponse
from app.core.security import authenticate_user
from app.core.config import GEMINI_API_KEY

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/predict",
    tags=["Judgment Prediction Engine"],
)

@router.post("/outcome", response_model=PredictionResponse)
async def predict_judgment_outcome(
    prediction_input: PredictionInput,
    current_user: dict = Depends(authenticate_user)
):
    """
    Accepts a case summary and uses an AI model to predict the likely outcome.
    """
    user_uid = current_user.get("uid")
    logger.info(f"Received judgment prediction request from user: {user_uid}")

    prompt = create_prediction_prompt(prediction_input.case_summary)
    
    try:
        api_key = GEMINI_API_KEY
        if not api_key:
            raise HTTPException(status_code=500, detail="AI Service is not configured.")

        # Define the expected JSON schema for the AI's response
        response_schema = {
            "type": "OBJECT",
            "properties": {
                "predicted_outcome": {"type": "STRING"},
                "confidence_score": {"type": "INTEGER"},
                "reasoning": {"type": "STRING"}
            },
            "required": ["predicted_outcome", "confidence_score", "reasoning"]
        }

        payload = {
            "contents": [{"role": "user", "parts": [{"text": prompt}]}],
            "generationConfig": {
                "responseMimeType": "application/json",
                "responseSchema": response_schema
            }
        }
        
        api_url = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key={api_key}"
        
        response = requests.post(api_url, headers={'Content-Type': 'application/json'}, json=payload)
        response.raise_for_status()
        result = response.json()

        json_response_str = result["candidates"][0]["content"]["parts"][0]["text"]
        ai_response_data = json.loads(json_response_str)

        return PredictionResponse(
            message="Judgment prediction generated successfully.",
            **ai_response_data
        )

    except Exception as e:
        logger.error(f"An unexpected error occurred during judgment prediction for user {user_uid}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"An internal error occurred: {e}")


def create_prediction_prompt(case_summary: str) -> str:
    """Creates a standardized prompt for the judgment prediction task."""
    return f"""
    You are ArguMate, an AI legal analyst that simulates a machine learning model trained on thousands of Indian court cases.
    Your task is to predict the likely outcome of a case based on its summary.
    The response MUST be a single, valid JSON object.

    The JSON object must have three keys: "predicted_outcome", "confidence_score", and "reasoning".

    1. "predicted_outcome": The most likely judgment. Must be one of "Conviction" (Doshi), "Acquittal" (Nirdosh), or "Settlement" (Samjhauta).
    2. "confidence_score": An integer from 0 to 100 representing your confidence in this prediction.
    3. "reasoning": A brief, data-driven explanation for your prediction, citing key facts from the summary.

    Analyze the following case summary and predict the outcome:
    ---
    {case_summary}
    ---
    """
