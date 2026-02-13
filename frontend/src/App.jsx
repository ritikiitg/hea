import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Navbar from './components/Navbar.jsx';
import OnboardingFlow from './components/OnboardingFlow.jsx';
import DailyInputForm from './components/DailyInputForm.jsx';
import RiskInsightCard from './components/RiskInsightCard.jsx';
import SettingsPrivacy from './components/SettingsPrivacy.jsx';
import AIInsightsPanel from './components/AIInsightsPanel.jsx';

// ─── Mock Data (for prototype demo — no backend needed) ──────
const MOCK_ASSESSMENT = {
    id: 'assess-001',
    risk_level: 'WEAK',
    confidence_score: 0.62,
    explanation_text:
        "We picked up a few subtle signals worth noting. Your sleep has been slightly below average, and mood scores have dipped. These are early-stage patterns we'll continue monitoring. No action needed right now, but keep tracking.",
    signal_details: {
        signals: [
            { signal: 'Sleep below personal baseline (5.5h avg vs 7h usual)', category: 'timeseries', weight: 0.55 },
            { signal: 'Mood trending downward over 3 days', category: 'timeseries', weight: 0.45 },
            { signal: 'Fatigue language detected in symptom text', category: 'nlp', weight: 0.40 },
            { signal: 'Stress level elevated (7/10)', category: 'timeseries', weight: 0.35 },
        ],
    },
    feedback_received: 'none',
    created_at: new Date().toISOString(),
};

const MOCK_HISTORY = [
    { id: 'a1', risk_level: 'LOW', confidence_score: 0.78, date: '2024-02-10', explanation_text: 'Patterns stable.' },
    { id: 'a2', risk_level: 'LOW', confidence_score: 0.81, date: '2024-02-11', explanation_text: 'All normal.' },
    { id: 'a3', risk_level: 'WEAK', confidence_score: 0.55, date: '2024-02-12', explanation_text: 'Minor dip in sleep.' },
    { id: 'a4', risk_level: 'WEAK', confidence_score: 0.62, date: '2024-02-13', explanation_text: 'Fatigue signals continuing.' },
];

