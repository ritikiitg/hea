# Hea — Early Health Risk Detector

![Hea Banner](https://via.placeholder.com/1200x400/EFF5F0/3B6BF5?text=Hea+Early+Health+Risk+Detector)

> **Catch health risks before they catch you.**
> An AI-powered wellness companion that detects subtle health signals from self-reported data — no medical records required.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Python](https://img.shields.io/badge/Python-3.11-blue)](https://python.org)
[![React](https://img.shields.io/badge/React-18-61DAFB)](https://react.dev)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.109-009688)](https://fastapi.tiangolo.com)
[![Terraform](https://img.shields.io/badge/Terraform-1.6-623CE4)](https://terraform.io)

## 📖 Overview

Hea is a **privacy-first AI prototype** designed to identify weak signals of emerging health risks (e.g., burnout, fatigue, early viral symptoms) using only user-reported data. It combines **Natural Language Processing (NLP)** on symptom descriptions and **Time-Series Analysis** on daily metrics (sleep, mood, steps) to provide actionable, non-clinical insights.

### Key Features
- **📝 Easy Daily Logging**: Free-text symptom entry, emoji mood picker, and quick sliders.
- **🧠 Hybrid AI Detection**: Fuses DistilBERT-based NLP with LSTM time-series analysis.
- **🔒 Privacy First**: Zero PHI storage requirements, GDPR-compliant consent flow, and full data control.
- **💡 Explainable Insights**: Human-readable explanations for every risk assessment (no "black box" AI).
- **🇬🇧 UK Data Residency**: Infrastructure designed for UK GDPR compliance.

---

## 🏗️ Architecture

The project is organized into four main pillars:

```
hea/
├── backend/        # FastAPI application (Python)
├── frontend/       # React application (Vite + Node.js)
├── ml/             # Machine Learning pipelines & training scripts
└── infra/          # Infrastructure as Code (Terraform for AWS)
```

### Tech Stack
- **Backend**: Python 3.11, FastAPI, SQLAlchemy, Pydantic, OWASP Sanitization
- **Frontend**: React 18, Vite, React Router, Custom Design System (CSS)
- **ML**: PyTorch, Transformers (DistilBERT), LSTM, Scikit-learn
- **Infrastructure**: AWS (Lambda, API Gateway, DynamoDB, S3), Terraform

---

## 🚀 Getting Started

### Prerequisites
- Node.js v20+
- Python 3.11+
- Terraform 1.5+ (optional, for deployment)
- AWS CLI (optional, for deployment)

### 1. Backend Setup

```bash
# 1. Navigate to backend
cd backend

# 2. Create virtual environment
python -m venv venv

# 3. Activate virtual environment
# Windows (PowerShell):
venv\Scripts\Activate
# Mac/Linux:
source venv/bin/activate

# 4. Install dependencies
pip install -r requirements.txt

# 5. Start the API server
# Using python -m to ensure correct environment
python -m uvicorn app.main:app --reload
```
API will be running at `http://localhost:8000`. API Docs at `http://localhost:8000/docs`.

### 2. Frontend Setup

```bash
cd frontend
npm install
npm run dev
```
App will be running at `http://localhost:5173`.

### 3. ML Pipeline (Optional)

Generate synthetic training data and train models locally:

```bash
# Generate mock data
python -m ml.training.generate_synthetic_data

# Train models (cpu or cuda)
python -m ml.training.train_nlp
python -m ml.training.train_timeseries
```

---

## 🧪 Testing

```bash
# Backend Tests
cd backend && pytest

# ML Evaluation
python -m ml.training.evaluate
```

---

## ☁️ Deployment (AWS)

The project uses **Terraform** to deploy a serverless architecture on AWS.

```bash
cd infra
terraform init
terraform plan
terraform apply
```

Resources created:
- **Compute**: Lambda Function (Python) for inference
- **API**: API Gateway HTTP API v2
- **Storage**: DynamoDB (Users, Inputs, Assessments), S3 (Models, Logs)
- **Monitoring**: CloudWatch Alarms & Dashboard

---

## 🛡️ Privacy & Security

- **Data Sovereignty**: All resources configured for `eu-west-2` (London).
- **Encryption**: KMS encryption for S3 buckets and DynamoDB tables.
- **Validation**: Strict input sanitization against XSS/Injection.
- **Consent**: Granular consent gating for data storage and ML usage.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Note: Hea is a prototype wellness tool and does not provide medical diagnosis or treatment. Always consult a qualified healthcare professional for medical concerns.*
