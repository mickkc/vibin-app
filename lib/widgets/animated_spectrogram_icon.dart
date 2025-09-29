import 'package:flutter/material.dart';

class AnimatedSpectogramIcon extends StatefulWidget {
  final Color color;
  final double size;
  final int barCount;
  final bool isPlaying;

  const AnimatedSpectogramIcon({
    super.key,
    required this.color,
    this.size = 24.0,
    this.barCount = 3,
    this.isPlaying = true,
  });

  @override
  State<AnimatedSpectogramIcon> createState() => _AnimatedSpectogramIconState();
}

class _AnimatedSpectogramIconState extends State<AnimatedSpectogramIcon> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(widget.barCount, (index) {
      return AnimationController(
        duration: Duration(milliseconds: 300 + index * 100),
        vsync: this,
      );
    });

    _animations = List.generate(widget.barCount, (index) {
      return Tween<double>(begin: 0.2, end: 1.0).animate(
        CurvedAnimation(
          parent: _controllers[index],
          curve: Curves.easeInOut,
        ),
      );
    });

    if (widget.isPlaying) {
      for (final c in _controllers) {
        c.repeat(reverse: true);
      }
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedSpectogramIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        for (final c in _controllers) {
          c.repeat(reverse: true);
        }
      } else {
        for (final c in _controllers) {
          c.stop();
          c.value = 0.2;
        }
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge(_controllers),
        builder: (context, _) {
          return CustomPaint(
            painter: _SpectrogramPainter(
              widget.color,
              _animations.map((a) => a.value).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _SpectrogramPainter extends CustomPainter {
  final Color color;
  final List<double> heights;

  _SpectrogramPainter(this.color, this.heights);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final barWidth = size.width / (heights.length * 2 - 1);

    for (int i = 0; i < heights.length; i++) {
      final heightFactor = heights[i];
      final barHeight = size.height * heightFactor;
      final x = i * barWidth * 2;
      final y = (size.height - barHeight) / 2;
      canvas.drawRect(Rect.fromLTWH(x, y, barWidth, barHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpectrogramPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.heights != heights;
  }
}
