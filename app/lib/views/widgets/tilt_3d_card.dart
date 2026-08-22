import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class Tilt3DCard extends StatefulWidget {
  final Widget child;
  final double maxTilt;
  final double borderRadius;
  final VoidCallback? onTap;

  const Tilt3DCard({
    super.key,
    required this.child,
    this.maxTilt = 0.25,
    this.borderRadius = 24.0,
    this.onTap,
  });

  @override
  State<Tilt3DCard> createState() => _Tilt3DCardState();
}

class _Tilt3DCardState extends State<Tilt3DCard> {
  double _rotX = 0.0;
  double _rotY = 0.0;
  bool _isHovered = false;

  void _onPointerMove(PointerMoveEvent event, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final localPos = event.localPosition;

    setState(() {
      _rotX = ((localPos.dy - center.dy) / center.dy) * widget.maxTilt;
      _rotY = -((localPos.dx - center.dx) / center.dx) * widget.maxTilt;
    });
  }

  void _resetTilt() {
    setState(() {
      _rotX = 0.0;
      _rotY = 0.0;
      _isHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return Listener(
          onPointerMove: (event) => _onPointerMove(event, size),
          onPointerDown: (_) => setState(() => _isHovered = true),
          onPointerUp: (_) => _resetTilt(),
          onPointerCancel: (_) => _resetTilt(),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // 3D Perspective Projection
                ..rotateX(_rotX)
                ..rotateY(_rotY),
              alignment: FractionalOffset.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryCyan.withOpacity(0.35),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, 10),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
