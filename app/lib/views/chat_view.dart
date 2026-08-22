import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/chat_controller.dart';
import '../models/chat_message_model.dart';
import '../models/ai_model_info.dart';
import '../theme/app_theme.dart';
import 'widgets/glass_container.dart';
import 'widgets/interactive_3d_orb.dart';
import 'widgets/gemini_drawer.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();

    return Scaffold(
      drawer: const GeminiDrawer(),
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white70, size: 24),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Obx(() => GestureDetector(
              onTap: () => _showModelPicker(context, controller),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: controller.selectedModel.value.primaryColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 16,
                      color: controller.selectedModel.value.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      controller.selectedModel.value.name,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Colors.white54),
                  ],
                ),
              ),
            )),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: Colors.white70, size: 24),
            tooltip: 'New Chat',
            onPressed: controller.startNewChat,
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: AppTheme.neonPurple.withOpacity(0.8),
              child: const Text('S', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Main Chat Area
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return _buildGeminiGreetingStage(context, controller);
              }
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return _buildMessageBubble(context, message, controller, index == controller.messages.length - 1);
                },
              );
            }),
          ),

          // Floating Gemini Bottom Input Bar
          _buildGeminiInputBar(context, controller),
        ],
      ),
    );
  }

  /// Gemini Empty Stage Greeting
  Widget _buildGeminiGreetingStage(BuildContext context, ChatController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // Animated 3D Glowing Core Watermark Background
            SizedBox(
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.cyberCyan.withOpacity(0.2),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  const Interactive3DOrb(size: 160),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Gemini Title Greeting
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF4285F4), Color(0xFF9B51E0), Color(0xFFE91E63)],
              ).createShader(bounds),
              child: Text(
                'Hello, Shivansh',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'How can I help you today?',
              style: GoogleFonts.outfit(
                fontSize: 18,
                color: Colors.white54,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 36),

            // Suggestion Cards Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: controller.quickPrompts.map((prompt) {
                return GestureDetector(
                  onTap: () => controller.sendMessage(prompt),
                  child: GlassContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(14),
                    borderColor: Colors.white.withOpacity(0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          prompt,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            fontSize: 13,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: AppTheme.cyberCyan.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Chat Message Bubble with Stream Indicator
  Widget _buildMessageBubble(
      BuildContext context, ChatMessageModel message, ChatController controller, bool isLast) {
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(top: 4, right: 12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.cyberCyan.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF1E2235),
                child: Icon(Icons.auto_awesome_rounded, color: AppTheme.cyberCyan, size: 18),
              ),
            ),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Sender Header & Latency
                if (!isUser)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message.modelName,
                          style: GoogleFonts.outfit(
                            color: AppTheme.cyberCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (message.responseTimeSeconds > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${message.responseTimeSeconds.toStringAsFixed(2)}s',
                            style: GoogleFonts.outfit(color: Colors.white38, fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ),

                // Message Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppTheme.cyberCyan.withOpacity(0.18) : const Color(0xFF161A26),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    border: Border.all(
                      color: isUser ? AppTheme.cyberCyan.withOpacity(0.4) : Colors.white.withOpacity(0.06),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        message.content.isEmpty && controller.isThinking.value && isLast
                            ? 'Gemini is thinking...'
                            : message.content,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                      if (controller.isStreaming.value && isLast && !isUser) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.cyberCyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Streaming live response...',
                              style: GoogleFonts.outfit(color: AppTheme.cyberCyan, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // AI Action Bar (Copy, Thumbs up)
                if (!isUser && message.content.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white38),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: message.content));
                          Get.snackbar('Copied', 'Response copied to clipboard',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.black87,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 1));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.thumb_up_alt_outlined, size: 16, color: Colors.white38),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.share_outlined, size: 16, color: Colors.white38),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Floating Input Bar
  Widget _buildGeminiInputBar(BuildContext context, ChatController controller) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: GlassContainer(
        borderRadius: 28,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        borderColor: AppTheme.cyberCyan.withOpacity(0.3),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white54, size: 24),
              onPressed: () {},
            ),
            Expanded(
              child: TextField(
                controller: controller.textController,
                style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Ask Gemini...',
                  hintStyle: GoogleFonts.outfit(color: Colors.white38, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                ),
                onSubmitted: (_) => controller.sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.mic_none_rounded, color: Colors.white54, size: 22),
              onPressed: () {},
            ),
            Obx(() => Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF4285F4), Color(0xFF9B51E0)],
                    ),
                  ),
                  child: IconButton(
                    icon: controller.isStreaming.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: () => controller.sendMessage(),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  /// Modal Model Picker Sheet
  void _showModelPicker(BuildContext context, ChatController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF121522),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Model',
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Column(
                children: AIModelInfo.sampleModels.map((model) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: Icon(Icons.auto_awesome_rounded, color: model.primaryColor),
                    title: Text(model.name, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w600)),
                    subtitle: Text(model.description, style: GoogleFonts.outfit(color: Colors.white54, fontSize: 12)),
                    trailing: Text(model.iconBadge, style: GoogleFonts.outfit(color: model.primaryColor, fontSize: 12)),
                    onTap: () {
                      controller.selectModel(model);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
