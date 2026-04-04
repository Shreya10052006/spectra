import re

class CalmLogic:
    """
    Hybrid logic that combines strict keyword/pattern matching 
    with the LLM's behavioral suggestion to determine if Calm Mode is needed.
    """
    
    HIGH_STRESS_KEYWORDS = [
        "overwhelmed", "too loud", "panic", "can't breathe", "scared",
        "too much", "stop", "freaking out", "anxious", "pain", "sensory overload"
    ]
    
    @staticmethod
    def evaluate_should_trigger_calm_mode(user_message: str, model_suggests_calm: bool) -> bool:
        message_lower = user_message.lower()
        
        # 1. Hard Triggers: If the user explicitly uses distress words, trigger immediately.
        for keyword in CalmLogic.HIGH_STRESS_KEYWORDS:
            if re.search(r'\b' + re.escape(keyword) + r'\b', message_lower):
                return True
                
        # 2. Hybrid Trigger: If the LLM sensed nuance in the tone, trust it.
        if model_suggests_calm:
            return True
            
        return False
