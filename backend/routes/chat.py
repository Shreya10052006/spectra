from fastapi import APIRouter, HTTPException
from models.schemas import ChatRequest, ChatResponse
from services.firebase_service import FirebaseService
from services.groq_service import GroqService
from services.calm_logic import CalmLogic

router = APIRouter()

@router.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    try:
        # 1. Fetch persistent contextual memory
        memory = await FirebaseService.get_user_memory(request.user_id)
        
        # 2. Query LLM safely via Groq
        llm_response = await GroqService.get_chat_completion(
            user_message=request.user_message,
            profile=request.user_profile,
            memory=memory,
            history=request.history
        )
        
        # 3. Hybrid Calm Mode Evaluation
        trigger_calm = CalmLogic.evaluate_should_trigger_calm_mode(
            user_message=request.user_message,
            model_suggests_calm=llm_response.get("model_suggests_calm_mode", False)
        )
        
        # 4. Safe Memory Update (Validation layer handles sanitization)
        updates = llm_response.get("memory_updates", {})
        await FirebaseService.update_user_memory(
            user_id=request.user_id,
            new_likes=updates.get("extracted_likes", []),
            new_dislikes=updates.get("extracted_dislikes", []),
            new_triggers=updates.get("extracted_triggers", [])
        )
        
        # 5. Send strictly formatted Insight to the analytics system silently
        try:
            await FirebaseService.save_ai_insight(
                user_id=request.user_id, 
                data={
                    "calm_mode_suggested": trigger_calm,
                    "model_confidence": llm_response.get("model_suggests_calm_mode", False),
                    "memory_nodes_extracted": len(updates.get("extracted_likes", [])) + len(updates.get("extracted_dislikes", [])) + len(updates.get("extracted_triggers", [])),
                }
            )
        except:
            pass # Silent fail enforcement
        
        return ChatResponse(
            response_text=llm_response.get("response_text", "I am here for you."),
            suggest_calm_mode=trigger_calm
        )
        
    except Exception as e:
        print(f"Chat Route Error: {e}")
        raise HTTPException(status_code=500, detail="Internal server error managing chat")
