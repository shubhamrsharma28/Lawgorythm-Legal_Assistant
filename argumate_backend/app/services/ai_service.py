import logging
import json
import requests
from firebase_admin import firestore
from app.core.config import GEMINI_API_KEY, db

logger = logging.getLogger(__name__)

async def get_gemini_response_for_fir(prompt: str, user_id: str, fir_filename: str) -> dict:
    api_key = GEMINI_API_KEY
    if not api_key:
        raise Exception("Missing API Key.")

    # --- OpenRouter Integration ---
    api_url = "https://openrouter.ai/api/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    payload = {
        "model": "mistralai/devstral-2512:free",
        "messages": [{"role": "user", "content": prompt}]
    }

    try:
        response = requests.post(api_url, headers=headers, json=payload)
        response.raise_for_status()
        result = response.json()

        # Extract content
        json_response_str = result["choices"][0]["message"]["content"]
        
        # OpenRouter returns markdown sometimes, cleaning it
        if "```json" in json_response_str:
            json_response_str = json_response_str.split("```json")[1].split("```")[0].strip()
        
        ai_response_data = json.loads(json_response_str)

        # Save to Firestore
        fir_doc_ref = db.collection('users').document(user_id).collection('firs').document()
        firestore_data = {
            "simplified_explanation": ai_response_data.get("simplified_explanation"),
            "structured_summary": ai_response_data.get("structured_summary"),
            "ipc_sections": ai_response_data.get("ipc_sections"),
            "filename": fir_filename,
            "uploaded_at": firestore.SERVER_TIMESTAMP,
        }
        fir_doc_ref.set(firestore_data)

        ai_response_data["message"] = "FIR processed successfully!"
        ai_response_data["fir_id"] = fir_doc_ref.id
        return ai_response_data

    except Exception as e:
        logger.error(f"AI Service Error: {e}")
        raise Exception(f"Failed to process FIR: {e}")