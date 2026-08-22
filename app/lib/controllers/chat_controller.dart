import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/chat_message_model.dart';
import '../models/ai_model_info.dart';
import '../services/api_service.dart';

class ChatController extends GetxController {
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final RxList<ChatMessageModel> messages = <ChatMessageModel>[].obs;
  final Rx<AIModelInfo> selectedModel = AIModelInfo.sampleModels[0].obs;
  final RxBool isThinking = false.obs;
  final RxBool isStreaming = false.obs;

  final List<String> quickPrompts = [
    "⚡ Optimize Django REST API Performance",
    "🚀 Explain Quantum Neural Networks",
    "🎨 Generate Futuristic 3D Flutter Code",
    "🤖 What is the architecture of Llama 3?",
  ];

  final List<Map<String, String>> chatHistorySessions = [
    {"id": "1", "title": "Quantum Computing Intro"},
    {"id": "2", "title": "Flutter 3D Matrix Setup"},
    {"id": "3", "title": "Django API Streaming"},
  ];

  @override
  void onInit() {
    super.onInit();
  }

  void selectModel(AIModelInfo model) {
    selectedModel.value = model;
    Get.snackbar(
      'Model Selected',
      'Switched to ${model.name}',
      snackPosition: SnackPosition.TOP,
      backgroundColor: model.primaryColor.withOpacity(0.2),
      colorText: Colors.white,
      borderColor: model.primaryColor,
      borderWidth: 1,
      duration: const Duration(seconds: 2),
    );
  }

  /// Send message with Live Real-time Token Streaming
  Future<void> sendMessage([String? customText]) async {
    final text = customText ?? textController.text.trim();
    if (text.isEmpty || isStreaming.value) return;

    textController.clear();

    // 1. Add User Message
    final userMsg = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      modelName: selectedModel.value.name,
    );

    messages.add(userMsg);
    _scrollToBottom();

    // 2. Add AI Message Placeholder for Live Streaming
    final aiMsg = ChatMessageModel(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      content: '',
      sender: MessageSender.ai,
      timestamp: DateTime.now(),
      modelName: selectedModel.value.name,
      is3DVisualized: true,
    );

    messages.add(aiMsg);
    final aiIndex = messages.length - 1;

    isThinking.value = true;
    isStreaming.value = true;

    final startTime = DateTime.now();

    try {
      // 3. Listen to live token stream
      final stream = ApiService.streamChatMessage(message: text);
      await for (final chunk in stream) {
        if (isThinking.value) {
          isThinking.value = false;
        }

        final current = messages[aiIndex];
        final updatedContent = current.content + chunk;
        
        messages[aiIndex] = ChatMessageModel(
          id: current.id,
          content: updatedContent,
          sender: current.sender,
          timestamp: current.timestamp,
          modelName: current.modelName,
          isCode: updatedContent.contains('```') || text.toLowerCase().contains('code'),
          tokenCount: (updatedContent.length * 0.75).toInt(),
          responseTimeSeconds: DateTime.now().difference(startTime).inMilliseconds / 1000.0,
          is3DVisualized: true,
        );

        messages.refresh();
        _scrollToBottom();
      }
    } catch (e) {
      final current = messages[aiIndex];
      messages[aiIndex] = ChatMessageModel(
        id: current.id,
        content: 'Error receiving stream response: $e',
        sender: current.sender,
        timestamp: current.timestamp,
        modelName: current.modelName,
      );
    } finally {
      isThinking.value = false;
      isStreaming.value = false;
      messages.refresh();
      _scrollToBottom();
    }
  }

  void startNewChat() {
    messages.clear();
  }

  void clearChat() {
    messages.clear();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
