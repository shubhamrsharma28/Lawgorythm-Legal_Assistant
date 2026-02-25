# main.py
import os
import logging
from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from firebase_admin import firestore
from fastapi.middleware.cors import CORSMiddleware

# Import your project's modules
from app.core.config import db
from app.routers import auth, fir_explainer, chatbot, fir_validator, argument_builder, case_retriever, case_timeline, judgment_predictor

# Load environment variables from .env file for local development
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="ArguMate Backend API",
    description="AI-Powered FIR Explainer & Legal Assistant Backend",
    version="1.0.0",
)

# --- CORS Configuration for Deployment ---
# This allows your Flutter app (from any origin) to make requests to this backend.
origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],  # Allows all HTTP methods (GET, POST, etc.)
    allow_headers=["*"],  # Allows all headers
)
# --- End CORS Configuration ---

# Include all the routers for different features
app.include_router(auth.router)
app.include_router(fir_explainer.router)
app.include_router(chatbot.router)
app.include_router(fir_validator.router)
app.include_router(argument_builder.router)
app.include_router(case_retriever.router)
app.include_router(case_timeline.router)
app.include_router(judgment_predictor.router)

# Root endpoint for a basic health check
@app.get("/")
async def read_root():
    return {"message": "ArguMate Backend is Running!"}

# Test endpoint for Firestore connection (useful for debugging)
@app.get("/test-firestore")
async def test_firestore_connection():
    """
    Endpoint to verify the connection to Firebase Firestore.
    """
    try:
        doc_ref = db.collection('test_collection').document('test_document')
        doc_ref.set({'hello': 'firestore', 'timestamp': firestore.SERVER_TIMESTAMP})
        return {"message": "Firestore test document written successfully!"}
    except Exception as e:
        logger.error(f"Firestore write failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))
