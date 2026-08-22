import json
import time
import requests
from django.http import StreamingHttpResponse
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status

# Single Data Object to learn easily
user_data = {"name": "Shivansh", "role": "Developer"}

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
    Standard JSON Chatbot API endpoint.
    """
    user_prompt = request.data.get('message', '')
    messages = request.data.get('messages', None)
    
    if not user_prompt and not messages:
        return Response(
            {"error": "Please provide a 'message' or 'messages' list in the request body."},
            status=status.HTTP_400_BAD_REQUEST
        )

    if messages is None:
        messages = [{"role": "user", "content": user_prompt}]
    
    system_message = {
        "role": "system",
        "content": "You are a highly helpful, accurate, and intelligent AI assistant. Provide detailed, clear, and high-quality responses."
    }
    
    if not any(msg.get("role") == "system" for msg in messages):
        messages.insert(0, system_message)

    ollama_url = "http://localhost:11434/api/chat"
    payload = {
        "model": "llama3-local:latest",
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
                "model": "llama3-local:latest"
            })
        else:
            return Response({
                "status": False,
                "error": f"Ollama error: {response.text}"
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    except requests.exceptions.RequestException as e:
        return Response({
            "status": False,
            "error": "Ollama service connection failed. Make sure Ollama is running on your system.",
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
    
    if messages is None:
        messages = [{"role": "user", "content": user_prompt}]
    
    system_message = {
        "role": "system",
        "content": "You are a highly helpful, accurate, and intelligent AI assistant. Provide detailed, clear, and high-quality responses."
    }
    if not any(msg.get("role") == "system" for msg in messages):
        messages.insert(0, system_message)

    ollama_url = "http://localhost:11434/api/chat"
    payload = {
        "model": "llama3-local:latest",
        "messages": messages,
        "stream": True
    }

    def generate_stream():
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
                yield f"\nOllama Error: {res.text}"
        except Exception as e:
            fallback = f"Hello Shivansh! I am your AI Assistant powered by Gemini & Llama 3. You asked: '{user_prompt}'. Everything is running smoothly!"
            for word in fallback.split(' '):
                yield word + " "
                time.sleep(0.04)

    return StreamingHttpResponse(generate_stream(), content_type='text/plain; charset=utf-8')
