🐔 Smart Poultry Farming AI System
An end-to-end AI-powered IoT system for real-time poultry health monitoring using Machine Learning, sensor data processing, and FastAPI deployment.

🚀 Problem Statement

Poultry farms face significant losses due to late detection of diseases and environmental anomalies such as temperature, humidity, and CO₂ imbalance.

Manual monitoring is inefficient and reactive rather than preventive.

💡 Solution

This project builds a real-time intelligent monitoring system that:

Collects IoT sensor data from poultry farms
Processes environmental and biological signals
Applies Machine Learning models for prediction
Detects anomalies early
Provides real-time status updates via API and mobile app
🧠 System Architecture
IoT Sensors → Data Collection → Preprocessing → ML Model → FastAPI Backend → Flutter App Dashboard
⚙️ Tech Stack
Python 🐍
Machine Learning (Scikit-learn / TensorFlow)
FastAPI (Backend API)
IoT Data Processing
Pandas / NumPy
Flutter (Mobile App Interface)
📊 Features
📡 Real-time IoT data ingestion
🧠 Machine learning-based prediction (Normal / Abnormal)
🌡️ Environmental monitoring (Temperature, Humidity, CO₂)
⚠️ Early anomaly detection system
🔗 REST API for integration with applications
📱 Mobile dashboard (Flutter integration)
🧬 How It Works
Sensors collect environmental data from poultry farm
Data is cleaned and preprocessed
ML model analyzes patterns and predicts farm status
FastAPI serves predictions in real-time
Flutter app displays results to the user
The system predicts:

🟢 Normal condition
🔴 Abnormal condition (risk detected)

With probability scores for better decision-making.

🔐 Important Note

This repository excludes:

Trained models (.pkl, .h5, .tflite)
Real farm datasets
Sensitive IoT credentials

Models can be retrained using the provided scripts.

🧠 What I Learned
Building full AI systems is more than training models
Data pipelines are critical in real-world AI
Deployment (FastAPI) is essential for usable AI
IoT + ML integration creates real impact
👩‍💻 Author

Aya Chouai
AI Engineer | Machine Learning | IoT Systems | Computer Vision

Focused on building real-world AI systems from data collection to deployment.

🚀 Future Improvements
Deep learning-based disease detection
Real-time streaming with WebSockets
Improved model accuracy with more data
