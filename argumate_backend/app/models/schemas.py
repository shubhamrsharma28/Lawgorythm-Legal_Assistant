# app/models/schemas.py
from pydantic import BaseModel, EmailStr, Field
from typing import List, Optional, Dict, Any

# --- User and Auth Models ---
class UserCreate(BaseModel):
    """Pydantic model for user registration request body."""
    display_name: str = Field(..., min_length=3)
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    """Pydantic model for user login request body."""
    email: EmailStr
    password: str

# --- Chatbot Models ---
class ChatInput(BaseModel):
    """Pydantic model for user chat message input."""
    message: str

# --- FIR Explainer Models ---
class IPCSection(BaseModel):
    """Defines the structure for a single suggested IPC section."""
    section: str
    reason: str

class FirExplanationResponse(BaseModel):
    """Defines the complete structure of the response for the /fir/explain endpoint."""
    message: str
    simplified_explanation: str
    structured_summary: Dict[str, Any]
    ipc_sections: List[IPCSection]
    fir_id: str

# --- FIR Validator Models ---
class FirDraftInput(BaseModel):
    """Pydantic model for receiving an FIR draft text for validation."""
    fir_draft_text: str = Field(..., min_length=50)

class ValidationPoint(BaseModel):
    """Defines the structure for a single validation suggestion."""
    issue: str
    suggestion: str
    severity: str # e.g., "High", "Medium", "Low"

class FirValidationResponse(BaseModel):
    """Defines the structure of the response for the FIR validation endpoint."""
    message: str
    overall_score: int
    validation_points: List[ValidationPoint]

# --- Argument Builder Models ---
class ArgumentBuilderInput(BaseModel):
    """Pydantic model for receiving the facts of a case."""
    case_summary: str = Field(..., min_length=50)

class ArgumentPoint(BaseModel):
    """Defines the structure for a single legal argument."""
    point: str
    reasoning: str

class ArgumentBuilderResponse(BaseModel):
    """Defines the structure of the response for the argument builder endpoint."""
    message: str
    prosecution_arguments: List[ArgumentPoint]
    defense_arguments: List[ArgumentPoint]

# --- Case Law Retriever Models ---
class CaseRetrieverInput(BaseModel):
    """Pydantic model for receiving a case summary to find similar cases."""
    case_summary: str = Field(..., min_length=50)

class SimilarCase(BaseModel):
    """Defines the structure for a single retrieved case law."""
    citation: str
    case_name: str
    summary: str
    relevance: str

class CaseRetrieverResponse(BaseModel):
    """Defines the structure of the response for the case retriever endpoint."""
    message: str
    similar_cases: List[SimilarCase]

# --- Visual Case Timeline Models ---
class CaseTimelineInput(BaseModel):
    """Pydantic model for receiving a case summary for timeline generation."""
    case_summary: str = Field(..., min_length=50)

class TimelineStep(BaseModel):
    """Defines the structure for a single step in the case timeline."""
    step_title: str
    description: str
    estimated_date_or_duration: str

class CaseTimelineResponse(BaseModel):
    """Defines the structure of the response for the timeline generation endpoint."""
    message: str
    timeline_steps: List[TimelineStep]


# --- Judgment Prediction Engine Models ---

class PredictionInput(BaseModel):
    """Pydantic model for receiving a case summary for judgment prediction."""
    case_summary: str = Field(..., min_length=50)

class PredictionResponse(BaseModel):
    """Defines the structure of the response for the judgment prediction endpoint."""
    message: str
    predicted_outcome: str
    confidence_score: int # A percentage from 0 to 100
    reasoning: str