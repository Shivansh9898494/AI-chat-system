import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/chat_controller.dart';
import '../../theme/app_theme.dart';
import '../../models/ai_model_info.dart';

class GeminiDrawer extends StatelessWidget {
  const GeminiDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final chatController = Get.find<ChatController>();

    return Drawer(
      backgroundColor: const Color(0xFF0D0F17),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header - New Chat Button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  chatController.startNewChat();
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.cyberCyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppTheme.cyberCyan.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.add_rounded, color: AppTheme.cyberCyan, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        'New chat',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // Recent Chats Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'Recent',
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: chatController.chatHistorySessions.length,
                itemBuilder: (context, index) {
                  final session = chatController.chatHistorySessions[index];
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    leading: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: Colors.white70),
                    title: Text(
                      session['title']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // Model Switcher Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Models',
                    style: GoogleFonts.outfit(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Column(
                        children: AIModelInfo.sampleModels.map((model) {
                          final isSelected = chatController.selectedModel.value.id == model.id;
                          return GestureDetector(
                            onTap: () {
                              chatController.selectModel(model);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? model.primaryColor.withOpacity(0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? model.primaryColor : Colors.white.withOpacity(0.05),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.auto_awesome_rounded, size: 16, color: model.primaryColor),
                                  const SizedBox(width: 8),
                                  Text(
                                    model.name,
                                    style: GoogleFonts.outfit(
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isSelected)
                                    Icon(Icons.check_circle_rounded, size: 16, color: model.primaryColor),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      )),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // User Profile Footer
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.neonPurple,
                    child: Text('S', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shivansh Kushwah',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Pro Member ✦',
                          style: GoogleFonts.outfit(
                            color: AppTheme.cyberCyan,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white54, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
