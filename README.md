# ⚖️ Lawgorythm - AI-Powered Legal Tech Assistant

**Lawgorythm** is a comprehensive full-stack AI solution designed to bridge the gap between complex legal jargon and common citizens. It leverages cutting-edge Large Language Models (LLMs) to analyze FIRs, predict case outcomes, and manage legal workflows seamlessly.

---

## 🚀 Key Features

* **🔍 AI FIR Analyzer:** Upload or paste FIR text to instantly identify relevant **BNS (Bharatiya Nyaya Sanhita)** sections and legal implications.
* **🤖 Legal Chatbot:** A specialized AI assistant to answer complex legal queries based on the Indian Judicial System.
* **📅 Case Timeline:** Automatically generate a visual and chronological timeline of legal events from unstructured documents.
* **⚖️ Argument Builder:** A tool to help legal professionals and students structure their legal arguments with relevant evidence references.
* **🔮 Judgment Predictor:** Analyzes historical case patterns to provide data-driven insights into potential legal outcomes.

---

## 🛠️ Tech Stack

### **Frontend**
* **Framework:** Flutter (Cross-platform support for Android, iOS, and Web)
* **State Management:** Provider
* **Database & Auth:** Firebase Firestore & Firebase Authentication

### **Backend**
* **Framework:** FastAPI (Python)
* **AI Model:** Google Gemini Pro API
* **Document Processing:** PyMuPDF & LangChain

---

## ⚙️ Setup & Installation

### Backend Setup
Navigate to the `argumate_backend` directory.

Install dependencies:
```bash

pip install -r requirements.txt
```
Configure your `.env` file with your `GEMINI_API_KEY`.

Start the server:
```bash
uvicorn main:app --reload
```
### Frontend Setup
Navigate to the `argumate_frontend` directory.

Fetch dependencies:
```bash
flutter pub get
```
Run the application:
```bash
flutter run
```
---

## 👨‍💻 Developer
Made with ❤️ by Shubham Sharma