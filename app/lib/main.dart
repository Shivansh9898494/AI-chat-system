import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'controllers/chat_controller.dart';
import 'controllers/navigation_controller.dart';
import 'controllers/three_d_controller.dart';
import 'theme/app_theme.dart';
import 'views/main_layout_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Transparent Status Bar setup
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const NeuralAI3DApp());
}

class AppInitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(NavigationController());
    Get.put(ChatController());
    Get.put(ThreeDViewController());
  }
}

class NeuralAI3DApp extends StatelessWidget {
  const NeuralAI3DApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Neural AI 3D Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialBinding: AppInitialBindings(),
      home: const MainLayoutView(),
    );
  }
}
