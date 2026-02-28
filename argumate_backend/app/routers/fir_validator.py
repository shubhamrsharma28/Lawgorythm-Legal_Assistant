import logging
import json
import requests
from fastapi import APIRouter, Depends, HTTPException
from app.models.schemas import FirDraftInput, FirValidationResponse
from app.core.security import authenticate_user
from app.core.config import GEMINI_API_KEY

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/fir-validator", tags=["FIR Validator"])

@router.post("/validate", response_model=FirValidationResponse)
async def validate_fir_draft(draft_input: FirDraftInput, current_user: dict = Depends(authenticate_user)):
    user_uid = current_user.get("uid")
    prompt = create_validation_prompt(draft_input.fir_draft_text)
    
    try:
        api_url = "https://openrouter.ai/api/v1/chat/completions"
        headers = {"Authorization": f"Bearer {GEMINI_API_KEY}", "Content-Type": "application/json"}
        payload = {
            "model": "google/gemini-2.0-flash-001",
            "messages": [{"role": "user", "content": prompt}],
            "response_format": { "type": "json_object" }
        }
        
        response = requests.post(api_url, headers=headers, json=payload)
        response.raise_for_status()
        ai_response_data = json.loads(response.json()["choices"][0]["message"]["content"].replace("```json", "").replace("```", ""))

        return FirValidationResponse(message="FIR draft validated successfully.", **ai_response_data)
    except Exception as e:
        logger.error(f"Validation Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

def create_validation_prompt(fir_draft: str) -> str:
    return f"You are ArguMate. Validate this FIR draft: {fir_draft}. Return JSON with 'overall_score' (int) and 'validation_points' list (issue, suggestion, severity)."