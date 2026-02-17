import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:kittycash/Profile_Screen/KycIdentityVerificationScreen.dart';

class AadhaarCardScanScreen extends StatefulWidget {
  const AadhaarCardScanScreen({super.key});

  @override
  State<AadhaarCardScanScreen> createState() => _AadhaarCardScanScreenState();
}

class _AadhaarCardScanScreenState extends State<AadhaarCardScanScreen> {
  CameraController? _controller;
  bool _isReady = false;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      if (mounted) setState(() => _isReady = true);
    } catch (e) {
      debugPrint("Camera error: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scanWidth = size.width * 0.9;
    final scanHeight = 200.0;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E2E2E),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          "Aadhaar Card Verification",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: !_isReady
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CameraPreview(_controller!),

                /// BLUR OUTSIDE
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: ClipPath(
                      clipper: _HoleClipper(
                        holeWidth: scanWidth,
                        holeHeight: scanHeight,
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(color: Colors.black.withOpacity(0.45)),
                      ),
                    ),
                  ),
                ),

                /// BORDER
                Center(
                  child: Container(
                    width: scanWidth,
                    height: scanHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white, width: 2),
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
                          final picture = await _controller!.takePicture();

                          /// IMPORTANT FIX
                          await _controller?.pausePreview();

                          if (!mounted) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => KycIdentityVerificationScreen(
                                imagePath: picture.path,
                              ),
                            ),
                          );
                        } catch (e) {
                          debugPrint("Capture error: $e");
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
/// BLUR HOLE CLIPPER
/// =======================
class _HoleClipper extends CustomClipper<Path> {
  final double holeWidth;
  final double holeHeight;

  _HoleClipper({required this.holeWidth, required this.holeHeight});

  @override
  Path getClip(Size size) {
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final holeRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: holeWidth,
      height: holeHeight,
    );

    path.addRRect(RRect.fromRectAndRadius(holeRect, const Radius.circular(12)));

    path.fillType = PathFillType.evenOdd;
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
