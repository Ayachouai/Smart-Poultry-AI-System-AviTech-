# 🐔 AviTech: Smart Poultry Farming AI & IoT System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Framework](https://img.shields.io/badge/Framework-FastAPI-009688.svg)](https://fastapi.tiangolo.com/)
[![Deep Learning](https://img.shields.io/badge/AI%2FML-TensorFlow%20%7C%20MobileNetV2-FF6F00.svg)](https://www.tensorflow.org/)
[![Mobile](https://img.shields.io/badge/Mobile-Flutter%20%7C%20Dart-02569B.svg)](https://flutter.dev/)

An end-to-end AI-powered IoT system designed for real-time poultry health monitoring and early anomaly detection. By combining Computer Vision, environmental sensor data processing, and an asynchronous cloud architecture, this system transitions poultry farm management from reactive to preventive.

---

## 🚀 Problem Statement
Poultry farms face devastating financial losses due to the late detection of infectious diseases and undetected environmental anomalies (such as temperature, humidity, and $CO_2$ imbalances). Manual monitoring is labor-intensive, inefficient, and often catches outbreaks only after irreversible damage has occurred.

## 💡 The Solution
AviTech builds a real-time intelligent monitoring ecosystem that:
* **Ingests Multi-Modal Data:** Collects live IoT sensor telemetry alongside biological signals (visual data) directly from poultry pens.
* **Applies Optimized AI:** Employs an edge-optimized MobileNetV2 image classifier and machine learning pipelines to detect health anomalies early.
* **Delivers Instant Insights:** Serves predictions via a high-performance, async FastAPI backend and syncs states across a cross-platform Flutter mobile dashboard.

---

## 📊 Key Performance & Impact Metrics
* **97.6% Test Accuracy:** Achieved on the core image classification model for poultry disease detection within a 6-month solo build cycle.
* **-30% Latency Reduction:** Optimized via transfer learning and fine-tuning for lightweight on-device and edge deployment.
* **⚡ Sub-200ms Server Latency:** FastAPI REST API seamlessly handles concurrent multi-device image uploads, preprocessing, and structured JSON inference responses.

---

## 🧠 System Architecture & Data Flow   
[ IoT Sensors / Poultry Images ]
│
▼
[ Flutter Mobile App ] ──(Offline Inference Available)
│
├─► (Async REST API Requests / Uploads) ──► [ FastAPI Backend ]
│                                                 │
│                                                 ▼
│                                      [ MobileNetV2 Model ]
│                                                 │
▼                                                 ▼
[ Firebase Realtime DB ] ◄─────────────────────── [ AWS / GCP Infrastructure ]
 1. **Data Acquisition:** On-field cameras capture poultry visual data, while hardware sensors track ambient environmental conditions ($CO_2$, Temperature, Humidity).
2. **Data Pipeline & Preprocessing:** Raw signals and frames are cleaned, structured, and validated dynamically.
3. **Inference Pipeline:** Data is processed either locally on-device for offline field use or routed through a highly optimized async FastAPI server.
4. **Real-time State Sync:** Live status reports and probability scores are transmitted instantaneously across multi-device clients via Firebase.

---

## 🛠️ Tech Stack

| Category | Technologies & Tools |
| :--- | :--- |
| **🧠 Machine Learning & CV** | Python, TensorFlow, MobileNetV2, Scikit-learn, OpenCV, Transfer Learning, Fine-tuning |
| **⚙️ Backend & APIs** | FastAPI, REST API Design, Async Processing, Uvicorn, Pydantic, Pandas, NumPy |
| **📱 Mobile Client** | Dart, Flutter (Cross-Platform Interface, On-Device Diagnostics, IoT Visualization) |
| **☁️ Cloud & DevOps** | AWS (S3, Cloud Foundations), Google Cloud Platform (GCP), Firebase Hosting & Realtime DB, Docker, Git |

---

## ⚡ Features
* **📡 Real-Time IoT Ingestion:** Continuous monitoring of critical farm variables (Temperature, Humidity, $CO_2$).
* **🧠 Deep Learning & ML Predictions:** Identifies and classifies farm statuses with granular probability scores:
  * 🟢 **Normal Condition:** Stable environment and healthy flock.
  * 🔴 **Abnormal Condition:** Disease risk detected or environmental anomaly triggered.
* **⏱️ Async Request Processing:** Non-blocking architectures prevent backend bottlenecks during concurrent bulk image uploads.
* **📱 Cross-Platform Mobile Dashboard:** Real-time analytics, instant notifications, and built-in offline inference capability.

---

## 📂 Repository Structure

```text
├── ai-engine/             # TensorFlow training scripts, notebooks, and serialized models
├── backend-api/           # FastAPI codebase, async inference routing, and validation layers
├── mobile-app/            # Flutter mobile client code for Android and iOS
├── hardware-iot/          # Arduino/ESP32 sensor configuration firmware
└── README.md              # Project documentation
🚀 Getting Started
1. Prerequisites
Python 3.10+

Flutter SDK (Latest Stable)

Docker (Optional, for production API containment)

2. Backend & Model Server Setup
Bash
cd backend-api
python -m venv venv
source venv/bin/activate  # On Windows use `venv\Scripts\activate`
pip install -r requirements.txt
uvicorn main:app --reload
Note: Once the server is running, interactive API documentation is automatically generated and accessible at http://127.0.0.1:8000/docs.

3. Mobile Client Setup
Bash
cd mobile-app
flutter pub get
flutter run
🔐 Deployment & Sensitive Data Note
To adhere to secure production standards, this public repository excludes:

Trained weights and serialized model artifacts (.pkl, .h5, .tflite).

Proprietary clinical/farm datasets.

Sensitive cloud infrastructure and IoT credentials.

You can fully retrain or fine-tune your own architectures using the provided compilation and training configurations located in the /ai-engine directory.

🧠 Key Engineering Takeaways
Beyond the Notebook: Building operational AI systems taught me that model training is just 10% of the lifecycle; end-to-end alignment requires production-grade code.

Data Pipelines are King: Real-world AI relies entirely on deterministic, robust preprocessing blocks to clean noisy IoT signals before inference.

The Power of IoT + ML: True operational impact happens when low-latency edge models meet immediate, actionable hardware telemetry.

🚀 Future Roadmap
[ ] Deep Learning Disease Localization: Transition from global image classification to bounding-box disease symptom localization.

[ ] WebSocket Integration: Implement full-duplex WebSocket connections for sub-millisecond streaming telemetry.

[ ] Continual Learning Pipelines: Automate performance regression checks to trigger cloud retraining cycles on newly annotated edge anomalies.

📜 License
Distributed under the MIT License. See LICENSE for more details.

👩‍💻 Author
Chouai Aya Douniazed - AI/ML & Computer Vision Engineer

Email: aya.chouai@univ-constantine2.dz

LinkedIn: linkedin.com/in/chouai-aya-796202285

GitHub: @Ayachouai
