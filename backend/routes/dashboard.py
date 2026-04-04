from fastapi import APIRouter, HTTPException
from services.dashboard_service import DashboardService

router = APIRouter()

@router.get("/dashboard/{user_id}")
async def get_dashboard(user_id: str):
    try:
        # The DashboardService perfectly wraps the Firestore physical connection
        # and gracefully handles 'empty' data or failed LLM mapping seamlessly natively.
        payload = await DashboardService.get_user_dashboard(user_id)
        return {"status": "success", "data": payload}
    except Exception as e:
        print(f"CRITICAL Dashboard Route Error: {e}")
        # Always return the deterministic fallback over crashing
        return {"status": "fallback", "data": DashboardService._get_mock_fallback()}
