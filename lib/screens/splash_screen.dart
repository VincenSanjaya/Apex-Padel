import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'main_layout_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // The Drop
  late Animation<double> _dropAnimation;

  // The Impact & Shockwave
  late Animation<double> _shockwaveScaleAnimation;
  late Animation<double> _shockwaveOpacityAnimation;

  // The Reveal
  late Animation<double> _ballTranslateXAnimation;
  late Animation<double> _ballScaleAnimation;
  late Animation<double> _textOpacityAnimation;
  late Animation<double> _textScaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // The Drop (0.0s - 0.8s) -> Interval(0.0, 0.32)
    _dropAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: -800.0,
              end: 0.0,
            ).chain(CurveTween(curve: Curves.bounceOut)),
            weight: 100,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.32),
          ),
        );

    // The Impact & Shockwave (0.8s - 1.2s) -> Interval(0.32, 0.48)
    _shockwaveScaleAnimation = Tween<double>(begin: 1.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.48, curve: Curves.easeOut),
      ),
    );

    _shockwaveOpacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.32, 0.48, curve: Curves.easeOut),
      ),
    );

    // The Reveal (1.2s - 2.0s) -> Interval(0.48, 0.80)
    _ballTranslateXAnimation = Tween<double>(begin: 0.0, end: -140.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.80, curve: Curves.easeInOutCubic),
      ),
    );

    _ballScaleAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.80, curve: Curves.easeInOutCubic),
      ),
    );

    _textOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.80, curve: Curves.easeInOutCubic),
      ),
    );

    _textScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.48, 0.80, curve: Curves.easeInOutCubic),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // The Transition (2.5s)
        _navigateToDashboard();
      }
    });

    // Start the animation immediately
    _controller.forward();
  }

  void _navigateToDashboard() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainLayoutScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // The Impact & Shockwave
                if (_controller.value >= 0.32 && _controller.value <= 0.48)
                  CustomPaint(
                    painter: ShockwavePainter(
                      scale: _shockwaveScaleAnimation.value,
                      opacity: _shockwaveOpacityAnimation.value,
                    ),
                  ),

                // The Reveal Text
                Transform.translate(
                  offset: const Offset(
                    40,
                    0,
                  ), // Shift right to balance the layout
                  child: Opacity(
                    opacity: _textOpacityAnimation.value,
                    child: Transform.scale(
                      scale: _textScaleAnimation.value,
                      child: Text(
                        'APEX PADEL',
                        style: GoogleFonts.oswald(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),

                // The Drop / The Reveal Ball
                Transform.translate(
                  offset: Offset(
                    _ballTranslateXAnimation.value,
                    _dropAnimation.value,
                  ),
                  child: Transform.scale(
                    scale: _ballScaleAnimation.value,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFD4FF00),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFD4FF00,
                            ).withValues(alpha: 0.6),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ShockwavePainter extends CustomPainter {
  final double scale;
  final double opacity;

  ShockwavePainter({required this.scale, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.0) return;

    final paint = Paint()
      ..color = const Color(0xFFD4FF00).withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);

    // Initial radius matches the ball's radius (30)
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      30 * scale,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ShockwavePainter oldDelegate) {
    return oldDelegate.scale != scale || oldDelegate.opacity != opacity;
  }
}
