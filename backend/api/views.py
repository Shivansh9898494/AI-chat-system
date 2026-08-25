import json
import time
import requests
import subprocess
import logging
from django.http import StreamingHttpResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

logger = logging.getLogger(__name__)

# Ollama service configuration
OLLAMA_BASE_URL = "http://localhost:11434"
DEFAULT_MODEL = "llama3-local:latest"

# Single Data Object to learn easily
user_data = {"name": "Shivansh", "role": "Developer"}

def is_ollama_alive(timeout=2):
    """Check if Ollama server is active and responding."""
    try:
        res = requests.get(f"{OLLAMA_BASE_URL}/api/tags", timeout=timeout)
        return res.status_code == 200
    except Exception:
        return False

def ensure_ollama_running():
    """Ensure Ollama server is running. Auto-starts Ollama if it is stopped."""
    if is_ollama_alive():
        return True
    
    logger.info("Ollama is not running. Attempting auto-start...")
    try:
        # Start Ollama service in background
        subprocess.Popen(
            "ollama serve",
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            shell=True
        )
    except Exception as e:
        logger.error(f"Failed to run 'ollama serve': {e}")
        try:
            subprocess.Popen(
                "ollama list",
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                shell=True
            )
        except Exception as e2:
            logger.error(f"Secondary start attempt failed: {e2}")

    # Wait up to 6 seconds for Ollama server to spin up
    for _ in range(6):
        time.sleep(1)
        if is_ollama_alive(timeout=1):
            return True

    return False

def get_best_available_model(requested_model=None):
    """Determine the best available model on the Ollama instance."""
    try:
        res = requests.get(f"{OLLAMA_BASE_URL}/api/tags", timeout=3)
        if res.status_code == 200:
            models_info = res.json().get("models", [])
            installed_models = [m.get("name") for m in models_info if m.get("name")]
            
            if requested_model and requested_model in installed_models:
                return requested_model
            
            # Match model prefix if exact match not found
            if requested_model:
                req_prefix = requested_model.split(':')[0]
                for model in installed_models:
                    if model.startswith(req_prefix):
                        return model

            if DEFAULT_MODEL in installed_models:
                return DEFAULT_MODEL
            
            if installed_models:
                return installed_models[0]
    except Exception as e:
        logger.warning(f"Error fetching installed Ollama models: {e}")

    return requested_model or DEFAULT_MODEL


@api_view(['GET'])
def home(request):
    return Response({
        'name': 'Shivansh Kushwah',
        'age': 20,
        'course': 'Btech',
        'branch': 'CST',
        'year': '2023'
    })

@api_view(['GET'])
def name(request):
    n = request.GET.get('name', 'Annu')
    return Response({
        'name': 'Your Name is ' + n,
        'status': True
    })

@api_view(['GET'])
def math(request):
    op = request.GET.get('op', '+')
    n1 = int(request.GET.get('n1', 0))
    n2 = int(request.GET.get('n2', 0))

    match op:
        case '+':
            return Response({
                'num1': n1,
                'num2': n2,
                'ans': n1 + n2,
                'op': '+',
                'status': True
            })
        case '-':
            return Response({
                'num1': n1,
                'num2': n2,
                'ans': n1 - n2,
                'op': '-',
                'status': True
            })
        case _:
            return Response({
                'num1': n1,
                'num2': n2,
                'ans': 0,
                'op': '',
                'status': False,
            })

@api_view(['POST'])
def chat(request):
    """
    Standard JSON Chatbot API endpoint with auto-start and best response formatting.
    """
    user_prompt = request.data.get('message', '')
    messages = request.data.get('messages', None)
    requested_model = request.data.get('model', None)
    
    if not user_prompt and not messages:
        return Response(
            {"status": False, "error": "Please provide a 'message' string or 'messages' list in the request body."},
            status=status.HTTP_400_BAD_REQUEST
        )

    if messages is None:
        messages = [{"role": "user", "content": user_prompt}]

    system_message = {
        "role": "system",
        "content": (
            "You are an intelligent, highly skilled, friendly, and accurate AI assistant created by Shivansh. "
            "Provide helpful, well-structured, clear, and high-quality responses. "
            "Format your answers with clean Markdown and code formatting where applicable."
        )
    }
    
    if not any(isinstance(msg, dict) and msg.get("role") == "system" for msg in messages):
        messages.insert(0, system_message)

    # 1. Auto start Ollama if not running
    ollama_ready = ensure_ollama_running()
    if not ollama_ready:
        return Response({
            "status": False,
            "error": "Ollama service is not running and could not be started automatically. Please check if Ollama is installed on your system.",
            "reply": "Ollama service unavailable. Please check system installation."
        }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

    # 2. Select best active model
    active_model = get_best_available_model(requested_model)

    ollama_url = f"{OLLAMA_BASE_URL}/api/chat"
    payload = {
        "model": active_model,
        "messages": messages,
        "stream": False
    }

    try:
        response = requests.post(ollama_url, json=payload, timeout=60)
        if response.status_code == 200:
            data = response.json()
            reply = data.get("message", {}).get("content", "")
            return Response({
                "status": True,
                "reply": reply,
                "model": active_model
            })
        else:
            return Response({
                "status": False,
                "error": f"Ollama model error: {response.text}",
                "model": active_model
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    except requests.exceptions.RequestException as e:
        return Response({
            "status": False,
            "error": "Failed to communicate with Ollama backend.",
            "details": str(e)
        }, status=status.HTTP_503_SERVICE_UNAVAILABLE)

@api_view(['POST'])
def chat_stream(request):
    """
    Real-time Token Streaming API Endpoint.
    Returns HTTP chunked response token-by-token.
    """
    user_prompt = request.data.get('message', '')
    messages = request.data.get('messages', None)
    requested_model = request.data.get('model', None)
    
    if messages is None:
        messages = [{"role": "user", "content": user_prompt}]
    
    system_message = {
        "role": "system",
        "content": (
            "You are an intelligent, highly skilled, friendly, and accurate AI assistant created by Shivansh. "
            "Provide helpful, well-structured, clear, and high-quality responses."
        )
    }
    if not any(isinstance(msg, dict) and msg.get("role") == "system" for msg in messages):
        messages.insert(0, system_message)

    # Auto start Ollama if not running
    ollama_ready = ensure_ollama_running()
    active_model = get_best_available_model(requested_model) if ollama_ready else DEFAULT_MODEL

    ollama_url = f"{OLLAMA_BASE_URL}/api/chat"
    payload = {
        "model": active_model,
        "messages": messages,
        "stream": True
    }

    def generate_stream():
        if not ollama_ready:
            fallback = f"Ollama service is currently not running. Please make sure Ollama is installed on your machine and start it."
            for word in fallback.split(' '):
                yield word + " "
                time.sleep(0.04)
            return

        try:
            res = requests.post(ollama_url, json=payload, stream=True, timeout=60)
            if res.status_code == 200:
                for line in res.iter_lines():
                    if line:
                        chunk_json = json.loads(line.decode('utf-8'))
                        content = chunk_json.get('message', {}).get('content', '')
                        if content:
                            yield content
            else:
                yield f"\n[Ollama Error: {res.text}]"
        except Exception as e:
            fallback = f"Connection error while talking to AI model: {str(e)}"
            for word in fallback.split(' '):
                yield word + " "
                time.sleep(0.04)

    return StreamingHttpResponse(generate_stream(), content_type='text/plain; charset=utf-8')

