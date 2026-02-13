import React, { useState } from 'react';

const SYMPTOM_OPTIONS = [
    { key: 'headache', label: 'Headache', icon: '🤕' },
    { key: 'fatigue', label: 'Fatigue', icon: '😫' },
    { key: 'nausea', label: 'Nausea', icon: '🤢' },
    { key: 'dizziness', label: 'Dizziness', icon: '😵' },
    { key: 'insomnia', label: 'Insomnia', icon: '😴' },
    { key: 'anxiety', label: 'Anxiety', icon: '😰' },
    { key: 'joint_pain', label: 'Joint Pain', icon: '🦴' },
    { key: 'muscle_ache', label: 'Muscle Ache', icon: '💪' },
    { key: 'shortness_of_breath', label: 'Short of Breath', icon: '😤' },
    { key: 'chest_pain', label: 'Chest Pain', icon: '💔' },
    { key: 'stomach_pain', label: 'Stomach Pain', icon: '🤮' },
    { key: 'back_pain', label: 'Back Pain', icon: '🔙' },
    { key: 'fever', label: 'Fever', icon: '🤒' },
    { key: 'cough', label: 'Cough', icon: '🤧' },
    { key: 'mood_changes', label: 'Mood Changes', icon: '😢' },
    { key: 'concentration', label: 'Poor Focus', icon: '🧠' },
];

const EMOJI_MOODS = [
    { emoji: '😊', label: 'Great' },
    { emoji: '🙂', label: 'Good' },
    { emoji: '😐', label: 'Okay' },
    { emoji: '😟', label: 'Not great' },
    { emoji: '😢', label: 'Bad' },
    { emoji: '😫', label: 'Terrible' },
];

export default function DailyInputForm({ onSubmit, isLoading }) {
    const [symptomText, setSymptomText] = useState('');
    const [selectedSymptoms, setSelectedSymptoms] = useState([]);
    const [selectedEmojis, setSelectedEmojis] = useState([]);
    const [metrics, setMetrics] = useState({
        sleep_hours: 7,
        mood_score: 5,
        energy_level: 5,
        stress_level: 5,
        steps_count: 5000,
        water_intake_ml: 1500,
    });

    const toggleSymptom = (key) => {
        setSelectedSymptoms(prev =>
            prev.includes(key) ? prev.filter(s => s !== key) : [...prev, key]
        );
    };

    const toggleEmoji = (emoji) => {
        setSelectedEmojis(prev =>
            prev.includes(emoji) ? prev.filter(e => e !== emoji) : [...prev, emoji]
        );
    };

    const updateMetric = (key, value) => {
        setMetrics(prev => ({ ...prev, [key]: Number(value) }));
    };

    const handleSubmit = (e) => {
        e.preventDefault();
        onSubmit({
            symptom_text: symptomText || null,
            emoji_inputs: selectedEmojis,
            checkbox_selections: selectedSymptoms,
            daily_metrics: metrics,
            input_source: 'web',
        });
    };

    return (
        <form onSubmit={handleSubmit}>
            <div className="card animate-in" style={{ marginBottom: 24 }}>
                <h3 style={{ marginBottom: 4 }}>📝 How are you feeling today?</h3>
                <p className="text-sm text-muted mb-md">Describe any symptoms or how you're feeling in your own words</p>
                <textarea
                    className="input-field"
                    placeholder="E.g., 'Woke up with a headache, feeling a bit tired. Didn't sleep well last night...'"
                    value={symptomText}
                    onChange={(e) => setSymptomText(e.target.value)}
                    rows={4}
                    maxLength={5000}
                />
                <p className="text-sm text-muted" style={{ marginTop: 4, textAlign: 'right' }}>
                    {symptomText.length}/5000
                </p>
            </div>

            <div className="card animate-in animate-delay-1" style={{ marginBottom: 24 }}>
                <h3 style={{ marginBottom: 4 }}>😊 Quick Mood Check</h3>
                <p className="text-sm text-muted mb-md">How's your overall mood?</p>
                <div className="emoji-grid">
                    {EMOJI_MOODS.map(({ emoji, label }) => (
                        <button
                            key={emoji}
                            type="button"
                            className={`emoji-btn ${selectedEmojis.includes(emoji) ? 'selected' : ''}`}
                            onClick={() => toggleEmoji(emoji)}
                            title={label}
                        >
                            {emoji}
                        </button>
                    ))}
                </div>
            </div>

            <div className="card animate-in animate-delay-2" style={{ marginBottom: 24 }}>
                <h3 style={{ marginBottom: 4 }}>🩺 Any of these apply?</h3>
                <p className="text-sm text-muted mb-md">Select any symptoms you're experiencing</p>
                <div className="checkbox-grid">
                    {SYMPTOM_OPTIONS.map(({ key, label, icon }) => (
                        <label
                            key={key}
                            className={`checkbox-item ${selectedSymptoms.includes(key) ? 'active' : ''}`}
                        >
                            <input
                                type="checkbox"
                                checked={selectedSymptoms.includes(key)}
                                onChange={() => toggleSymptom(key)}
                            />
                            <span>{icon}</span>
                            <span>{label}</span>
                        </label>
                    ))}
                </div>
            </div>

            <div className="card animate-in animate-delay-3" style={{ marginBottom: 24 }}>
                <h3 style={{ marginBottom: 16 }}>📊 Daily Metrics</h3>

                <div className="input-group">
                    <label>😴 Sleep (hours)</label>
                    <div className="slider-container">
                        <input type="range" className="slider" min="0" max="16" step="0.5" value={metrics.sleep_hours} onChange={(e) => updateMetric('sleep_hours', e.target.value)} />
                        <span className="slider-value">{metrics.sleep_hours}h</span>
                    </div>
                </div>

                <div className="input-group">
                    <label>😊 Mood (1-10)</label>
                    <div className="slider-container">
                        <input type="range" className="slider" min="1" max="10" step="1" value={metrics.mood_score} onChange={(e) => updateMetric('mood_score', e.target.value)} />
                        <span className="slider-value">{metrics.mood_score}</span>
                    </div>
                </div>

                <div className="input-group">
                    <label>⚡ Energy Level (1-10)</label>
                    <div className="slider-container">
                        <input type="range" className="slider" min="1" max="10" step="1" value={metrics.energy_level} onChange={(e) => updateMetric('energy_level', e.target.value)} />
                        <span className="slider-value">{metrics.energy_level}</span>
                    </div>
                </div>

                <div className="input-group">
                    <label>😓 Stress Level (1-10)</label>
                    <div className="slider-container">
                        <input type="range" className="slider" min="1" max="10" step="1" value={metrics.stress_level} onChange={(e) => updateMetric('stress_level', e.target.value)} />
                        <span className="slider-value">{metrics.stress_level}</span>
                    </div>
                </div>

                <div className="grid-2">
                    <div className="input-group">
                        <label>🚶 Steps</label>
                        <input type="number" className="input-field" value={metrics.steps_count} onChange={(e) => updateMetric('steps_count', e.target.value)} min="0" max="50000" />
                    </div>
                    <div className="input-group">
                        <label>💧 Water (ml)</label>
                        <input type="number" className="input-field" value={metrics.water_intake_ml} onChange={(e) => updateMetric('water_intake_ml', e.target.value)} min="0" max="5000" />
                    </div>
                </div>
            </div>

            <button
                type="submit"
                className="btn btn-primary btn-lg"
                style={{ width: '100%' }}
                disabled={isLoading}
            >
                {isLoading ? 'Submitting...' : 'Submit Daily Log ✨'}
            </button>
        </form>
    );
}
