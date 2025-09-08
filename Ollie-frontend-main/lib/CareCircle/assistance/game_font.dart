// xo_glow.dart
import 'package:flutter/material.dart';

class TicGlyph extends StatelessWidget {
  const TicGlyph({
    super.key,
    required this.mark, // "X", "O", or ""
    this.size = 64,
  });

  final String mark;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (mark.isEmpty) return const SizedBox.shrink();
    return CustomPaint(
      size: Size.square(size),
      painter: _XOGlowPainter(mark: mark),
    );
  }
}

class _XOGlowPainter extends CustomPainter {
  _XOGlowPainter({required this.mark});

  final String mark;

  // Colors tuned to look like your screenshot
  static const _redCore = Color(0xFFFF6B6B);
  static const _redGlow = Color(0x66FF6B6B);
  static const _cyanCore = Color(0xFF6BE7FF);
  static const _cyanGlow = Color(0x666BE7FF);

  @override
  void paint(Canvas canvas, Size size) {
    final isX = mark.toUpperCase() == 'X';
    final coreColor = isX ? _redCore : _cyanCore;
    final glowColor = isX ? _redGlow : _cyanGlow;

    // Common geometry
    final w = size.width;
    final h = size.height;
    final pad = size.shortestSide * 0.12;
    final rect = Rect.fromLTWH(pad, pad, w - 2 * pad, h - 2 * pad);

    // Two-layer stroke: outer glow + inner core
    final glow = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.22
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);

    final core = Paint()
      ..color = coreColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.shortestSide * 0.12;

    if (isX) {
      // Draw "\"
      canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.right, rect.bottom), glow);
      canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.right, rect.bottom), core);
      // Draw "/"
      canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.left, rect.bottom), glow);
      canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.left, rect.bottom), core);
    } else {
      // O: circle stroke with glow
      final center = rect.center;
      final r = rect.width / 2;
      canvas.drawCircle(center, r, glow);
      canvas.drawCircle(center, r, core);
    }
  }

  @override
  bool shouldRepaint(covariant _XOGlowPainter oldDelegate) => oldDelegate.mark != mark;
}
