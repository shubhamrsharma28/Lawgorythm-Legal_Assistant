# app/routers/fir_explainer.py

import logging
import json
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form

# Import Pydantic models from a central location
from app.models.schemas import FirExplanationResponse

# Import helper services
from app.core.security import authenticate_user
from app.services.document_parser import parse_document
from app.services.ai_service import get_gemini_response_for_fir

# Configure logging
logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/fir",
    tags=["FIR Explainer"],
)

@router.post("/explain", response_model=FirExplanationResponse)
async def explain_fir_unified(
    current_user: dict = Depends(authenticate_user),
    file: Optional[UploadFile] = File(None),
    fir_text_input: Optional[str] = Form(None)
):
    """
    Accepts either an FIR document (file) or FIR text (form data) and returns an explanation.
    If both are provided, the file will be prioritized.
    """
    user_uid = current_user.get("uid")
    fir_text = ""
    filename = "pasted_text.txt"

    try:
        # Determine the source of the FIR content
        if file:
            logger.info(f"Processing FIR file: {file.filename} for user: {user_uid}")
            fir_text = await parse_document(file)
            fir_text = clean_text_for_json(fir_text)
            filename = file.filename
        elif fir_text_input:
            logger.info(f"Processing FIR from direct text input for user: {user_uid}")
            fir_text = fir_text_input
        else:
            # If neither file nor text is provided, raise an error
            raise HTTPException(status_code=400, detail="Please provide either a file or text to explain.")

        if len(fir_text) < 50:
            raise HTTPException(status_code=400, detail="The provided text is too short to be a valid FIR.")

        # Create a detailed prompt for the AI
        prompt = create_fir_prompt(fir_text)

        # Get the structured response from the AI service
        ai_response_json = await get_gemini_response_for_fir(
            prompt=prompt, 
            user_id=user_uid, 
            fir_filename=filename
        )
        
        logger.info(f"Successfully processed FIR for user {user_uid}, fir_id: {ai_response_json.get('fir_id')}")

        # Validate and return the response
        return FirExplanationResponse(**ai_response_json)

    except HTTPException as http_exc:
        logger.error(f"HTTP exception in FIR explanation for user {user_uid}: {http_exc.detail}")
        raise http_exc
    except Exception as e:
        logger.error(f"An unexpected error occurred in FIR explanation for user {user_uid}: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"An internal error occurred: {e}")

def clean_text_for_json(text: str) -> str:
    """
    Cleans text extracted from files to make it safe for JSON embedding.
    """
    # Replace different kinds of quotes with standard ones
    text = text.replace('“', '"').replace('”', '"').replace("‘", "'").replace("’", "'")
    # Escape backslashes and double quotes
    text = text.replace('\\', '\\\\').replace('"', '\\"')
    # Remove excessive newlines and tabs
    text = text.replace('\n', ' ').replace('\r', ' ').replace('\t', ' ')
    # Remove multiple spaces
    return ' '.join(text.split())


# --- UPDATED: Helper function with a more robust prompt ---
def create_fir_prompt(fir_text: str) -> str:
    """Creates a more robust and standardized prompt for the Gemini API."""
    return f"""
    You are an expert AI legal assistant. Your task is to analyze the following First Information Report (FIR) text from India and convert it into a structured, valid JSON object.
    The JSON output MUST be perfect and parseable. Pay extremely close attention to syntax, especially escaping quotes within string values and ensuring all commas are correctly placed.

    The JSON object must contain these exact three top-level keys: "simplified_explanation", "structured_summary", and "ipc_sections".

    1. "simplified_explanation": Provide a clear, easy-to-understand summary of the FIR. This must be a single JSON string.
    2. "structured_summary": Extract key details into a nested JSON object. If a detail is not found, use an empty string "" or an empty list [] as the value. The keys inside this object should be explicitly defined as per the schema, for example: "complainant_name", "accused_name_s", "victim_name_s", "date_of_incident", "time_of_incident", "place_of_incident", "brief_offence_description", "fir_number", "police_station", "date_of_fir".
    3. "ipc_sections": Create a list of JSON objects. Each object must have two keys: "section" (e.g., "IPC Section 302") and "reason" (a brief explanation). If no sections are applicable, return an empty list [].

    Analyze the following FIR text carefully:
    ---
    {fir_text}
    ---
    """
