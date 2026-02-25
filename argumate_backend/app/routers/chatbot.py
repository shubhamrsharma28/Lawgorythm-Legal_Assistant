from fastapi import APIRouter, Depends, HTTPException, status
import logging
import requests
from firebase_admin import firestore

from app.core.config import db, GEMINI_API_KEY
from app.core.security import authenticate_user
from app.models.schemas import ChatInput

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/chat",
    tags=["Chatbot"],
)

@router.post("/")
async def chat_with_assistant(
    chat_input: ChatInput,
    current_user: dict = Depends(authenticate_user)
):
    user_uid = current_user.get("uid")
    if not user_uid:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="User UID not found in token.")

    user_message = chat_input.message.strip()
    if not user_message:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Chat message cannot be empty.")

    try:
        api_key = GEMINI_API_KEY
        if not api_key:
            raise HTTPException(status_code=500, detail="API Key is missing.")

        prompt_for_gemini = f"""
        You are Lawgorythm, a helpful AI legal assistant. Respond to the user's legal query concisely and accurately.
        Do NOT provide legal advice. Always state that your responses are for informational purposes only.

        User's query: {user_message}
        """

        # --- Verified OpenRouter Config ---
        api_url = "https://openrouter.ai/api/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
            "HTTP-Referer": "http://localhost:8000",
            "X-Title": "ArguMate"
        }
        payload = {
            "model": "stepfun/step-3.5-flash:free",
            "messages": [{"role": "user", "content": prompt_for_gemini}]
        }

        response = requests.post(api_url, headers=headers, json=payload)
        
        # Debugging ke liye response check
        if response.status_code != 200:
            logger.error(f"OpenRouter Error: {response.status_code} - {response.text}")
            
        response.raise_for_status()
        result = response.json()

        if "choices" in result and len(result["choices"]) > 0:
            ai_response_text = result["choices"][0]["message"]["content"]
        else:
            ai_response_text = "Sorry, I couldn't generate a response."

    except Exception as e:
        logger.error(f"Error calling AI: {e}")
        raise HTTPException(status_code=500, detail=f"AI processing failed: {e}")

    # --- Save to Firestore ---
    try:
        chat_history_ref = db.collection('users').document(user_uid).collection('chat_history').document()
        chat_history_ref.set({
            "user_message": user_message,
            "ai_response": ai_response_text,
            "timestamp": firestore.SERVER_TIMESTAMP
        })
    except Exception as e:
        logger.error(f"Firestore error: {e}")

    return {
        "message": "Success",
        "user_message": user_message,
        "ai_response": ai_response_text
    }