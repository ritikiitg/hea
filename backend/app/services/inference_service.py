"""
Inference Service — orchestrates ML models for risk assessment.
Combines NLP weak signal detection, time-series anomaly detection, and fusion classification.
"""

import time
import uuid
import logging
from typing import Optional
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)


class InferenceService:
    """
    Orchestrates the ML inference pipeline:
    1. WeakSignalDetector_NLP → extract symptom language patterns
    2. TimeSeriesAnomalyDetector → detect behavioral anomalies
    3. FusionClassifier → aggregate into risk levels
    """

    # Risk level thresholds
    RISK_THRESHOLDS = {
        "LOW": (0.0, 0.25),
        "WEAK": (0.25, 0.50),
        "MODERATE": (0.50, 0.75),
        "HIGH": (0.75, 1.0),
    }

    # Symptom keywords for rule-based fallback
    HIGH_CONCERN_KEYWORDS = [
        "chest pain", "shortness of breath", "severe headache",
        "vision loss", "numbness", "fainting", "blood",
        "heart palpitations", "difficulty breathing", "confusion"
    ]

    MODERATE_CONCERN_KEYWORDS = [
        "persistent pain", "recurring", "worsening", "chronic",
        "can't sleep", "losing weight", "always tired", "anxious",
        "depressed", "dizzy", "nausea", "fever"
    ]

    def __init__(self):
        self._nlp_model = None
        self._timeseries_model = None
        self._fusion_model = None
        self._loaded = False

    def _ensure_models_loaded(self):
        """Lazy-load models on first inference call."""
        if not self._loaded:
            logger.info("Loading ML models for inference (using rule-based fallback for prototype)...")
            self._loaded = True

    def assess_risk(
        self,
        symptom_text: Optional[str],
        emoji_inputs: list,
        checkbox_selections: list,
        daily_metrics: Optional[dict],
        historical_metrics: Optional[list] = None,
    ) -> dict:
        """
        Run full inference pipeline and return risk assessment.

        Returns:
            dict with risk_level, confidence_score, explanation_text, signal_details, inference_time_ms
        """
        start_time = time.time()
        self._ensure_models_loaded()

        # Step 1: NLP Signal Detection
        nlp_signals = self._analyze_text_signals(symptom_text, emoji_inputs, checkbox_selections)

        # Step 2: Time-Series Anomaly Detection
        ts_signals = self._analyze_timeseries_signals(daily_metrics, historical_metrics)

        # Step 3: Fusion Classification
        result = self._fuse_signals(nlp_signals, ts_signals)

        inference_time_ms = (time.time() - start_time) * 1000
        result["inference_time_ms"] = round(inference_time_ms, 2)

        logger.info(
            f"Risk assessment completed: level={result['risk_level']}, "
            f"confidence={result['confidence_score']:.2f}, "
            f"time={inference_time_ms:.1f}ms"
        )

        return result

    def _analyze_text_signals(
        self,
        symptom_text: Optional[str],
        emoji_inputs: list,
        checkbox_selections: list,
    ) -> dict:
        """
        NLP-based weak signal detection from text inputs.
        Prototype: rule-based keyword analysis + attention simulation.
        Production: DistilBERT fine-tuned model.
        """
        signals = []
        score = 0.0

        # Analyze symptom text
        if symptom_text:
            text_lower = symptom_text.lower()

            # High concern keywords
            for keyword in self.HIGH_CONCERN_KEYWORDS:
                if keyword in text_lower:
                    signals.append({
                        "signal": f"High-concern symptom mentioned: '{keyword}'",
                        "weight": 0.8,
                        "category": "nlp",
                    })
                    score = max(score, 0.8)

            # Moderate concern keywords
            for keyword in self.MODERATE_CONCERN_KEYWORDS:
                if keyword in text_lower:
                    signals.append({
                        "signal": f"Notable symptom mentioned: '{keyword}'",
                        "weight": 0.5,
                        "category": "nlp",
                    })
                    score = max(score, 0.5)

            # Check for frequency/duration language
            frequency_patterns = ["every day", "keeps happening", "won't go away", "for weeks", "getting worse"]
            for pattern in frequency_patterns:
                if pattern in text_lower:
                    signals.append({
                        "signal": f"Persistence indicator detected: '{pattern}'",
                        "weight": 0.4,
                        "category": "nlp",
                    })
                    score = min(score + 0.15, 1.0)

        # Analyze emoji signals
        negative_emojis = ["nauseated face", "face with thermometer", "sneezing face",
                          "dizzy", "anxious face", "crying face", "tired face",
                          "sleeping face", "confounded face", "weary face"]
        for e in emoji_inputs:
            if any(neg in e.lower() for neg in negative_emojis):
                signals.append({
                    "signal": f"Negative health emoji: '{e}'",
                    "weight": 0.3,
                    "category": "nlp",
                })
                score = min(score + 0.1, 1.0)

        # Analyze checkbox selections
        high_concern_checks = ["chest_pain", "shortness_of_breath", "heart_palpitations"]
        moderate_concern_checks = ["headache", "fatigue", "insomnia", "anxiety", "dizziness"]

        for check in checkbox_selections:
            if check in high_concern_checks:
                signals.append({
                    "signal": f"Critical symptom selected: {check.replace('_', ' ')}",
                    "weight": 0.7,
                    "category": "nlp",
                })
                score = max(score, 0.7)
            elif check in moderate_concern_checks:
                signals.append({
                    "signal": f"Symptom selected: {check.replace('_', ' ')}",
                    "weight": 0.4,
                    "category": "nlp",
                })
                score = max(score, 0.4)

        if not signals:
            signals.append({
                "signal": "No concerning patterns detected in text inputs",
                "weight": 0.0,
                "category": "nlp",
            })

        return {"signals": signals, "score": round(score, 3)}

    def _analyze_timeseries_signals(
        self,
        daily_metrics: Optional[dict],
        historical_metrics: Optional[list] = None,
    ) -> dict:
        """
        Time-series anomaly detection from daily metrics.
        Prototype: statistical baseline with Z-score detection.
        Production: LSTM + statistical baseline.
        """
        signals = []
        score = 0.0

        if not daily_metrics:
            return {"signals": [{"signal": "No daily metrics provided", "weight": 0.0, "category": "timeseries"}], "score": 0.0}

        # Sleep analysis
        sleep = daily_metrics.get("sleep_hours")
        if sleep is not None:
            if sleep < 4:
                signals.append({"signal": f"Critically low sleep: {sleep}h (< 4h)", "weight": 0.7, "category": "timeseries"})
                score = max(score, 0.7)
            elif sleep < 6:
                signals.append({"signal": f"Below-average sleep: {sleep}h (< 6h)", "weight": 0.4, "category": "timeseries"})
                score = max(score, 0.4)
            elif sleep > 12:
                signals.append({"signal": f"Excessive sleep: {sleep}h (> 12h)", "weight": 0.5, "category": "timeseries"})
                score = max(score, 0.5)

        # Mood analysis
        mood = daily_metrics.get("mood_score")
        if mood is not None:
            if mood <= 2:
                signals.append({"signal": f"Very low mood score: {mood}/10", "weight": 0.6, "category": "timeseries"})
                score = max(score, 0.6)
            elif mood <= 4:
                signals.append({"signal": f"Low mood score: {mood}/10", "weight": 0.35, "category": "timeseries"})
                score = max(score, 0.35)

        # Energy analysis
        energy = daily_metrics.get("energy_level")
        if energy is not None and energy <= 3:
            signals.append({"signal": f"Low energy level: {energy}/10", "weight": 0.4, "category": "timeseries"})
            score = max(score, 0.4)

        # Stress analysis
        stress = daily_metrics.get("stress_level")
        if stress is not None and stress >= 8:
            signals.append({"signal": f"High stress level: {stress}/10", "weight": 0.5, "category": "timeseries"})
            score = max(score, 0.5)

        # Historical trend analysis (if historical data available)
        if historical_metrics and len(historical_metrics) >= 3:
            # Check for declining trends
            moods = [m.get("mood_score") for m in historical_metrics if m.get("mood_score")]
            if len(moods) >= 3:
                recent_avg = sum(moods[-3:]) / 3
                overall_avg = sum(moods) / len(moods)
                if recent_avg < overall_avg * 0.7:
                    signals.append({
                        "signal": f"Declining mood trend detected (recent avg: {recent_avg:.1f} vs overall: {overall_avg:.1f})",
                        "weight": 0.6,
                        "category": "timeseries",
                    })
                    score = max(score, 0.6)

            sleeps = [m.get("sleep_hours") for m in historical_metrics if m.get("sleep_hours")]
            if len(sleeps) >= 3:
                recent_avg = sum(sleeps[-3:]) / 3
                overall_avg = sum(sleeps) / len(sleeps)
                if recent_avg < overall_avg * 0.75:
                    signals.append({
                        "signal": f"Declining sleep trend detected (recent avg: {recent_avg:.1f}h vs overall: {overall_avg:.1f}h)",
                        "weight": 0.55,
                        "category": "timeseries",
                    })
                    score = max(score, 0.55)

        if not signals:
            signals.append({"signal": "Daily metrics within normal range", "weight": 0.0, "category": "timeseries"})

        return {"signals": signals, "score": round(score, 3)}

    def _fuse_signals(self, nlp_signals: dict, ts_signals: dict) -> dict:
        """
        Fusion classifier: combine NLP and time-series signals.
        Weighted ensemble with attention-based explanation generation.
        """
        # Weighted fusion (NLP: 0.55, TimeSeries: 0.45)
        nlp_weight = 0.55
        ts_weight = 0.45
        combined_score = (nlp_signals["score"] * nlp_weight) + (ts_signals["score"] * ts_weight)
        combined_score = round(min(combined_score, 1.0), 3)

        # Determine risk level
        risk_level = "LOW"
        for level, (low, high) in self.RISK_THRESHOLDS.items():
            if low <= combined_score < high:
                risk_level = level
                break
        if combined_score >= 1.0:
            risk_level = "HIGH"

        # Generate human-readable explanation
        explanation = self._generate_explanation(risk_level, nlp_signals, ts_signals, combined_score)

        # Combine all signal details
        all_signals = nlp_signals["signals"] + ts_signals["signals"]
        # Sort by weight descending
        all_signals.sort(key=lambda s: s["weight"], reverse=True)

        return {
            "risk_level": risk_level,
            "confidence_score": combined_score,
            "explanation_text": explanation,
            "signal_details": {
                "nlp_score": nlp_signals["score"],
                "timeseries_score": ts_signals["score"],
                "combined_score": combined_score,
                "signals": all_signals[:10],  # Top 10 signals
            },
            "model_version": "v0.1.0-prototype",
        }

    def _generate_explanation(self, risk_level: str, nlp_signals: dict,
                               ts_signals: dict, combined_score: float) -> str:
        """Generate a simple, human-readable explanation for non-clinical users."""
        explanations = {
            "LOW": "Your recent inputs look good! No concerning patterns detected. Keep tracking to maintain your health awareness.",
            "WEAK": "We noticed a few subtle signals in your recent inputs. Nothing urgent, but worth keeping an eye on. Continue logging daily to help us track any changes.",
            "MODERATE": "We've detected some patterns that suggest you might want to pay closer attention to your health. Consider reviewing the signals below and consult a healthcare professional if symptoms persist.",
            "HIGH": "We've detected several concerning signals in your recent health data. We strongly recommend speaking with a healthcare professional soon. Remember, Hea is a wellness tool — not a medical diagnosis.",
        }

        base_explanation = explanations.get(risk_level, explanations["LOW"])

        # Add specific signal context
        top_nlp = [s for s in nlp_signals["signals"] if s["weight"] > 0.3]
        top_ts = [s for s in ts_signals["signals"] if s["weight"] > 0.3]

        details = []
        if top_nlp:
            details.append(f"Your symptom descriptions raised {len(top_nlp)} notable signal(s)")
        if top_ts:
            details.append(f"Your daily metrics showed {len(top_ts)} pattern change(s)")

        if details:
            base_explanation += " " + ". ".join(details) + "."

        return base_explanation


# Singleton instance
inference_service = InferenceService()
