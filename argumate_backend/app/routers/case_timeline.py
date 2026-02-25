# app/routers/case_timeline.py

import logging
import json
import requests
from fastapi import APIRouter, Depends, HTTPException

# Import models and security dependencies
from app.models.schemas import CaseTimelineInput, CaseTimelineResponse
from app.core.security import authenticate_user
from app.core.config import GEMINI_API_KEY

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/timeline",
    tags=["Visual Case Timeline"],
)

@router.post("/generate", response_model=CaseTimelineResponse)
async def generate_case_timeline(
    timeline_input: CaseTimelineInput,
    current_user: dict = Depends(authenticate_user)
):
    """
    Accepts a case summary and generates a visual timeline of the legal process.
    """
    user_uid = current_user.get("uid")
    logger.info(f"Received case timeline request from user: {user_uid}")

    prompt = create_timeline_prompt(timeline_input.case_summary)
    
    try:
        api_key = GEMINI_API_KEY
        if not api_key:
            raise HTTPException(status_code=500, detail="AI Service is not configured.")

        # Define the expected JSON schema for the AI's response
        response_schema = {
            "type": "OBJECT",
            "properties": {
                "timeline_steps": {
                    "type": "ARRAY",
                    "items": {
                        "type": "OBJECT",
                        "properties": {
                            "step_title": {"type": "STRING"},
                            "description": {"type": "STRING"},
                            "estimated_date_or_duration": {"type": "STRING"}
                        },
                        "required": ["step_title", "description", "estimated_date_or_duration"]
                    }
                }
            },
            "required": ["timeline_steps"]
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

        return CaseTimelineResponse(
            message="Case timeline generated successfully.",
            **ai_response_data
        )

    except Exception as e:
        logger.error(f"An unexpected error occurred during timeline generation for user {user_uid}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"An internal error occurred: {e}")


def create_timeline_prompt(case_summary: str) -> str:
    """Creates a standardized prompt for the case timeline generation task."""
    return f"""
    You are ArguMate, an expert AI legal assistant specializing in the Indian legal process.
    Your task is to analyze the facts of a case summary and generate a typical procedural timeline for such a case in India.
    The response MUST be a single, valid JSON object.

    The JSON object must have one key: "timeline_steps".

    "timeline_steps" should be a list of 5-7 JSON objects, each representing a key stage in the legal process. Each object must have three keys:
    - "step_title": The name of the stage (e.g., "FIR Filed", "Investigation Begins", "Chargesheet Filed", "Trial Commences", "Judgment").
    - "description": A brief, one-sentence explanation of what happens at this stage.
    - "estimated_date_or_duration": A typical or estimated date/duration for this stage based on the case summary (e.g., "Approx. 60-90 days", "Within 24 hours", "Could take several months").

    Analyze the following case summary and generate the timeline:
    ---
    {case_summary}
    ---
    """