// ─── Landing Page ────────────────────────────────────
function LandingPage() {
    return (
        <div className="page-wrapper">
            <div className="app-container">
                <div className="text-center" style={{ paddingTop: 60, paddingBottom: 40 }}>
                    <div className="animate-in">
                        <span style={{ fontSize: '3.5rem' }}>🩺</span>
                        <h1 style={{ marginTop: 16, fontSize: '2.5rem', fontWeight: 800 }}>
                            Catch health risks <span style={{ color: 'var(--hea-primary)' }}>before they catch you</span>
                        </h1>
                        <p style={{ maxWidth: 560, margin: '16px auto 0', fontSize: '1.1rem', lineHeight: 1.7, color: 'var(--hea-text-body)' }}>
                            Hea's AI monitors your daily health inputs and detects subtle patterns that could signal emerging risks — no medical records required.
                        </p>
                    </div>
                </div>

                <div className="grid-3 animate-in animate-delay-1" style={{ maxWidth: 900, margin: '0 auto 60px' }}>
                    <div className="card text-center" style={{ padding: 32 }}>
                        <span style={{ fontSize: '2.2rem' }}>📝</span>
                        <h3 style={{ marginTop: 12, marginBottom: 8 }}>Log Daily</h3>
                        <p className="text-sm text-muted">Share how you're feeling in your own words, emojis, or quick checkboxes.</p>
                    </div>
                    <div className="card text-center" style={{ padding: 32 }}>
                        <span style={{ fontSize: '2.2rem' }}>🧠</span>
                        <h3 style={{ marginTop: 12, marginBottom: 8 }}>AI Analysis</h3>
                        <p className="text-sm text-muted">Our models detect weak signals across NLP patterns and time-series metrics.</p>
                    </div>
                    <div className="card text-center" style={{ padding: 32 }}>
                        <span style={{ fontSize: '2.2rem' }}>💡</span>
                        <h3 style={{ marginTop: 12, marginBottom: 8 }}>Clear Insights</h3>
                        <p className="text-sm text-muted">Get plain-language explanations and actionable next steps, not medical jargon.</p>
                    </div>
                </div>

                {/* Demo Assessment */}
                <div style={{ maxWidth: 640, margin: '0 auto' }}>
                    <div className="text-center mb-lg animate-in animate-delay-2">
                        <h2>Live Demo Assessment</h2>
                        <p className="text-muted">Experience how Hea presents risk insights</p>
                    </div>
                    <div className="animate-in animate-delay-3">
                        <RiskInsightCard assessment={MOCK_ASSESSMENT} />
                    </div>

                    {/* Mini Timeline */}
                    <div className="card animate-in" style={{ marginTop: 24 }}>
                        <h3 style={{ marginBottom: 16 }}>📅 Recent History</h3>
                        <div style={{ display: 'flex', gap: 8 }}>
                            {MOCK_HISTORY.map(h => {
                                const bg = h.risk_level === 'LOW' ? 'var(--risk-low)' : h.risk_level === 'WEAK' ? 'var(--risk-weak)' : 'var(--risk-moderate)';
                                return (
                                    <div key={h.id} style={{
                                        flex: 1, textAlign: 'center', padding: 12,
                                        borderRadius: 'var(--radius-md)', background: 'var(--hea-bg-light)',
                                    }}>
                                        <div style={{
                                            width: 10, height: 10, borderRadius: '50%',
                                            background: bg, margin: '0 auto 6px',
                                        }} />
                                        <p className="text-sm" style={{ fontWeight: 600 }}>{h.date.split('-')[2]}</p>
                                        <p style={{ fontSize: '0.7rem' }} className="text-muted">{h.risk_level}</p>
                                    </div>
                                );
                            })}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

// ─── Daily Log Page ──────────────────────────────────
function DailyPage() {
    const [submitted, setSubmitted] = useState(false);
    const [loading, setLoading] = useState(false);
    const [lastLog, setLastLog] = useState(null);

    const handleSubmit = async (data) => {
        setLoading(true);
        setLastLog(data);
        // Simulate API call
        await new Promise(r => setTimeout(r, 1200));
        setLoading(false);
        setSubmitted(true);
    };

    if (submitted) {
        return (
            <div className="page-wrapper">
                <div className="app-container" style={{ maxWidth: 640, margin: '0 auto' }}>
                    <div className="card text-center animate-in" style={{ padding: 48 }}>
                        <span style={{ fontSize: '3rem' }}>✨</span>
                        <h2 style={{ marginTop: 16, marginBottom: 8 }}>Log Submitted!</h2>
                        <p className="text-muted mb-lg">Your data is being analyzed. Here's your latest insight:</p>
                        <RiskInsightCard assessment={MOCK_ASSESSMENT} onFeedback={(type, id) => {
                            alert(`Feedback "${type}" submitted for assessment ${id}`);
                        }} />
                    </div>

                    {/* AI Quick Tip — Gemini Flash */}
                    <div style={{ marginTop: 20 }}>
                        <AIInsightsPanel mode="quick-tip" dailyLog={lastLog} autoLoad={true} />
                    </div>

                    <div className="text-center" style={{ marginTop: 20 }}>
                        <button className="btn btn-secondary" onClick={() => { setSubmitted(false); setLastLog(null); }}>
                            Submit Another Log
                        </button>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="page-wrapper">
            <div className="app-container" style={{ maxWidth: 640, margin: '0 auto' }}>
                <div className="page-header">
                    <h1>📝 Daily Health Log</h1>
                    <p>Take a minute to check in. Every entry makes your insights smarter.</p>
                </div>
                <DailyInputForm onSubmit={handleSubmit} isLoading={loading} />
            </div>
        </div>
    );
}

// ─── Insights Page ───────────────────────────────────
function InsightsPage() {
    return (
        <div className="page-wrapper">
            <div className="app-container" style={{ maxWidth: 640, margin: '0 auto' }}>
                <div className="page-header">
                    <h1>💡 Your Insights</h1>
                    <p>AI-powered analysis of your health patterns over time</p>
                </div>

                {/* Gemini Pro Deep Analysis */}
                <div style={{ marginBottom: 24 }}>
                    <AIInsightsPanel mode="deep-analysis" userId="demo-user" />
                </div>

                <RiskInsightCard assessment={MOCK_ASSESSMENT} onFeedback={(type, id) => {
                    alert(`Feedback "${type}" submitted for ${id}`);
                }} />
                <div className="card" style={{ marginTop: 24 }}>
                    <h3 style={{ marginBottom: 16 }}>📈 Assessment History</h3>
                    {MOCK_HISTORY.map(h => (
                        <div key={h.id} style={{
                            display: 'flex', justifyContent: 'space-between', alignItems: 'center',
                            padding: '12px 0', borderBottom: '1px solid var(--hea-border-light)',
                        }}>
                            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                                <span className={`badge badge-${h.risk_level.toLowerCase()}`}>{h.risk_level}</span>
                                <span className="text-sm">{h.explanation_text}</span>
                            </div>
                            <span className="text-sm text-muted">{h.date}</span>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}

// ─── Settings Page ───────────────────────────────────
function SettingsPage() {
    return (
        <div className="page-wrapper">
            <div className="app-container" style={{ maxWidth: 640, margin: '0 auto' }}>
                <div className="page-header">
                    <h1>⚙️ Settings</h1>
                    <p>Manage your privacy, consent, and data</p>
                </div>
                <SettingsPrivacy
                    onUpdate={(s) => alert('Settings saved: ' + JSON.stringify(s, null, 2))}
                    onExport={() => alert('Data export initiated')}
                    onDelete={() => alert('Data deleted')}
                />
            </div>
        </div>
    );
}

// ─── App Root ────────────────────────────────────────
export default function App() {
    const [isOnboarded, setIsOnboarded] = useState(() => {
        return localStorage.getItem('hea_onboarded') === 'true';
    });

    const handleOnboardComplete = (consents) => {
        localStorage.setItem('hea_onboarded', 'true');
        localStorage.setItem('hea_consents', JSON.stringify(consents));
        setIsOnboarded(true);
    };

    if (!isOnboarded) {
        return (
            <Router>
                <OnboardingFlow onComplete={handleOnboardComplete} />
            </Router>
        );
    }

    return (
        <Router>
            <Navbar />
            <Routes>
                <Route path="/" element={<LandingPage />} />
                <Route path="/daily" element={<DailyPage />} />
                <Route path="/insights" element={<InsightsPage />} />
                <Route path="/settings" element={<SettingsPage />} />
                <Route path="*" element={<Navigate to="/" />} />
            </Routes>
        </Router>
    );
}
