import os
import json
from datetime import datetime
from groq import Groq
from services.firebase_service import _db, FirebaseService # We can access physical db or use standard get
# Note: Since _db is managed by firebase_service, we'll try to use _db directly for queries if available, 
# otherwise return empty fallbacks.

client = Groq(api_key=os.getenv("GROQ_API_KEY", "mock_key_if_missing"))

class DashboardService:
    @staticmethod
    async def get_user_dashboard(user_id: str) -> dict:
        if not _db:
            return DashboardService._get_mock_fallback()

        try:
            today_str = datetime.utcnow().strftime("%Y-%m-%d")

            # 1. Gather Wearables
            wearables_ref = _db.collection("users").document(user_id).collection("wearable_events")
            wearables_docs = wearables_ref.get()
            total_spikes = 0
            today_spikes = 0
            for doc in wearables_docs:
                data = doc.to_dict()
                if data.get("event_type") in ["spike", "simulated_spike"]:
                    total_spikes += 1
                    if data.get("server_timestamp", "").startswith(today_str):
                        today_spikes += 1

            # 2. Gather Calm Sessions
            calm_ref = _db.collection("users").document(user_id).collection("calm_sessions")
            calm_docs = calm_ref.get()
            total_calm_time = 0
            today_calm_time = 0
            for doc in calm_docs:
                data = doc.to_dict()
                dur = data.get("duration_seconds", 0)
                total_calm_time += dur
                if data.get("server_timestamp", "").startswith(today_str):
                    today_calm_time += dur

            # 3. Gather VR Sessions
            vr_ref = _db.collection("users").document(user_id).collection("vr_sessions")
            vr_docs = vr_ref.get()
            total_vr_sessions = len(vr_docs)
            today_vr_sessions = sum(1 for doc in vr_docs if doc.to_dict().get("server_timestamp", "").startswith(today_str))

            # 4. Gather Core Memory (for context)
            memory = await FirebaseService.get_user_memory(user_id)
            
            # Simple Daily Summary Logic (Deterministic)
            if today_spikes > 2:
                daily_summary = f"You had {today_spikes} busy moments today, but you managed through them."
            elif today_spikes > 0:
                daily_summary = "You experienced a slightly stressful moment today, but kept going."
            elif today_calm_time > 0:
                daily_summary = "You had a very peaceful and grounded day today."
            else:
                daily_summary = "You're just getting started today. Take it one step at a time."

            # 5. LLM Pattern Generation (Strict Output)
            insights = DashboardService._generate_insights(
                spikes=total_spikes,
                calm_time=total_calm_time,
                vr_sessions=total_vr_sessions,
                memory=memory
            )

            return {
                "daily_summary": daily_summary,
                "calm_time": total_calm_time,
                "today_calm_time": today_calm_time,
                "vr_sessions": total_vr_sessions,
                "today_vr_sessions": today_vr_sessions,
                "total_stress_events": total_spikes,
                "insights": insights
            }

        except Exception as e:
            print(f"Error compiling dashboard: {e}")
            return DashboardService._get_mock_fallback()

    @staticmethod
    def _generate_insights(spikes: int, calm_time: int, vr_sessions: int, memory: dict) -> list:
        # LLM Strict Guardrails
        likes = ", ".join(memory.get("likes", [])) or "None identified yet"
        dislikes = ", ".join(memory.get("dislikes", [])) or "None identified yet"
        triggers = ", ".join(memory.get("triggers", [])) or "None identified yet"

        system_prompt = f"""You are the Pattern Extraction Engine for SPECTRA, a supportive system for autistic individuals.
Your job is to generate exactly 3 short, calming sentences describing the user's behavioral patterns based ONLY on the data below.

--- RAW DATA ---
Total Stress Spikes Logged: {spikes}
Total Calm Mode Time: {calm_time} seconds
VR Social Sessions Practiced: {vr_sessions}
Known Likes: {likes}
Known Dislikes/Triggers: {dislikes}, {triggers}

--- STRICT RULES ---
1. NEVER use clinical language.
2. NEVER diagnose (e.g. Do not say "You suffer from anxiety").
3. ONLY use soft phrases like: "It seems like...", "You might feel...", "You appear to prefer...".
4. Return exactly 3 sentences in a JSON array.

Return format:
{{
  "insights": ["sentence 1", "sentence 2", "sentence 3"]
}}
"""
        
        try:
            if os.getenv("GROQ_API_KEY") is None:
                return DashboardService._get_deterministic_insights(spikes, calm_time, vr_sessions)

            completion = client.chat.completions.create(
                model="llama3-8b-8192", # Switched to 8b for ultra-fast simple extraction
                messages=[{"role": "system", "content": system_prompt}],
                response_format={"type": "json_object"},
                temperature=0.3, # Low temp = strict adherence
            )
            data = json.loads(completion.choices[0].message.content)
            insights = data.get("insights", [])
            
            # Enforce exactly 3 constraint safely
            if not insights or len(insights) == 0:
                return DashboardService._get_deterministic_insights(spikes, calm_time, vr_sessions)
            return insights[:3]
            
        except Exception as e:
            print(f"Insight Generation Error: {e}")
            return DashboardService._get_deterministic_insights(spikes, calm_time, vr_sessions)

    @staticmethod
    def _get_deterministic_insights(spikes: int, calm_time: int, vr_sessions: int) -> list:
        """Fallback if LLM fails or keys are missing."""
        base = ["You are taking steps to understand your daily rhythm."]
        if spikes > 3:
            base.append("Busy or loud environments might be overwhelming for you recently.")
        else:
            base.append("It seems like you've been maintaining a fairly steady pace.")
            
        if calm_time > 300:
            base.append("You appear to find comfort in taking quiet breaks.")
        elif vr_sessions > 0:
            base.append("Practicing social interactions seems to be a goal of yours.")
        else:
            base.append("Remember that you can always use the calm space when you need it.")
            
        return base

    @staticmethod
    def _get_mock_fallback() -> dict:
        return {
            "daily_summary": "You're just getting started. That's great.",
            "calm_time": 0,
            "today_calm_time": 0,
            "vr_sessions": 0,
            "today_vr_sessions": 0,
            "total_stress_events": 0,
            "insights": ["You are taking steps to understand your daily rhythm.", "It seems like you're exploring the system at your own pace.", "Remember that you can always use the calm space when you need it."]
        }
