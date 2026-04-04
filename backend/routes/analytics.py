from fastapi import APIRouter, HTTPException, Path
from typing import Any, Dict
from services.firebase_service import FirebaseService
from pydantic import BaseModel

router = APIRouter()

class EventPayload(BaseModel):
    user_id: str
    timestamp: str  # Kept as str to easily accept Flutter ISO format
    # Using dynamic kwargs mapped model is harder in basic Pydantic, so we use a dict payload
    # for the dynamic stuff, or we can just unpack it. 
    # Actually, the safest way to ingest dynamic JSON safely in FastAPI is explicitly defining kwargs
    # but the prompt specifically says "reject malformed payloads silently":
    # So we accept dict for the body, but parse carefully.

@router.post("/track/{event_type}")
async def track_event(
    event_type: str,
    payload: Dict[str, Any]
):
    # Enforce silent failures and robust typing
    try:
        user_id = payload.get("user_id")
        if not user_id:
            return {"status": "ignored"} # Silent fail

        # Route dynamically
        if event_type == "wearable":
            await FirebaseService.save_wearable_event(user_id, payload)
        elif event_type == "vr":
            await FirebaseService.save_vr_session(user_id, payload)
        elif event_type == "calm":
            await FirebaseService.save_calm_session(user_id, payload)
        elif event_type == "ai":
            await FirebaseService.save_ai_insight(user_id, payload)
        else:
            return {"status": "unsupported_event_type_ignored"}

        return {"status": "success", "event_type": event_type}

    except Exception as e:
        # ABSOLUTE SILENT FAILURE -> NO Error 500 exposed to mobile client
        print(f"Tracking Route Error: {e}")
        return {"status": "silent_failure"}
