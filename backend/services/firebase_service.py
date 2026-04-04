import firebase_admin
from firebase_admin import credentials, firestore
from typing import Dict, Any
import os

# Initialize Physical Firebase connection
_db = None

try:
    cred_path = os.path.join(os.path.dirname(__file__), "..", "serviceAccountKey.json")
    if os.path.exists(cred_path):
        cred = credentials.Certificate(cred_path)
        # Avoid re-initialization errors in hot-reloading
        if not firebase_admin._apps:
            firebase_admin.initialize_app(cred)
        _db = firestore.client()
        print("✅ [FIREBASE] Successfully connected to physical Firestore.")
    else:
        print("⚠️ [FIREBASE WARNING] serviceAccountKey.json not found! Firebase analytics will fail silently.")
except Exception as e:
    print(f"❌ [FIREBASE CRITICAL] Failed to initialize Google Firebase: {e}")


def test_connection():
    if _db is not None:
        try:
            _db.collection("test").add({
                "message": "Firebase connected!",
                "timestamp": firestore.SERVER_TIMESTAMP
            })
            print("🚀 [FIREBASE TEST] Wrote successful document to 'test' collection.")
        except Exception as e:
            print(f"❌ [FIREBASE TEST FAILED] {e}")


class FirebaseService:
    # ─── MEMORY INTEGRATION ─────────────────────────
    @staticmethod
    async def get_user_memory(user_id: str) -> dict:
        if not _db: 
            return {"likes": [], "dislikes": [], "triggers": []}
            
        try:
            doc = _db.collection("users").document(user_id).collection("memory").document("core_memory").get()
            if doc.exists:
                return doc.to_dict()
            return {"likes": [], "dislikes": [], "triggers": []}
        except Exception as e:
            print(f"Silent Firebase Error (get_memory): {e}")
            return {"likes": [], "dislikes": [], "triggers": []}

    @staticmethod
    async def update_user_memory(user_id: str, new_likes: list, new_dislikes: list, new_triggers: list) -> dict:
        if not _db: 
            return {"likes": new_likes, "dislikes": new_dislikes, "triggers": new_triggers}
            
        try:
            ref = _db.collection("users").document(user_id).collection("memory").document("core_memory")
            doc = ref.get()
            
            memory = {"likes": [], "dislikes": [], "triggers": []}
            if doc.exists:
                memory = doc.to_dict()
                
            current_likes = set(memory.get("likes", []))
            current_dislikes = set(memory.get("dislikes", []))
            current_triggers = set(memory.get("triggers", []))

            for x in new_likes: 
                if x.strip(): current_likes.add(x.strip())
            for x in new_dislikes: 
                if x.strip(): current_dislikes.add(x.strip())
            for x in new_triggers: 
                if x.strip(): current_triggers.add(x.strip())
            
            updated = {
                "likes": list(current_likes),
                "dislikes": list(current_dislikes),
                "triggers": list(current_triggers),
                "last_updated": firestore.SERVER_TIMESTAMP
            }
            # Merge True ensures we don't accidentally wipe out standard profile fields 
            # if we accidentally write to the wrong doc
            ref.set(updated, merge=True)
            return updated
        except Exception as e:
            print(f"Silent Firebase Error (update_memory): {e}")
            return {"likes": new_likes, "dislikes": new_dislikes, "triggers": new_triggers}

    # ─── BEHAVIORAL ANALYTICS ────────────────────────────
    @staticmethod
    async def save_wearable_event(user_id: str, data: dict):
        if not _db: return
        try:
            _db.collection("users").document(user_id).collection("wearable_events").add({
                **data,
                "server_timestamp": firestore.SERVER_TIMESTAMP
            })
            print(f"[FIRESTORE WRITE] Appended wearable event for {user_id}")
        except Exception as e:
            print(f"[FIRESTORE ERROR] Silent fail on wearable log: {e}")

    @staticmethod
    async def save_vr_session(user_id: str, data: dict):
        if not _db: return
        try:
            _db.collection("users").document(user_id).collection("vr_sessions").add({
                **data,
                "server_timestamp": firestore.SERVER_TIMESTAMP
            })
            print(f"[FIRESTORE WRITE] Appended VR session for {user_id}")
        except Exception as e:
            print(f"[FIRESTORE ERROR] Silent fail on VR log: {e}")

    @staticmethod
    async def save_calm_session(user_id: str, data: dict):
        if not _db: return
        try:
            _db.collection("users").document(user_id).collection("calm_sessions").add({
                **data,
                "server_timestamp": firestore.SERVER_TIMESTAMP
            })
            print(f"[FIRESTORE WRITE] Appended Calm session for {user_id}")
        except Exception as e:
            print(f"[FIRESTORE ERROR] Silent fail on Calm log: {e}")

    @staticmethod
    async def save_ai_insight(user_id: str, data: dict):
        if not _db: return
        try:
            _db.collection("users").document(user_id).collection("ai_insights").add({
                **data,
                "server_timestamp": firestore.SERVER_TIMESTAMP
            })
            print(f"[FIRESTORE WRITE] Appended AI Insight for {user_id}")
        except Exception as e:
            print(f"[FIRESTORE ERROR] Silent fail on AI Insight log: {e}")
