from fastapi import APIRouter, HTTPException
from models.schemas import TTSTransformRequest, TTSTransformResponse
from services.groq_service import GroqService

router = APIRouter()

@router.post("/tts-transform", response_model=TTSTransformResponse)
async def tts_transform_endpoint(request: TTSTransformRequest):
    try:
        # Note: Deliberately NO user_profile or memory logic is passed here to ensure strict isolation.
        transformed_string = await GroqService.get_tts_transformation(
            text=request.text,
            tone=request.tone
        )
        
        return TTSTransformResponse(generated_text=transformed_string)
        
    except Exception as e:
        print(f"TTS Route Error: {e}")
        # Intent Fallback: Even if it fails entirely, return the user's raw input so they are never blocked from speaking.
        return TTSTransformResponse(generated_text=request.text)
