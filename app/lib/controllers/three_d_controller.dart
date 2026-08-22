import 'dart:async';
import 'package:get/get.dart';

class ThreeDViewController extends GetxController {
  // 3D rotation angles in radians
  final RxDouble angleX = 0.3.obs;
  final RxDouble angleY = 0.4.obs;
  final RxDouble angleZ = 0.0.obs;

  // Auto animation toggle
  final RxBool isAutoSpinning = true.obs;
  final RxDouble pulseScale = 1.0.obs;
  final RxBool isHovered = false.obs;

  Timer? _spinTimer;
  Timer? _pulseTimer;

  @override
  void onInit() {
    super.onInit();
    _startAutoSpin();
    _startPulseEffect();
  }

  void updateDragRotation(double deltaX, double deltaY) {
    angleY.value += deltaX * 0.01;
    angleX.value -= deltaY * 0.01;
  }

  void toggleAutoSpin() {
    isAutoSpinning.value = !isAutoSpinning.value;
  }

  void resetRotation() {
    angleX.value = 0.3;
    angleY.value = 0.4;
    angleZ.value = 0.0;
  }

  void _startAutoSpin() {
    _spinTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (isAutoSpinning.value && !isHovered.value) {
        angleY.value += 0.012;
        angleX.value = 0.2 * (angleY.value % (3.14159 * 2));
      }
    });
  }

  void _startPulseEffect() {
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      pulseScale.value = pulseScale.value == 1.0 ? 1.08 : 1.0;
    });
  }

  @override
  void onClose() {
    _spinTimer?.cancel();
    _pulseTimer?.cancel();
    super.onClose();
  }
}
