# app/routers/fir_validator.py

import logging
import json
import requests
from fastapi import APIRouter, Depends, HTTPException

# Import models and security dependencies
from app.models.schemas import FirDraftInput, FirValidationResponse
from app.core.security import authenticate_user
from app.core.config import GEMINI_API_KEY

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/fir-validator",
    tags=["FIR Validator"],
)

@router.post("/validate", response_model=FirValidationResponse)
async def validate_fir_draft(
    draft_input: FirDraftInput,
    current_user: dict = Depends(authenticate_user)
):
    """
    Accepts an FIR draft text, analyzes it for completeness and correctness,
    and returns a validation report.
    """
    user_uid = current_user.get("uid")
    logger.info(f"Received FIR draft validation request from user: {user_uid}")

    prompt = create_validation_prompt(draft_input.fir_draft_text)
    
    try:
        api_key = GEMINI_API_KEY
        if not api_key:
            raise HTTPException(status_code=500, detail="AI Service is not configured.")

        # Define the expected JSON schema for the AI's response
        response_schema = {
            "type": "OBJECT",
            "properties": {
                "overall_score": {"type": "INTEGER"},
                "validation_points": {
                    "type": "ARRAY",
                    "items": {
                        "type": "OBJECT",
                        "properties": {
                            "issue": {"type": "STRING"},
                            "suggestion": {"type": "STRING"},
                            "severity": {"type": "STRING"}
                        },
                        "required": ["issue", "suggestion", "severity"]
                    }
                }
            },
            "required": ["overall_score", "validation_points"]
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

        return FirValidationResponse(
            message="FIR draft validated successfully.",
            **ai_response_data
        )

    except requests.exceptions.RequestException as e:
        logger.error(f"Network error during FIR validation for user {user_uid}: {e}")
        raise HTTPException(status_code=500, detail=f"AI processing network error: {e}")
    except Exception as e:
        logger.error(f"An unexpected error occurred during FIR validation for user {user_uid}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"An internal error occurred: {e}")


def create_validation_prompt(fir_draft: str) -> str:
    """Creates a standardized prompt for the FIR validation task."""
    return f"""
    You are ArguMate, an expert AI legal assistant specializing in Indian law.
    Your task is to review a user-drafted First Information Report (FIR) and provide a validation report.
    The response MUST be a single, valid JSON object.

    The JSON object must have two keys: "overall_score" and "validation_points".

    1. "overall_score": An integer score from 0 to 100 representing the quality and completeness of the FIR draft.
    2. "validation_points": A list of JSON objects. Each object must have three keys:
        - "issue": A short title for the problem found (e.g., "Missing Date of Incident", "Vague Description").
        - "suggestion": A clear, constructive suggestion on how to fix the issue.
        - "severity": The importance of the issue, which must be one of "High", "Medium", or "Low".

    Analyze the following FIR draft:
    ---
    {fir_draft}
    ---
    """
