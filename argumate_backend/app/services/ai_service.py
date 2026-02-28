# app/services/ai_service.py
import logging
import json
import requests
from firebase_admin import firestore
from app.core.config import GEMINI_API_KEY, db

logger = logging.getLogger(__name__)

async def get_gemini_response_for_fir(prompt: str, user_id: str, fir_filename: str) -> dict:
    """
    Orchestrates the AI response for FIR explanation using OpenRouter.
    Ensures identity as ArguMate and structured JSON output.
    """
    api_key = GEMINI_API_KEY
    if not api_key:
        raise Exception("Missing AI API Key configuration.")

    # --- OpenRouter Integration ---
    api_url = "https://openrouter.ai/api/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }

    # Added System Role to enforce ArguMate identity and JSON format
    payload = {
        "model": "google/gemini-2.0-flash-001", # High accuracy for legal parsing
        "messages": [
            {
                "role": "system", 
                "content": (
                    "You are 'ArguMate', a specialized AI Legal Assistant for the Lawgorythm platform. "
                    "Your job is to analyze Indian FIRs and provide structured insights. "
                    "You must ALWAYS respond in valid JSON format. Never call yourself Lawgorythm."
                )
            },
            {
                "role": "user", 
                "content": prompt
            }
        ],
        "response_format": { "type": "json_object" }
    }

    try:
        response = requests.post(api_url, headers=headers, json=payload)
        response.raise_for_status()
        result = response.json()

        # Extract content
        json_response_str = result["choices"][0]["message"]["content"]
        
        # Robust Cleaning: Remove markdown backticks if AI includes them
        if "```json" in json_response_str:
            json_response_str = json_response_str.split("```json")[1].split("```")[0].strip()
        elif "```" in json_response_str:
            json_response_str = json_response_str.split("```")[1].split("```")[0].strip()
        
        ai_response_data = json.loads(json_response_str)

        # --- Save to Firestore ---
        fir_doc_ref = db.collection('users').document(user_id).collection('firs').document()
        firestore_data = {
            "simplified_explanation": ai_response_data.get("simplified_explanation"),
            "structured_summary": ai_response_data.get("structured_summary"),
            "ipc_sections": ai_response_data.get("ipc_sections"),
            "filename": fir_filename,
            "uploaded_at": firestore.SERVER_TIMESTAMP,
        }
        fir_doc_ref.set(firestore_data)

        # Meta info for Frontend
        ai_response_data["message"] = "FIR processed successfully by ArguMate!"
        ai_response_data["fir_id"] = fir_doc_ref.id
        
        return ai_response_data

    except Exception as e:
        logger.error(f"ArguMate Service Error: {e}")
        raise Exception(f"ArguMate failed to process FIR: {e}")