# app/core/security.py
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer
from firebase_admin import auth
import logging

logger = logging.getLogger(__name__)

security_scheme = HTTPBearer()

async def authenticate_user(credentials: HTTPBearer = Depends(security_scheme)):
    """
    Authenticates a user based on Firebase ID Token provided in the Authorization header.
    Raises HTTPException if token is invalid or user is not authenticated.
    Returns the decoded token (user claims) if successful.
    """
    try:
        # Verify the ID token using Firebase Admin SDK
        decoded_token = auth.verify_id_token(credentials.credentials)
        return decoded_token
    except Exception as e:
        logger.error(f"Firebase ID Token verification failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )
