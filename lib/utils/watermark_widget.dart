import 'package:flutter/material.dart';

/// Semi-transparent email watermark overlay — shown on exam screens
/// to deter screenshot sharing.
class WatermarkWidget extends StatelessWidget {
  final String email;
  final Widget child;

  const WatermarkWidget({
    super.key,
    required this.email,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: _WatermarkPainterWidget(email: email),
          ),
        ),
      ],
    );
  }
}

class _WatermarkPainterWidget extends StatelessWidget {
  final String email;

  const _WatermarkPainterWidget({required this.email});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _WatermarkPainter(email: email),
    );
  }
}

class _WatermarkPainter extends CustomPainter {
  final String email;

  _WatermarkPainter({required this.email});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: email,
        style: TextStyle(
          color: Colors.white.withOpacity(0.05),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Tile the watermark diagonally
    canvas.save();
    canvas.rotate(-0.4); // ~23 degrees

    const spacing = 160.0;
    for (double y = -size.height; y < size.height * 2; y += spacing) {
      for (double x = -size.width; x < size.width * 2; x += 300) {
        textPainter.paint(canvas, Offset(x, y));
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_WatermarkPainter old) => old.email != email;
}
