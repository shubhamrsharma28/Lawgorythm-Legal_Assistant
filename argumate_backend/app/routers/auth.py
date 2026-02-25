# app/routers/auth.py
from fastapi import APIRouter, Depends, HTTPException, status
from firebase_admin import auth, firestore
import logging

from app.core.config import db
from app.core.security import authenticate_user
from app.models.schemas import UserCreate, UserLogin

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/auth",
    tags=["Authentication"],
)

@router.post("/register")
async def register_user(user_data: UserCreate):
    """
    Registers a new user with Firebase Authentication and saves their display name.
    """
    try:
        # Create user in Firebase Authentication with email, password, and display name
        user = auth.create_user(
            email=user_data.email,
            password=user_data.password,
            display_name=user_data.display_name
        )
        
        # Save additional user data to Firestore
        user_ref = db.collection('users').document(user.uid)
        user_ref.set({
            'email': user.email,
            'display_name': user.display_name,
            'created_at': firestore.SERVER_TIMESTAMP
        })
        
        logger.info(f"User registered: {user.email} with UID: {user.uid}")
        return {"message": "User registered successfully!", "uid": user.uid, "email": user.email}
        
    except Exception as e:
        logger.error(f"User registration failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Registration failed: {e}"
        )

@router.post("/login")
async def login_user(user_data: UserLogin):
    logger.info(f"Login request received for: {user_data.email}. Client-side Firebase Auth will handle actual login.")
    return {"message": "Login request received. Client-side authentication expected."}

@router.get("/protected-test")
async def protected_test_route(current_user: dict = Depends(authenticate_user)):
    logger.info(f"Access granted to protected test route for user: {current_user.get('email', current_user.get('uid'))}")
    return {"message": "Welcome to the protected test area!", "user": current_user}
