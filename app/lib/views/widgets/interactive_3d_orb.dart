import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../../controllers/three_d_controller.dart';
import '../../theme/app_theme.dart';

class Interactive3DOrb extends StatelessWidget {
  final double size;
  const Interactive3DOrb({super.key, this.size = 260.0});

  @override
  Widget build(BuildContext context) {
    final ThreeDViewController controller = Get.find<ThreeDViewController>();

    return GestureDetector(
      onPanUpdate: (details) {
        controller.updateDragRotation(details.delta.dx, details.delta.dy);
      },
      onTap: () {
        controller.toggleAutoSpin();
      },
      child: Obx(() {
        return Transform.scale(
          scale: controller.pulseScale.value,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Glow Sphere
                Container(
                  width: size * 0.75,
                  height: size * 0.75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryCyan.withOpacity(0.4),
                        blurRadius: 50,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: AppTheme.neonPurple.withOpacity(0.3),
                        blurRadius: 70,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),
                // Inner Core Light
                Container(
                  width: size * 0.3,
                  height: size * 0.3,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white,
                        AppTheme.primaryCyan,
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.4, 1.0],
                    ),
                  ),
                ),
                // 3D Polyhedron & Particle Mesh Renderer
                CustomPaint(
                  size: Size(size, size),
                  painter: _Orb3DPainter(
                    angleX: controller.angleX.value,
                    angleY: controller.angleY.value,
                    angleZ: controller.angleZ.value,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _Orb3DPainter extends CustomPainter {
  final double angleX;
  final double angleY;
  final double angleZ;

  _Orb3DPainter({
    required this.angleX,
    required this.angleY,
    required this.angleZ,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // Generate Icosahedron 3D Vertices
    final double phi = (1.0 + math.sqrt(5.0)) / 2.0;
    List<vector.Vector3> baseVertices = [
      vector.Vector3(-1, phi, 0),
      vector.Vector3(1, phi, 0),
      vector.Vector3(-1, -phi, 0),
      vector.Vector3(1, -phi, 0),
      vector.Vector3(0, -1, phi),
      vector.Vector3(0, 1, phi),
      vector.Vector3(0, -1, -phi),
      vector.Vector3(0, 1, -phi),
      vector.Vector3(phi, 0, -1),
      vector.Vector3(phi, 0, 1),
      vector.Vector3(-phi, 0, -1),
      vector.Vector3(-phi, 0, 1),
    ];

    // Normalize and scale to radius
    for (int i = 0; i < baseVertices.length; i++) {
      baseVertices[i] = baseVertices[i].normalized() * radius;
    }

    // 3D Rotation Matrix
    final matrix = Matrix4.identity()
      ..rotateX(angleX)
      ..rotateY(angleY)
      ..rotateZ(angleZ);

    List<Offset> projectedVertices = [];
    List<double> zCoords = [];

    for (var vertex in baseVertices) {
      final rotated = matrix.transform3(vector.Vector3.copy(vertex));
      // Perspective projection
      double perspective = 1.0 / (1.0 - (rotated.z / 600.0));
      projectedVertices.add(Offset(
        center.dx + rotated.x * perspective,
        center.dy + rotated.y * perspective,
      ));
      zCoords.add(rotated.z);
    }

    // Connections between vertices
    final List<List<int>> edges = [
      [0, 11], [0, 5], [0, 1], [0, 7], [0, 10],
      [1, 5], [5, 11], [11, 10], [10, 7], [7, 1],
      [3, 9], [3, 4], [3, 2], [3, 6], [3, 8],
      [4, 9], [9, 8], [8, 6], [6, 2], [2, 4],
      [5, 9], [11, 4], [10, 2], [7, 6], [1, 8],
    ];

    final paintLine = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var edge in edges) {
      int idx1 = edge[0];
      int idx2 = edge[1];

      double avgZ = (zCoords[idx1] + zCoords[idx2]) / 2;
      double opacity = ((avgZ + radius) / (2 * radius)).clamp(0.15, 0.95);

      paintLine.shader = LinearGradient(
        colors: [
          AppTheme.primaryCyan.withOpacity(opacity),
          AppTheme.neonPurple.withOpacity(opacity),
        ],
      ).createShader(Rect.fromPoints(projectedVertices[idx1], projectedVertices[idx2]));

      canvas.drawLine(projectedVertices[idx1], projectedVertices[idx2], paintLine);
    }

    // Draw Glowing Vertices
    final paintNode = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < projectedVertices.length; i++) {
      double zFactor = ((zCoords[i] + radius) / (2 * radius)).clamp(0.2, 1.0);
      paintNode.color = zFactor > 0.6 ? AppTheme.primaryCyan : AppTheme.neonPink;
      canvas.drawCircle(projectedVertices[i], 3.5 * zFactor, paintNode);
    }
  }

  @override
  bool shouldRepaint(covariant _Orb3DPainter oldDelegate) {
    return oldDelegate.angleX != angleX ||
        oldDelegate.angleY != angleY ||
        oldDelegate.angleZ != angleZ;
  }
}
