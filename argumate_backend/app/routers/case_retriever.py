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
    Accepts a case summary and finds similar, real-life case laws with citations.
    """
    user_uid = current_user.get("uid")
    logger.info(f"Received similar case request from user: {user_uid}")

    prompt = create_retrieval_prompt(case_input.case_summary)
    
    try:
        api_key = GEMINI_API_KEY
        if not api_key:
            raise HTTPException(status_code=500, detail="AI Service is not configured.")

        # Define the expected JSON schema for the AI's response
        response_schema = {
            "type": "OBJECT",
            "properties": {
                "similar_cases": {
                    "type": "ARRAY",
                    "items": {
                        "type": "OBJECT",
                        "properties": {
                            "citation": {"type": "STRING"},
                            "case_name": {"type": "STRING"},
                            "summary": {"type": "STRING"},
                            "relevance": {"type": "STRING"}
                        },
                        "required": ["citation", "case_name", "summary", "relevance"]
                    }
                }
            },
            "required": ["similar_cases"]
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

        return CaseRetrieverResponse(
            message="Similar cases retrieved successfully.",
            **ai_response_data
        )

    except Exception as e:
        logger.error(f"An unexpected error occurred during case retrieval for user {user_uid}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"An internal error occurred: {e}")


def create_retrieval_prompt(case_summary: str) -> str:
    """Creates a standardized prompt for the case law retrieval task."""
    return f"""
    You are ArguMate, an expert AI legal researcher specializing in Indian law.
    Your task is to analyze the facts of a case summary and find 3 to 5 similar, real case laws from India.
    The response MUST be a single, valid JSON object.

    The JSON object must have one key: "similar_cases".

    "similar_cases" should be a list of JSON objects. Each object must have four keys:
    - "citation": The official legal citation of the case (e.g., "AIR 1983 SC 465").
    - "case_name": The name of the case (e.g., "State of Punjab vs. Gurmit Singh").
    - "summary": A brief, one-paragraph summary of the case's judgment.
    - "relevance": A short explanation of why this case is relevant to the user's summary.

    Analyze the following case summary:
    ---
    {case_summary}
    ---
    """
