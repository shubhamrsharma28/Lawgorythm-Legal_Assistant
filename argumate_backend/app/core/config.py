# app/core/config.py
import firebase_admin # <-- IMPORTANT: This import is added
from firebase_admin import credentials, initialize_app, firestore
import os
from dotenv import load_dotenv
import json
import logging

# Configure logging for this module
logger = logging.getLogger(__name__)

# Load environment variables from .env file (for local development)
load_dotenv()

# --- Firebase Initialization ---
try:
    firebase_credentials_json = os.getenv('FIREBASE_SERVICE_ACCOUNT_KEY')
    if firebase_credentials_json:
        # On Render, the JSON is a string. We need to load it.
        cred = credentials.Certificate(json.loads(firebase_credentials_json))
    else:
        # For local development, use the file
        cred = credentials.Certificate("serviceAccountKey.json")

    # Check if the app is already initialized to avoid errors
    # THIS IS THE CORRECTED LINE
    if not firebase_admin._apps:
        initialize_app(cred)
        logger.info("Firebase initialized successfully from config!")
    else:
        logger.info("Firebase was already initialized.")

except Exception as e:
    logger.error(f"Error initializing Firebase from config: {e}")
    exit(1)

# Firestore client instance
db = firestore.client()

# --- Get Gemini API Key ---
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
if not GEMINI_API_KEY:
    logger.error("GEMINI_API_KEY environment variable not set! AI processing will fail.")