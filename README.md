# 📡 LTE/5G Wireless System Performance Evaluation for Urban Mobile Broadband

![MATLAB](https://img.shields.io/badge/MATLAB-Wireless%20Simulation-orange)
![Python](https://img.shields.io/badge/Python-Machine%20Learning-blue)
![LTE](https://img.shields.io/badge/LTE-4G-success)
![5G](https://img.shields.io/badge/5G-NR-purple)
![MIMO](https://img.shields.io/badge/MIMO-2x2-red)
![OFDM](https://img.shields.io/badge/OFDM-PAPR%20Analysis-green)

> 🚀 A comprehensive MATLAB and Python-based simulation framework for evaluating key LTE/5G physical layer technologies including Adaptive Modulation, QAM, MIMO, OFDM, PAPR Analysis, and Machine Learning-based Modulation Classification.

---

# 📖 Overview

Modern LTE and 5G communication systems rely on advanced physical-layer technologies to deliver high data rates, low latency, improved reliability, and efficient spectrum utilization.

This project presents a complete end-to-end simulation framework for evaluating LTE/5G wireless communication performance in urban mobile broadband environments using MATLAB and Python.

The project integrates:

- 📶 Adaptive Modulation & Channel Analysis
- 🔷 QAM Performance under Noise & Fading
- 📡 MIMO BER Performance Analysis
- 🌐 OFDM Transmission & PAPR Analysis
- 🤖 Machine Learning-Based Modulation Classification

---

# 🎯 Project Objectives

✅ Model urban wireless propagation using the COST-231 Hata model

✅ Perform link budget and coverage analysis

✅ Implement adaptive modulation based on SNR

✅ Evaluate QAM performance under AWGN and Rayleigh fading

✅ Compare SISO and MIMO communication systems

✅ Analyze OFDM transmission characteristics

✅ Investigate Peak-to-Average Power Ratio (PAPR)

✅ Apply Machine Learning for automatic modulation classification

---

# 🏗️ System Modules

## 📶 Adaptive Modulation & Channel Analysis

This module evaluates wireless channel quality and dynamically selects the most suitable modulation scheme.

### Features

- COST-231 Hata Path Loss Model
- Urban Coverage Analysis
- Link Budget Evaluation
- SNR Estimation
- Adaptive Modulation Selection

### Generated Results

- Path Loss vs Distance
- SNR vs Distance
- Coverage Regions
- Link Budget Analysis
- Modulation Selection Regions

---

## 🔷 QAM Performance Analysis

This module investigates the impact of noise and fading on digital modulation schemes.

### Features

- 16-QAM Implementation
- 64-QAM Implementation
- AWGN Channel Simulation
- Rayleigh Fading Channel
- Error Analysis

### Generated Results

- Ideal Constellation Diagrams
- Noisy Constellations
- Fading Effects
- BER Performance
- Error Magnitude Analysis

---

## 📡 MIMO BER Performance Analysis

This module evaluates spatial diversity and multiplexing gains in modern wireless systems.

### Features

- SISO Communication
- 2×2 MIMO System
- Rayleigh Fading Channel
- Zero Forcing (ZF) Receiver
- MMSE Receiver

### Generated Results

- BER vs SNR Curves
- SISO vs MIMO Comparison
- ZF vs MMSE Comparison
- Capacity Enhancement Analysis

---

## 🌐 OFDM Transmission & PAPR Analysis

This module implements an LTE/5G-inspired OFDM transmitter and evaluates PAPR behavior.

### Features

- OFDM Signal Generation
- IFFT-Based Transmission
- Cyclic Prefix Addition
- Power Spectrum Analysis
- PAPR Calculation
- CCDF Analysis

### Generated Results

- Time Domain OFDM Signal
- OFDM Power Spectrum
- CCDF of PAPR
- Peak Power Analysis

---

## 🤖 Machine Learning-Based Modulation Classification

This module predicts the optimal modulation scheme using channel information.

### Input Features

- SNR (dB)
- Distance (km)
- Noise Power (dBm)

### ML Algorithms

- 🌳 Random Forest
- 📈 Logistic Regression
- 🎯 Support Vector Machine (SVM)

### Generated Results

- Dataset Generation
- Model Accuracy Comparison
- Confusion Matrix
- Feature Importance Analysis
- Live Modulation Prediction

---

# 🛠️ Technologies Used

## MATLAB

- Adaptive Modulation
- COST-231 Hata Model
- QAM Modulation/Demodulation
- Rayleigh Fading Channels
- MIMO Systems
- OFDM Design
- BER Analysis
- PAPR Evaluation

## Python

- NumPy
- Pandas
- Matplotlib
- Scikit-Learn
- Random Forest
- Logistic Regression
- Support Vector Machine

---

# 📊 Performance Metrics

| Metric | Description |
|----------|-------------|
| 📶 SNR | Signal-to-Noise Ratio |
| 📉 BER | Bit Error Rate |
| 🎯 EVM | Error Vector Magnitude |
| 📡 Capacity | Shannon Channel Capacity |
| ⚡ PAPR | Peak-to-Average Power Ratio |
| 📈 Spectral Efficiency | Throughput per Hz |

---

# 🔄 System Workflow

```text
Urban Wireless Channel
        │
        ▼
Path Loss Modeling
        │
        ▼
Link Budget Analysis
        │
        ▼
SNR Estimation
        │
        ▼
Adaptive Modulation
(QPSK / 16-QAM / 64-QAM)
        │
        ▼
QAM Transmission
        │
        ▼
MIMO Processing
        │
        ▼
OFDM Transmission
        │
        ▼
PAPR Evaluation
        │
        ▼
Machine Learning Classification
```

---

# 🏆 Key Results

### 📶 Adaptive Modulation

- Dynamic switching between QPSK, 16-QAM, and 64-QAM
- Improved spectral efficiency
- Urban coverage estimation using SNR thresholds

### 🔷 QAM Analysis

- Visualized constellation distortion under noise and fading
- Evaluated BER performance under varying channel conditions

### 📡 MIMO Analysis

- MMSE receiver achieved better BER performance than Zero Forcing
- Significant performance gains over SISO communication

### 🌐 OFDM Analysis

- Generated LTE/5G-style OFDM waveforms
- Evaluated power spectrum characteristics
- Measured PAPR using CCDF analysis

### 🤖 Machine Learning

- Compared Random Forest, Logistic Regression, and SVM
- Random Forest achieved the highest classification accuracy
- Successfully predicted modulation schemes based on channel parameters


---

# 🎓 Academic Relevance

This project demonstrates practical implementation of concepts from:

- Wireless Mobile Communication
- Digital Communication Systems
- Information Theory
- Signal Processing
- Machine Learning
- LTE/5G Network Design
- Modern Wireless Systems

---

# 📚 References

- 3GPP LTE Release Standards
- 3GPP 5G NR Specifications
- COST-231 Hata Propagation Model
- Shannon Information Theory
- Wireless Communications by Andrea Goldsmith
- Digital Communications by John G. Proakis

---

# 👩‍💻 Author

**Shrenica Chawda A**

🎓 B.Tech Electronics and Communication Engineering  
🏫 Vellore Institute of Technology, Chennai
