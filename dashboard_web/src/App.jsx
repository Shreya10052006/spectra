import { useState, useEffect } from 'react'
import './App.css'

function App() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Hardcoded for Demo purposes. In production, this pulls dynamically from Therapist selection.
  const FALLBACK_USER_ID = "fallback_anonymous_user";

  useEffect(() => {
    // 1. Core Intelligence API Connection built directly against FastAPI
    fetch(`http://127.0.0.1:8000/api/v1/dashboard/${FALLBACK_USER_ID}`)
      .then((res) => {
        if (!res.ok) throw new Error("Failed to fetch analytical base");
        return res.json();
      })
      .then((payload) => {
        setData(payload.data);
        setLoading(false);
      })
      .catch((err) => {
        setError(err.message);
        setLoading(false);
      });
  }, []);

  if (loading) return <div className="container centered"><h2>Loading Intelligence Layer...</h2></div>;
  if (error) return <div className="container centered"><h2>API Conflict: {error}</h2></div>;

  return (
    <div className="container">
      <header className="header">
        <h1>Therapist Dashboard <span>| SPECTRA System</span></h1>
        <p className="subtitle">Real-time analytical extraction of behavioral loops across modules</p>
      </header>

      <div className="grid">
        {/* A. BEHAVIORAL INSIGHTS */}
        <section className="card card-insights">
          <h3>🧠 Behavioral Patterns</h3>
          <p className="description">Extracted from AI Companion memory matrices</p>
          <ul>
            {data?.insights?.map((insight, index) => (
              <li key={index}>"{insight}"</li>
            ))}
          </ul>
        </section>

        {/* B. VR PERFORMANCE */}
        <section className="card card-vr">
          <h3>🥽 VR Performance</h3>
          <div className="metric">
            <span className="value">{data?.vr_sessions || 0}</span>
            <span className="label">Total Training Sessions</span>
          </div>
          <p className="placeholder">Detailed reaction timing analytics scaling soon...</p>
        </section>

        {/* C. WEARABLE INSIGHTS */}
        <section className="card card-wearable">
          <h3>❤️ Stress Tracking</h3>
          <div className="metric">
            <span className="value">{data?.total_stress_events || 0}</span>
            <span className="label">Stress Spikes Logged</span>
          </div>
          <p className="placeholder">Smooth spline graphing engine under construction.</p>
        </section>
        
        {/* D. CROSS-FEATURE CORRELATION (Core Intel) */}
        <section className="card card-correlation" style={{ gridColumn: '1 / -1' }}>
          <h3>🔗 Cross-Feature Correlation</h3>
          <p className="ai-highlight">
            <strong>System Analyst Node:</strong> User displays elevated stress triggers ({data?.total_stress_events}) alongside ({data?.calm_time / 60}m) active calm mode usage. High likelihood of strong self-regulation.
          </p>
        </section>
      </div>
    </div>
  )
}

export default App
