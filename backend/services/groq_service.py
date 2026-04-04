import os
import json
from groq import Groq
from models.schemas import UserProfile, MemoryNode, LlamaResponseFormat

client = Groq(api_key=os.getenv("GROQ_API_KEY", "mock_key_if_missing"))

class GroqService:
    @staticmethod
    def construct_system_prompt(profile: UserProfile, memory: MemoryNode) -> str:
        prompt = f"""You are SPECTRA, a calm, patient, and highly empathetic digital companion designed to support autistic individuals. 
You are NOT a medical professional, therapist, or bot. Do NOT diagnose or use clinical language.

--- USER PROFILE ---
Name: {profile.name}
Role: {profile.role}
Noise Sensitivity: {profile.noise_sensitivity}
Social Comfort: {profile.social_comfort}
Triggers (from onboarding): {', '.join(profile.triggers) if profile.triggers else 'None yet'}

--- STORED MEMORY ---
Likes: {', '.join(memory.likes) if memory.likes else 'None yet'}
Dislikes: {', '.join(memory.dislikes) if memory.dislikes else 'None yet'}
Identified Triggers: {', '.join(memory.triggers) if memory.triggers else 'None yet'}

--- STRICT BEHAVIORAL RULES ---
1. EMOTIONAL FLOW: If the user expresses distress/emotion, you MUST strictly follow this exact 3-step sequence:
   - ACKNOWLEDGE: "That sounds completely overwhelming."
   - VALIDATE: "It makes total sense that you feel drained."
   - GENTLE ASK: "Would you like to talk about what happened?"
2. ONE QUESTION LIMIT: You may ONLY ask a maximum of ONE question per response. Never chain questions.
3. IMPLICIT MEMORY: Use memory naturally in context. Do NOT ever say "Based on your memory data" or "I remember that you". Instead, say things like "I know crowds can be hard for you."
4. NATURAL LANGUAGE: While you are returning JSON, the 'response_text' MUST be human-like, warm, and natural. Do not speak like an exam or a robot. Keep paragraphs very short.

You must respond in pure JSON matching this exact schema:
{{
  "response_text": "Your conversational response",
  "model_suggests_calm_mode": false,
  "memory_updates": {{ "extracted_likes": [], "extracted_dislikes": [], "extracted_triggers": [] }}
}}
"""
        return prompt

    @staticmethod
    async def get_chat_completion(user_message: str, profile: UserProfile, memory: MemoryNode, history: list) -> dict:
        system_prompt = GroqService.construct_system_prompt(profile, memory)
        
        messages = [{"role": "system", "content": system_prompt}]
        
        # Inject recent contextual history
        for msg in history[-5:]: # Keep only the last 5 to avoid context bloat
            messages.append({"role": msg.role, "content": msg.content})
            
        messages.append({"role": "user", "content": user_message})

        try:
            # Note: For production without a real key we'd mock this. 
            # If the literal key is "mock_key_if_missing", we return a safe mock response.
            if os.getenv("GROQ_API_KEY") is None:
                print("WARNING: No GROQ_API_KEY found, using offline mock response.")
                return {
                    "response_text": "I hear you. That sounds like a lot to process right now. I'm here with you. Would you like to talk about it?",
                    "model_suggests_calm_mode": False,
                    "memory_updates": {"extracted_likes": [], "extracted_dislikes": [], "extracted_triggers": []}
                }

            completion = client.chat.completions.create(
                model="llama3-70b-8192",
                messages=messages,
                response_format={"type": "json_object"},
                temperature=0.6, # Lower temp for consistent emotional support
            )
            
            response_json = json.loads(completion.choices[0].message.content)
            return response_json
            
        except Exception as e:
            print(f"Error calling Groq: {e}")
            return {
                "response_text": "I'm having a little trouble connecting my thoughts right now, but I am still here for you. Take a deep breath.",
                "model_suggests_calm_mode": False,
                "memory_updates": {"extracted_likes": [], "extracted_dislikes": [], "extracted_triggers": []}
            }

    @staticmethod
    async def get_tts_transformation(text: str, tone: str) -> str:
        # Strictly enforce isolation! No memory, no emotion. Just syntax translation.
        tone_lower = tone.lower()
        
        # Build strict tone enforcement
        tone_instruction = ""
        if tone_lower == "formal":
            tone_instruction = "Tone: Formal / Professional. Use highly polite, structured, and respectful language (e.g. 'Good morning, may I please...')"
        elif tone_lower == "friendly":
            tone_instruction = "Tone: Friendly / Casual. Use warm, relaxed, and everyday language (e.g. 'Hey, could I get...')"
        else:
            tone_instruction = "Tone: Neutral / Polite. Use standard respectful, socially appropriate phrasing."

        system_prompt = f"""You are a strict syntax translator. You are NOT a chatbot. Do NOT answer the user's statement. Do NOT provide explanations.

Your objective is strictly to convert the user's raw, fragmented, or blunt input into a socially appropriate spoken sentence.
{tone_instruction}

CRITICAL RULES:
1. ONLY return the final translated sentence.
2. DO NOT change the core meaning or intent.
3. Fix grammar and expand fragments naturally.
4. DO NOT add new meaning.
5. If the user input is blunt/rude (e.g., 'you talk too much'), soften it respectfully (e.g., 'I am finding it hard to follow, could we slow down?').

You must respond in pure JSON format:
{{
  "generated_text": "The translated sentence here"
}}
"""
        messages = [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": text}
        ]

        try:
            if os.getenv("GROQ_API_KEY") is None:
                # Dummy fallback for immediate testing without API key
                print("WARNING: No GROQ_API_KEY. Using offline TTS translation fallback.")
                if tone_lower == "formal":
                    return "Good day, I would like to " + text.lower() + ", please."
                elif tone_lower == "friendly":
                    return "Hey! Could I get " + text.lower() + "?"
                return "Excuse me, I would like " + text.lower() + "."

            completion = client.chat.completions.create(
                model="llama3-70b-8192",
                messages=messages,
                response_format={"type": "json_object"},
                temperature=0.3, # Low temperature ensures it doesn't hallucinate meaning
            )
            
            response_json = json.loads(completion.choices[0].message.content)
            result = response_json.get("generated_text", text)

            # Intent validation safety block: Avoid the LLM rejecting the prompt or chatting.
            if "I cannot" in result or "As an AI" in result:
                return text # Safely fallback to raw sentence if AI drops constraints
                
            return result
            
        except Exception as e:
            print(f"Error calling Groq TTS Translator: {e}")
            return text # Fallback to raw text if error occurs
