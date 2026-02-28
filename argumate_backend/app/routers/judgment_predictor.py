import logging
import json
import requests
from fastapi import APIRouter, Depends, HTTPException

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
    Accepts a case summary and uses OpenRouter (Gemini Model) to predict the likely outcome.
    """
    user_uid = current_user.get("uid")
    logger.info(f"Received judgment prediction request from user: {user_uid}")

    prompt = create_prediction_prompt(prediction_input.case_summary)
    
    try:
        api_key = GEMINI_API_KEY
        if not api_key:
            raise HTTPException(status_code=500, detail="AI Service is not configured.")

        api_url = "https://openrouter.ai/api/v1/chat/completions"
        
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }

        payload = {
            "model": "google/gemini-2.0-flash-001", 
            "messages": [
                {
                    "role": "system", 
                    "content": "You are ArguMate, an expert legal analyst. You must respond ONLY with a valid JSON object."
                },
                {
                    "role": "user", 
                    "content": prompt
                }
            ],
            "response_format": { "type": "json_object" } 
        }
        
        response = requests.post(api_url, headers=headers, json=payload)
        response.raise_for_status()
        result = response.json()

        json_response_str = result["choices"][0]["message"]["content"]
        
        if "```json" in json_response_str:
            json_response_str = json_response_str.split("```json")[1].split("```")[0].strip()
        elif "```" in json_response_str:
             json_response_str = json_response_str.split("```")[1].split("```")[0].strip()

        ai_response_data = json.loads(json_response_str)

        return PredictionResponse(
            message="Judgment prediction generated successfully.",
            predicted_outcome=ai_response_data.get("predicted_outcome", "Unknown"),
            confidence_score=ai_response_data.get("confidence_score", 0),
            reasoning=ai_response_data.get("reasoning", "No reasoning provided.")
        )

    except Exception as e:
        logger.error(f"An unexpected error occurred during judgment prediction for user {user_uid}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"An internal error occurred: {e}")


def create_prediction_prompt(case_summary: str) -> str:
    """Creates a standardized prompt for the judgment prediction task."""
    return f"""
    You are ArguMate, an AI legal analyst that simulates a machine learning model trained on Indian court cases.
    Your task is to predict the likely outcome of a case based on its summary.
    
    The response MUST be a single, valid JSON object with the following keys:
    1. "predicted_outcome": String. Use "Conviction" (Doshi), "Acquittal" (Nirdosh), or "Settlement" (Samjhauta).
    2. "confidence_score": Integer (0-100).
    3. "reasoning": String. A brief explanation citing facts.

    Analyze this case summary:
    ---
    {case_summary}
    ---
    """