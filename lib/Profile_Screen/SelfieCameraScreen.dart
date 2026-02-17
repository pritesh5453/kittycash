import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:kittycash/Profile_Screen/kyc_progress_screen.dart';

class SelfieIdentityScanScreen extends StatefulWidget {
  final CameraDescription camera;

  const SelfieIdentityScanScreen({super.key, required this.camera});

  @override
  State<SelfieIdentityScanScreen> createState() =>
      _SelfieIdentityScanScreenState();
}

class _SelfieIdentityScanScreenState extends State<SelfieIdentityScanScreen> {
  late CameraController _controller;
  bool _ready = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _controller.initialize().then((_) {
      if (mounted) {
        setState(() => _ready = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final radius = size.width * 0.35;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E2E2E),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          "Identity Verification",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: !_ready
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                /// CAMERA PREVIEW
                CameraPreview(_controller),

                /// BLUR OUTSIDE CIRCLE
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: ClipPath(
                      clipper: _CircleHoleClipper(radius),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(color: Colors.black.withOpacity(0.45)),
                      ),
                    ),
                  ),
                ),

                /// FACE BORDER
                Center(
                  child: Container(
                    width: radius * 2,
                    height: radius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),

                /// CAPTURE BUTTON
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: InkResponse(
                      radius: 45,
                      onTap: () async {
                        if (_isCapturing) return;
                        _isCapturing = true;

                        try {
                          final image = await _controller.takePicture();

                          debugPrint("Selfie captured: ${image.path}");

                          await _controller.pausePreview();

                          if (!mounted) return;

                          /// 👉 GO TO KYC PROGRESS SCREEN
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KycProgressScreen(),
                            ),
                            (route) => false,
                          );
                        } catch (e) {
                          debugPrint("Selfie capture error: $e");
                        } finally {
                          _isCapturing = false;
                        }
                      },
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: const Center(
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// =======================
/// CIRCLE HOLE CLIPPER
/// =======================
class _CircleHoleClipper extends CustomClipper<Path> {
  final double radius;

  _CircleHoleClipper(this.radius);

  @override
  Path getClip(Size size) {
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    path.addOval(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: radius,
      ),
    );

    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
