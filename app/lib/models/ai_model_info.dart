import 'package:flutter/material.dart';

class AIModelInfo {
  final String id;
  final String name;
  final String provider;
  final String version;
  final String description;
  final Color primaryColor;
  final List<Color> gradientColors;
  final double speedRating;
  final double intelligenceRating;
  final String category;
  final bool isLocal;
  final String iconBadge;

  const AIModelInfo({
    required this.id,
    required this.name,
    required this.provider,
    required this.version,
    required this.description,
    required this.primaryColor,
    required this.gradientColors,
    required this.speedRating,
    required this.intelligenceRating,
    required this.category,
    this.isLocal = true,
    required this.iconBadge,
  });

  static const List<AIModelInfo> sampleModels = [
    AIModelInfo(
      id: 'llama3_8b',
      name: 'Llama 3 8B Local',
      provider: 'Meta / Ollama',
      version: 'v3.0.1',
      description: 'Ultra-fast local open-weights neural network running on Ollama local engine.',
      primaryColor: Color(0xFF00F2FE),
      gradientColors: [Color(0xFF00F2FE), Color(0xFF4FACFE)],
      speedRating: 0.98,
      intelligenceRating: 0.92,
      category: 'General Reasoning',
      isLocal: true,
      iconBadge: '⚡ LOCAL',
    ),
    AIModelInfo(
      id: 'neural_mesh_3d',
      name: 'NeuralMesh 3D',
      provider: 'Spatial AI Lab',
      version: 'v2.5 Pro',
      description: 'Advanced multi-modal model optimized for spatial 3D generation & code analysis.',
      primaryColor: Color(0xFF9D4EDD),
      gradientColors: [Color(0xFF9D4EDD), Color(0xFFFF2A85)],
      speedRating: 0.91,
      intelligenceRating: 0.96,
      category: '3D Spatial & Code',
      isLocal: true,
      iconBadge: '🧊 3D CORE',
    ),
    AIModelInfo(
      id: 'gpt4o_mini',
      name: 'GPT-4o Omniverse',
      provider: 'OpenAI',
      version: 'Omni 2026',
      description: 'High intelligence cloud model with fast multimodal comprehension & speed.',
      primaryColor: Color(0xFFFFB703),
      gradientColors: [Color(0xFFFFB703), Color(0xFFFB8500)],
      speedRating: 0.95,
      intelligenceRating: 0.99,
      category: 'Multimodal',
      isLocal: false,
      iconBadge: '☁️ CLOUD',
    ),
    AIModelInfo(
      id: 'claude_35_sonnet',
      name: 'Claude 3.5 Sonnet',
      provider: 'Anthropic',
      version: 'v3.5',
      description: 'Industry leading logic, coding, nuanced writing, and architectural design.',
      primaryColor: Color(0xFFFF2A85),
      gradientColors: [Color(0xFFFF2A85), Color(0xFF9D4EDD)],
      speedRating: 0.89,
      intelligenceRating: 0.98,
      category: 'Architecture & Logic',
      isLocal: false,
      iconBadge: '🧠 LOGIC',
    ),
  ];
}
