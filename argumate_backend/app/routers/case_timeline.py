import logging
import json
import requests
from fastapi import APIRouter, Depends, HTTPException

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
    user_uid = current_user.get("uid")
    logger.info(f"Received case timeline request from user: {user_uid}")

    prompt = create_timeline_prompt(timeline_input.case_summary)
    
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
                {"role": "system", "content": "You are ArguMate, an expert legal assistant. Respond ONLY with a valid JSON object."},
                {"role": "user", "content": prompt}
            ],
            "response_format": { "type": "json_object" }
        }
        
        response = requests.post(api_url, headers=headers, json=payload)
        response.raise_for_status()
        result = response.json()

        json_response_str = result["choices"][0]["message"]["content"]
        
        # Clean Markdown
        if "```json" in json_response_str:
            json_response_str = json_response_str.split("```json")[1].split("```")[0].strip()
        
        ai_response_data = json.loads(json_response_str)

        return CaseTimelineResponse(
            message="Case timeline generated successfully.",
            **ai_response_data
        )

    except Exception as e:
        logger.error(f"Error in timeline generation for user {user_uid}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"An internal error occurred: {e}")

def create_timeline_prompt(case_summary: str) -> str:
    return f"""
    You are ArguMate, an expert AI legal assistant for Indian law. Analyze the case and generate a procedural timeline.
    Respond with a JSON object containing a 'timeline_steps' list of 5-7 objects.
    Each object needs: 'step_title', 'description', 'estimated_date_or_duration'.

    Case Summary: {case_summary}
    """