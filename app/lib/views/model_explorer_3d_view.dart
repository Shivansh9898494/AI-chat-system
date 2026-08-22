import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import '../controllers/navigation_controller.dart';
import '../models/ai_model_info.dart';
import '../theme/app_theme.dart';
import 'widgets/glass_container.dart';
import 'widgets/tilt_3d_card.dart';

class ModelExplorer3DView extends StatefulWidget {
  const ModelExplorer3DView({super.key});

  @override
  State<ModelExplorer3DView> createState() => _ModelExplorer3DViewState();
}

class _ModelExplorer3DViewState extends State<ModelExplorer3DView> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatController chatCtrl = Get.find<ChatController>();
    final NavigationController navCtrl = Get.find<NavigationController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Model Explorer', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI ENGINE ARCHITECTURE',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryCyan, letterSpacing: 1.5),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Select & Activate Neural Models',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 3D Perspective Cylindrical PageView Carousel
              SizedBox(
                height: 380,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: AIModelInfo.sampleModels.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final model = AIModelInfo.sampleModels[index];
                    final delta = index - _currentPage;
                    final rotationY = delta * 0.45; // 3D Y-axis perspective rotation angle
                    final scale = (1 - (delta.abs() * 0.15)).clamp(0.8, 1.0);

                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0015) // Perspective Depth Projection
                        ..rotateY(rotationY.clamp(-0.8, 0.8)),
                      alignment: delta > 0 ? Alignment.centerLeft : Alignment.centerRight,
                      child: Transform.scale(
                        scale: scale,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Tilt3DCard(
                            maxTilt: 0.15,
                            onTap: () {
                              chatCtrl.selectModel(model);
                              navCtrl.changePage(1); // Go to Chat
                            },
                            child: GlassContainer(
                              borderRadius: 28,
                              padding: const EdgeInsets.all(22),
                              color: model.primaryColor.withOpacity(0.1),
                              borderColor: model.primaryColor.withOpacity(0.5),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: model.primaryColor.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: model.primaryColor),
                                        ),
                                        child: Text(
                                          model.iconBadge,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: model.primaryColor,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        model.version,
                                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 20),

                                  // Glowing Center Icon
                                  Center(
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(colors: model.gradientColors),
                                        boxShadow: [
                                          BoxShadow(
                                            color: model.primaryColor.withOpacity(0.5),
                                            blurRadius: 25,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.memory, size: 40, color: Colors.white),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Text(
                                    model.name,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Provided by ${model.provider}',
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                  ),

                                  const SizedBox(height: 12),

                                  Text(
                                    model.description,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.3),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const Spacer(),

                                  // Ratings
                                  _buildRatingBar('Speed', model.speedRating, model.primaryColor),
                                  const SizedBox(height: 6),
                                  _buildRatingBar('Logic & Reasoning', model.intelligenceRating, AppTheme.neonPurple),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 24),

              // Activate Button for Current Centered Model
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      final selected = AIModelInfo.sampleModels[_currentPage.round()];
                      chatCtrl.selectModel(selected);
                      navCtrl.changePage(1);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 10,
                      shadowColor: AppTheme.primaryCyan.withOpacity(0.5),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'ACTIVATE SELECTED 3D ENGINE',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingBar(String label, double rating, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
            Text('${(rating * 100).toInt()}%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: rating,
            minHeight: 5,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
