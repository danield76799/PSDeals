import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A "flitsend" (glossy / shimmering) animated logo for the home header.
///
/// Combines a soft pulsing glow behind the mark with a diagonal shimmer
/// sweep across it, giving a premium PlayStation-style sheen.
class ShimmerLogo extends StatefulWidget {
  final double size;

  const ShimmerLogo({super.key, this.size = 72});

  @override
  State<ShimmerLogo> createState() => _ShimmerLogoState();
}

class _ShimmerLogoState extends State<ShimmerLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing glow
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final glow = 0.35 + 0.25 * _controller.value;
              return Container(
                width: widget.size * 1.15,
                height: widget.size * 1.15,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withValues(alpha: glow),
                      blurRadius: widget.size * 0.6,
                      spreadRadius: widget.size * 0.08,
                    ),
                  ],
                ),
              );
            },
          ),
          // Glossy rounded-square mark
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.size * 0.22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.accentLight, AppTheme.accent],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.white, Colors.white70, Colors.white],
                  stops: [0.0, 0.5, 1.0],
                ).createShader(bounds),
                child: const Text(
                  'PS',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
          // Diagonal shimmer sweep
          ClipRRect(
            borderRadius: BorderRadius.circular(widget.size * 0.22),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _ShimmerPainter(_controller.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  _ShimmerPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const sweepWidth = 0.35;
    final x = (-sweepWidth + progress * (1 + sweepWidth * 2)) * size.width;
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: const [
        Colors.white24,
        Colors.white70,
        Colors.white24,
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(
      Rect.fromLTWH(x - size.width * sweepWidth, 0, size.width * sweepWidth * 2, size.height),
    );
    canvas.save();
    canvas.clipRect(rect);
    canvas.drawRect(
      Rect.fromLTWH(x - size.width * sweepWidth, 0, size.width * sweepWidth * 2, size.height),
      Paint()..shader = gradient,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter old) => old.progress != progress;
}
