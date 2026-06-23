import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SegmentedRatingGauge extends StatelessWidget {
  final double rating;

  const SegmentedRatingGauge({super.key, required this.rating});

  String _getLevelName(double r) {
    if (r < 3.0) return 'BEGINNER';
    if (r < 5.0) return 'INTERMEDIATE';
    if (r < 7.0) return 'ADVANCED';
    if (r < 8.5) return 'MASTER LEVEL';
    return 'TOP LEVEL';
  }

  @override
  Widget build(BuildContext context) {
    final levelName = _getLevelName(rating);
    return SizedBox(
      width: 320,
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // The circular gauge
          SizedBox(
            width: 320,
            height: 320,
            child: CustomPaint(
              painter: _GaugePainter(
                rating: rating,
                maxRating: 10.0,
                activeColor: Theme.of(context).colorScheme.primary, // Yellow
                inactiveColor: const Color(0xFF2A2A2A),
                backgroundColor: const Color(0xFF121212),
              ),
            ),
          ),
          // Center Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                size: 64,
                color: Color(0xFFFFD700),
                shadows: [
                  Shadow(color: Color(0x80FFD700), blurRadius: 20),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                rating.toStringAsFixed(1),
                style: GoogleFonts.oswald(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  height: 1.0,
                  shadows: [
                    Shadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 15,
                    )
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                levelName,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  letterSpacing: 2.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double rating;
  final double maxRating;
  final Color activeColor;
  final Color inactiveColor;
  final Color backgroundColor;

  _GaugePainter({
    required this.rating,
    required this.maxRating,
    required this.activeColor,
    required this.inactiveColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Gauge ring radius
    final radius = min(size.width / 2, size.height / 2) - 30;
    
    // Draw background solid circle to represent the inner sphere
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius + 15, bgPaint);

    // Add some gradient inner shadow to make it look like a 3D ball
    final Rect bgRect = Rect.fromCircle(center: center, radius: radius + 15);
    final shadowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.8),
        ],
        stops: const [0.7, 1.0],
      ).createShader(bgRect);
    canvas.drawCircle(center, radius + 15, shadowPaint);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 28.0
      ..strokeCap = StrokeCap.butt;

    int totalSegments = 10; // Let's use 10 segments for 10 levels
    double gapAngle = 0.06; // Gap between segments
    double segmentAngle = (2 * pi - (totalSegments * gapAngle)) / totalSegments;

    // Start from top
    double startAngle = -pi / 2;
    
    for (int i = 0; i < totalSegments; i++) {
      double segmentValueStart = i * (maxRating / totalSegments);
      double segmentValueEnd = (i + 1) * (maxRating / totalSegments);
      
      if (rating >= segmentValueEnd) {
        // Fully active segment
        ringPaint.color = activeColor;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          segmentAngle,
          false,
          ringPaint,
        );
      } else if (rating > segmentValueStart) {
        // Partially active
        ringPaint.color = inactiveColor;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          segmentAngle,
          false,
          ringPaint,
        );
        double fraction = (rating - segmentValueStart) / (maxRating / totalSegments);
        ringPaint.color = activeColor;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          segmentAngle * fraction,
          false,
          ringPaint,
        );
      } else {
        // Inactive segment
        ringPaint.color = inactiveColor;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          segmentAngle,
          false,
          ringPaint,
        );
      }

      // Draw subtle ticks on the edges of segments
      final tickPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      // Outer tick
      double tickRadiusStart = radius + 14;
      double tickRadiusEnd = radius + 22;
      Offset tickStart = Offset(
        center.dx + tickRadiusStart * cos(startAngle),
        center.dy + tickRadiusStart * sin(startAngle),
      );
      Offset tickEnd = Offset(
        center.dx + tickRadiusEnd * cos(startAngle),
        center.dy + tickRadiusEnd * sin(startAngle),
      );
      canvas.drawLine(tickStart, tickEnd, tickPaint);

      // Inner tick
      double innerTickRadiusStart = radius - 22;
      double innerTickRadiusEnd = radius - 14;
      Offset innerTickStart = Offset(
        center.dx + innerTickRadiusStart * cos(startAngle),
        center.dy + innerTickRadiusStart * sin(startAngle),
      );
      Offset innerTickEnd = Offset(
        center.dx + innerTickRadiusEnd * cos(startAngle),
        center.dy + innerTickRadiusEnd * sin(startAngle),
      );
      canvas.drawLine(innerTickStart, innerTickEnd, tickPaint);

      startAngle += segmentAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.rating != rating;
  }
}
