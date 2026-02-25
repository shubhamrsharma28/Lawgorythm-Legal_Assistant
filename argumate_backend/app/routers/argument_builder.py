# app/routers/argument_builder.py

import logging
import json
import requests
from fastapi import APIRouter, Depends, HTTPException
from firebase_admin import firestore

# Import models and security dependencies
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
    """
    Accepts a case summary and generates potential arguments for both
    prosecution and defense.
    """
    user_uid = current_user.get("uid")
    logger.info(f"Received argument build request from user: {user_uid}")

    prompt = create_argument_prompt(argument_input.case_summary)
    
    try:
        api_key = GEMINI_API_KEY
        if not api_key:
            raise HTTPException(status_code=500, detail="AI Service is not configured.")

        # Define the expected JSON schema for the AI's response
        response_schema = {
            "type": "OBJECT",
            "properties": {
                "prosecution_arguments": {
                    "type": "ARRAY",
                    "items": {
                        "type": "OBJECT",
                        "properties": {
                            "point": {"type": "STRING"},
                            "reasoning": {"type": "STRING"}
                        },
                        "required": ["point", "reasoning"]
                    }
                },
                "defense_arguments": {
                    "type": "ARRAY",
                    "items": {
                        "type": "OBJECT",
                        "properties": {
                            "point": {"type": "STRING"},
                            "reasoning": {"type": "STRING"}
                        },
                        "required": ["point", "reasoning"]
                    }
                }
            },
            "required": ["prosecution_arguments", "defense_arguments"]
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

        # --- DATABASE SAVING LOGIC STARTS HERE ---
        try:
            # Pydantic models ko dicts mein convert karein
            prosecution_args_to_save = ai_response_data.get("prosecution_arguments", [])
            defense_args_to_save = ai_response_data.get("defense_arguments", [])
            args_ref = db.collection('users').document(user_uid).collection('arguments_built').document()
            args_ref.set({
                'case_summary': argument_input.case_summary, # Poori summary save karein
                'timestamp': firestore.SERVER_TIMESTAMP,
                'prosecution_arguments': prosecution_args_to_save, # Arguments save karein
                'defense_arguments': defense_args_to_save      # Arguments save karein
            })
            logger.info(f"Argument build activity saved for user {user_uid}")
        except Exception as db_e:
            logger.error(f"Failed to save argument build activity for user {user_uid}: {db_e}")
        # --- DATABASE SAVING LOGIC ENDS HERE ---

        return ArgumentBuilderResponse(
            message="Arguments generated successfully.",
            **ai_response_data
        )

    except Exception as e:
        logger.error(f"An unexpected error occurred during argument generation for user {user_uid}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"An internal error occurred: {e}")


def create_argument_prompt(case_summary: str) -> str:
    """Creates a standardized prompt for the argument generation task."""
    return f"""
    You are ArguMate, an expert AI legal strategist specializing in Indian law.
    Your task is to analyze the facts of a case and construct potential legal arguments for both the prosecution and the defense.
    The response MUST be a single, valid JSON object.

    The JSON object must have two keys: "prosecution_arguments" and "defense_arguments".

    1. "prosecution_arguments": A list of JSON objects, each representing a key point for the prosecution.
    2. "defense_arguments": A list of JSON objects, each representing a key point for the defense.

    Each argument object must have two keys:
    - "point": A short, impactful title for the argument (e.g., "Theft Proven by Eyewitness").
    - "reasoning": A brief explanation of the legal and factual basis for this argument.

    Analyze the following case summary:
    ---
    {case_summary}
    ---
    """