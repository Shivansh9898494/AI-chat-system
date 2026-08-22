# AI Chat Application (Flutter + Django + Ollama)

A full-stack cross-platform AI Chat application featuring a modern 3D UI built with Flutter and powered by a Django REST API backend integrated with local LLMs (Ollama / Llama 3).

## Features

- **Flutter Frontend (`/app`)**:
  - Modern futuristic glassmorphism UI with smooth animations and responsive drawer layout.
  - Multi-session chat support with real-time message streaming aesthetics.
  - Custom theme switcher, clean status indicators, and model selection.
  - HTTP connection service linking directly to the local Django backend.

- **Django Backend (`/backend`)**:
  - RESTful API endpoints for managing chat sessions and message processing.
  - Direct integration with local Ollama service (`llama3-local`).
  - CORS header configuration for cross-origin local development with Flutter.

## Project Structure

```
AI-chat/
├── app/                  # Flutter application source code
│   ├── lib/              # Main Dart code (controllers, models, services, views, theme)
│   └── pubspec.yaml      # Dependencies and configuration
└── backend/              # Django backend service
    ├── api/              # Django app containing views and API logic
    ├── backend/          # Project settings and URL configurations
    └── manage.py         # Django management script
```

## Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Python 3.10+](https://www.python.org/)
- [Ollama](https://ollama.ai/) with `llama3` model pulled (`ollama pull llama3`)

### 1. Running the Django Backend
```bash
cd backend
python -m venv venv
# On Windows PowerShell:
venv\Scripts\Activate.ps1
pip install django django-cors-headers requests
python manage.py migrate
python manage.py runserver 8000
```

### 2. Running the Flutter App
```bash
cd app
flutter pub get
flutter run
```

---
*Created by [Shivansh9898494](https://github.com/Shivansh9898494)*


