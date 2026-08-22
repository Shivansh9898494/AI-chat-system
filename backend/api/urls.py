from django.urls import path
from . import views

urlpatterns = [
    path('', views.home, name='home'),
    path('name/', views.name, name='name'),
    path('math/', views.math, name='math'),
    path('chat/', views.chat, name='chat'),
    path('chat/stream/', views.chat_stream, name='chat_stream'),
]
