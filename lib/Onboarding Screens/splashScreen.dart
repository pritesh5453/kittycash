import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:kittycash/Onboarding%20Screens/Welcome1.dart';
import 'package:kittycash/Onboarding%20Screens/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _lineController;
  late AnimationController _logoController;
  late AnimationController _iconRotateController;

  bool showWhiteScreen = false;

  @override
  void initState() {
    super.initState();

    // 🔵 Background animation
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // ⚪ White screen logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // 🔄 Rotating PNG logo
    _iconRotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // 🔁 Switch to white screen
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() => showWhiteScreen = true);
      _logoController.forward();

      // 🚀 Navigate to HomeScreen after 2 seconds
      Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      });
    });
  }

  @override
  void dispose() {
    _lineController.dispose();
    _logoController.dispose();
    _iconRotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 700),
        child: showWhiteScreen ? _whiteScreen() : _blueScreen(),
      ),
    );
  }

  /// 🔵 BLUE SCREEN
  Widget _blueScreen() {
    return Stack(
      key: const ValueKey("blue"),
      children: [
        Container(color: const Color(0xFF2F6BFF)),

        AnimatedBuilder(
          animation: _lineController,
          builder: (_, __) {
            return CustomPaint(
              painter: ContourLinesPainter(_lineController.value),
              size: Size.infinite,
            );
          },
        ),

        Center(
          child: RotationTransition(
            turns: _iconRotateController,
            child: Image.asset(
              'assets/images/Coinmoney.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }

  /// ⚪ WHITE SCREEN
  Widget _whiteScreen() {
    return Container(
      key: const ValueKey("white"),
      color: Colors.white,
      child: Center(
        child: FadeTransition(
          opacity: _logoController,
          child: ScaleTransition(
            scale: Tween(begin: 0.9, end: 1.0).animate(_logoController),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/Coinmoney.png',
                  width: 28,
                  height: 28,
                  fit: BoxFit.contain,
                  color: const Color(0xFF2F6BFF),
                ),
                const SizedBox(width: 8),
                const Text(
                  "KittyCash",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F6BFF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 🎨 BACKGROUND CONTOUR LINES (UNCHANGED)
class ContourLinesPainter extends CustomPainter {
  final double progress;

  ContourLinesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-0.18);
    canvas.translate(-size.width / 2, -size.height / 2);

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.18)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double spacing = 26;
    const double amplitude = 60;
    const double frequency = 0.015;

    final double verticalOffset = progress * spacing * 2;
    int index = 0;

    for (double baseX = 0; baseX < size.width; baseX += spacing) {
      final path = Path();
      bool first = true;

      final double phase = (index.isEven) ? 0 : pi / 3;

      for (double y = -200; y <= size.height + 200; y += 6) {
        final double x = baseX + sin(y * frequency + phase) * amplitude;
        final double drawY = y + verticalOffset;

        if (first) {
          path.moveTo(x, drawY);
          first = false;
        } else {
          path.lineTo(x, drawY);
        }
      }

      canvas.drawPath(path, paint);
      index++;
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
