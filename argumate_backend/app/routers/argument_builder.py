import logging
import json
import requests
from fastapi import APIRouter, Depends, HTTPException
from firebase_admin import firestore

from app.models.schemas import ArgumentBuilderInput, ArgumentBuilderResponse
from app.core.security import authenticate_user
from app.core.config import GEMINI_API_KEY, db

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/arguments",
    tags=["Argument Builder"],
)

@router.post("/build", response_model=ArgumentBuilderResponse)
async def build_arguments(
    argument_input: ArgumentBuilderInput,
    current_user: dict = Depends(authenticate_user)
):
    user_uid = current_user.get("uid")
    logger.info(f"Received argument build request from user: {user_uid}")
    prompt = create_argument_prompt(argument_input.case_summary)
    
    try:
        api_key = GEMINI_API_KEY
        api_url = "https://openrouter.ai/api/v1/chat/completions"
        headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}

        payload = {
            "model": "google/gemini-2.0-flash-001",
            "messages": [{"role": "user", "content": prompt}],
            "response_format": { "type": "json_object" }
        }
        
        response = requests.post(api_url, headers=headers, json=payload)
        response.raise_for_status()
        result = response.json()

        json_response_str = result["choices"][0]["message"]["content"]
        if "```json" in json_response_str:
            json_response_str = json_response_str.split("```json")[1].split("```")[0].strip()
        
        ai_response_data = json.loads(json_response_str)

        # Database saving
        try:
            args_ref = db.collection('users').document(user_uid).collection('arguments_built').document()
            args_ref.set({
                'case_summary': argument_input.case_summary,
                'timestamp': firestore.SERVER_TIMESTAMP,
                'prosecution_arguments': ai_response_data.get("prosecution_arguments", []),
                'defense_arguments': ai_response_data.get("defense_arguments", [])
            })
        except Exception as db_e:
            logger.error(f"DB Error: {db_e}")

        return ArgumentBuilderResponse(message="Arguments generated successfully.", **ai_response_data)

    except Exception as e:
        logger.error(f"Error in argument generation: {e}")
        raise HTTPException(status_code=500, detail=str(e))

def create_argument_prompt(case_summary: str) -> str:
    return f"You are ArguMate. Create 'prosecution_arguments' and 'defense_arguments' in JSON for: {case_summary}. Each arg needs 'point' and 'reasoning'."