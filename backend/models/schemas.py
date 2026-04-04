from pydantic import BaseModel, Field
from typing import List, Dict, Optional

class UserProfile(BaseModel):
    name: str = ""
    age_group: str = ""
    noise_sensitivity: str = ""
    social_comfort: str = ""
    communication: str = ""
    triggers: List[str] = []
    interests: List[str] = []

class ChatMessage(BaseModel):
    role: str # "user" or "assistant"
    content: str

class ChatRequest(BaseModel):
    user_id: str
    user_message: str
    user_profile: UserProfile
    history: List[ChatMessage] = [] # Last 3-5 messages for context

class ChatResponse(BaseModel):
    response_text: str
    suggest_calm_mode: bool
    
class LlamaMemoryUpdates(BaseModel):
    extracted_likes: List[str] = []
    extracted_dislikes: List[str] = []
    extracted_triggers: List[str] = []

class LlamaResponseFormat(BaseModel):
    response_text: str = Field(description="The natural, empathetic response strict to the one-question rule.")
    model_suggests_calm_mode: bool = Field(description="True if the user sounds overwhelmed and might need a break.")
    memory_updates: LlamaMemoryUpdates = Field(description="Any newly learned preferences or triggers.")

class MemoryNode(BaseModel):
    likes: List[str] = []
    dislikes: List[str] = []
    triggers: List[str] = []
    patterns: List[str] = []

class TTSTransformRequest(BaseModel):
    text: str
    tone: str # neutral, friendly, formal

class TTSTransformResponse(BaseModel):
    generated_text: str
