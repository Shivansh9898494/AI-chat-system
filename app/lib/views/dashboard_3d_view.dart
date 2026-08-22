import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/three_d_controller.dart';
import '../theme/app_theme.dart';
import 'widgets/glass_container.dart';
import 'widgets/interactive_3d_orb.dart';
import 'widgets/tilt_3d_card.dart';

class Dashboard3DView extends StatelessWidget {
  const Dashboard3DView({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navCtrl = Get.find<NavigationController>();
    final ChatController chatCtrl = Get.find<ChatController>();
    final ThreeDViewController threeDCtrl = Get.put(ThreeDViewController());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NEURAL CORE 3D',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            'Welcome, Shivansh',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryCyan.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primaryCyan.withOpacity(0.5)),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryCyan,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GlassContainer(
                    padding: const EdgeInsets.all(10),
                    borderRadius: 16,
                    child: const Icon(Icons.blur_on, color: AppTheme.primaryCyan, size: 26),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

              const SizedBox(height: 24),

              // Interactive 3D Orb Hero Stage
              GlassContainer(
                width: double.infinity,
                borderRadius: 28,
                padding: const EdgeInsets.all(20),
                borderColor: AppTheme.primaryCyan.withOpacity(0.3),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.successGreen,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.successGreen,
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Obx(() => Text(
                              'ACTIVE MODEL: ${chatCtrl.selectedModel.value.name.toUpperCase()}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                                letterSpacing: 1.0,
                              ),
                            )),
                          ],
                        ),
                        Obx(() => IconButton(
                          icon: Icon(
                            threeDCtrl.isAutoSpinning.value
                                ? Icons.pause_circle_outline
                                : Icons.play_circle_outline,
                            color: AppTheme.primaryCyan,
                          ),
                          onPressed: () => threeDCtrl.toggleAutoSpin(),
                          tooltip: 'Toggle 3D Rotation',
                        )),
                      ],
                    ),
                    const SizedBox(height: 10),
                    
                    // Central 3D Visualizer Orb
                    const Interactive3DOrb(size: 240),
                    
                    const SizedBox(height: 12),
                    const Text(
                      '👈 Drag to Rotate 3D Polyhedron • Tap to Toggle Auto-Spin 👉',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms).scale(begin: const Offset(0.95, 0.95)),

              const SizedBox(height: 24),

              // Quick Action 3D Perspective Cards Grid
              const Text(
                'AI WORKSPACES & TOOLS',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.2,
                children: [
                  Tilt3DCard(
                    onTap: () => navCtrl.changePage(1),
                    child: GlassContainer(
                      color: AppTheme.primaryCyan.withOpacity(0.08),
                      borderColor: AppTheme.primaryCyan.withOpacity(0.4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.primaryGradient,
                            ),
                            child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 24),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'AI Chat Studio',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Local Ollama & Cloud',
                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Tilt3DCard(
                    onTap: () => navCtrl.changePage(2),
                    child: GlassContainer(
                      color: AppTheme.neonPurple.withOpacity(0.08),
                      borderColor: AppTheme.neonPurple.withOpacity(0.4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [AppTheme.neonPurple, AppTheme.neonPink],
                              ),
                            ),
                            child: const Icon(Icons.view_in_ar_outlined, color: Colors.white, size: 24),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '3D Model Hub',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Explore Mesh Engines',
                            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms, duration: 500.ms),

              const SizedBox(height: 24),

              // System Telemetry Panel
              GlassContainer(
                width: double.infinity,
                borderRadius: 20,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'REAL-TIME SYSTEM METRICS',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _metricTile('GPU Render FPS', '60.0 FPS', Icons.speed, AppTheme.successGreen),
                        _metricTile('Tensor VRAM', '3.8 / 8 GB', Icons.memory, AppTheme.primaryCyan),
                        _metricTile('Latency', '18 ms', Icons.bolt, AppTheme.accentGold),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

              const SizedBox(height: 80), // Padding for floating nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _metricTile(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
      ],
    );
  }
}
