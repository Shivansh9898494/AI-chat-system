enum MessageSender { user, ai, system }

class ChatMessageModel {
  final String id;
  final String content;
  final MessageSender sender;
  final DateTime timestamp;
  final String modelName;
  final bool isCode;
  final int tokenCount;
  final double responseTimeSeconds;
  final bool is3DVisualized;

  ChatMessageModel({
    required this.id,
    required this.content,
    required this.sender,
    required this.timestamp,
    this.modelName = 'Ollama Llama 3',
    this.isCode = false,
    this.tokenCount = 128,
    this.responseTimeSeconds = 0.45,
    this.is3DVisualized = false,
  });

  ChatMessageModel copyWith({
    String? id,
    String? content,
    MessageSender? sender,
    DateTime? timestamp,
    String? modelName,
    bool? isCode,
    int? tokenCount,
    double? responseTimeSeconds,
    bool? is3DVisualized,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      modelName: modelName ?? this.modelName,
      isCode: isCode ?? this.isCode,
      tokenCount: tokenCount ?? this.tokenCount,
      responseTimeSeconds: responseTimeSeconds ?? this.responseTimeSeconds,
      is3DVisualized: is3DVisualized ?? this.is3DVisualized,
    );
  }
}
