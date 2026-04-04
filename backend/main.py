from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import chat, tts, analytics, dashboard
from dotenv import load_dotenv

# Load .env variables (like GROQ_API_KEY)
load_dotenv()

app = FastAPI(title="SPECTRA AI Ecosystem Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(chat.router, prefix="/api/v1")
app.include_router(tts.router, prefix="/api/v1")
app.include_router(analytics.router, prefix="/api/v1")
app.include_router(dashboard.router, prefix="/api/v1")

@app.get("/")
def read_root():
    return {"status": "SPECTRA API is actively running."}
