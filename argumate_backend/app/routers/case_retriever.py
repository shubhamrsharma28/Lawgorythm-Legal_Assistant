# app/routers/case_retriever.py

import logging
import json
import requests
from fastapi import APIRouter, Depends, HTTPException

# Import models and security dependencies
from app.models.schemas import CaseRetrieverInput, CaseRetrieverResponse
from app.core.security import authenticate_user
from app.core.config import GEMINI_API_KEY

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/cases",
    tags=["Case Law Retriever"],
)

@router.post("/find-similar", response_model=CaseRetrieverResponse)
async def find_similar_cases(
    case_input: CaseRetrieverInput,
    current_user: dict = Depends(authenticate_user)
):
    """
    Accepts a case summary and finds similar, real-life case laws using OpenRouter.
    """
    user_uid = current_user.get("uid")
    logger.info(f"Received similar case request from user: {user_uid}")

    prompt = create_retrieval_prompt(case_input.case_summary)
    
    try:
        api_key = GEMINI_API_KEY
        if not api_key:
            raise HTTPException(status_code=500, detail="AI Service Key is not configured.")

        # --- FIX: CLEAN URL WITHOUT MARKDOWN BRACKETS ---
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
                    "content": "You are ArguMate, an expert legal researcher. You MUST respond ONLY with a valid JSON object."
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

        # Extract content safely
        json_response_str = result["choices"][0]["message"]["content"]
        
        # Robust Cleaning for JSON
        if "```json" in json_response_str:
            json_response_str = json_response_str.split("```json")[1].split("```")[0].strip()
        elif "```" in json_response_str:
            json_response_str = json_response_str.split("```")[1].split("```")[0].strip()
        
        ai_response_data = json.loads(json_response_str)

        # Ensure the keys match what the Frontend (Pydantic model) expects
        return CaseRetrieverResponse(
            message="Similar cases retrieved successfully.",
            similar_cases=ai_response_data.get("similar_cases", [])
        )

    except Exception as e:
        logger.error(f"Error in case retrieval for user {user_uid}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"An internal error occurred: {str(e)}")

def create_retrieval_prompt(case_summary: str) -> str:
    """Creates a standardized prompt for the case law retrieval task."""
    return (
        f"You are ArguMate, an expert AI legal researcher specializing in Indian law. "
        f"Find 3 to 5 real, landmark Indian case laws that are similar to this case: {case_summary}. "
        f"Return ONLY a JSON object with a 'similar_cases' key. Each case in the list must have: "
        f"'citation', 'case_name', 'summary', and 'relevance'."
    )