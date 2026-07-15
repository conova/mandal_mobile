import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../theme/app_text_styles.dart';

class CameraOverlayScreen extends StatefulWidget {
  const CameraOverlayScreen({super.key});

  @override
  State<CameraOverlayScreen> createState() => _CameraOverlayScreenState();
}

class _CameraOverlayScreenState extends State<CameraOverlayScreen> {
  CameraController? _controller;
  bool _isCameraInitialized = false;
  String _type = 'id';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isCameraInitialized && _controller == null) {
      _type = ModalRoute.of(context)!.settings.arguments as String? ?? 'id';
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      try {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          final camera = _type == 'selfie'
              ? cameras.firstWhere(
                  (c) => c.lensDirection == CameraLensDirection.front,
                  orElse: () => cameras.first,
                )
              : cameras.firstWhere(
                  (c) => c.lensDirection == CameraLensDirection.back,
                  orElse: () => cameras.first,
                );

          _controller = CameraController(
            camera,
            ResolutionPreset.high,
            enableAudio: false,
          );

          await _controller!.initialize();

          if (mounted) {
            setState(() {
              _isCameraInitialized = true;
            });
          }
        }
      } catch (e) {
        debugPrint("Camera error: $e");
      }
    } else {
      if (mounted) {
        Navigator.pop(context); // Go back if denied
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    final String title = _type == 'selfie' ? l10n.selfiePhoto : l10n.idFront;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 70,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: extendedColors.neutral500,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: AppTextStyles.light,
            color: theme.colorScheme.onBackground,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Camera Preview Feed
                if (_isCameraInitialized && _controller != null)
                  FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _controller!.value.previewSize?.height ?? 1,
                      height: _controller!.value.previewSize?.width ?? 1,
                      child: CameraPreview(_controller!),
                    ),
                  )
                else
                  Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),

                // Dark Overlay with Cutout Mask
                ClipPath(
                  clipper: _MaskClipper(type: _type),
                  child: Container(color: Colors.black.withOpacity(0.55)),
                ),

                // Instruction Text & Border overlay
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _type == 'selfie'
                            ? l10n.cameraInstructionSelfie
                            : l10n.cameraInstructionId,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: AppTextStyles.light,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _type == 'selfie'
                          ? _buildSelfieBorder()
                          : _buildIdBorder(),
                    ],
                  ),
                ),

                // Bottom Controls
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 48), // Layout spacer
                      // iPhone SDK Style Capture Button
                      GestureDetector(
                        onTap: () async {
                          if (_controller != null &&
                              _controller!.value.isInitialized) {
                            try {
                              final image = await _controller!.takePicture();
                              // Web дээр path нь blob URL тул File-ээр уншиж
                              // болохгүй — bytes-ийг нь шууд base64 болгож
                              // буцаана (upload_document base64 хүлээдэг)
                              if (kIsWeb) {
                                final bytes = await image.readAsBytes();
                                if (mounted) {
                                  Navigator.pop(context, base64Encode(bytes));
                                }
                              } else if (mounted) {
                                Navigator.pop(context, image.path);
                              }
                            } catch (e) {
                              debugPrint(e.toString());
                              if (mounted) {
                                Navigator.pop(context, true);
                              }
                            }
                          } else {
                            Navigator.pop(
                              context,
                              true,
                            ); // Fallback for testing on simulator
                          }
                        },
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          padding: const EdgeInsets.all(3),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      // Refresh/Switch Camera Button
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.75),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.black87,
                            size: 24,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdBorder() {
    return Container(
      width: 320,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Widget _buildSelfieBorder() {
    return Container(
      width: 260,
      height: 380,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        borderRadius: BorderRadius.circular(130),
      ),
    );
  }
}

class _MaskClipper extends CustomClipper<Path> {
  final String type;

  _MaskClipper({required this.type});

  @override
  Path getClip(Size size) {
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Calculate the height shift created by the instruction text + spacing.
    // Text height is typically ~20px, spacing is 16px. Total = 36px.
    // The center of the hole should shift down by exactly half of this total space.
    final double yOffset = 18.0;

    final holeRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 + yOffset),
      width: type == 'selfie'
          ? 320
          : 320, // Keep width 320 for both if desired, else:
      height: type == 'selfie' ? 380 : 200,
    );

    // Explicit sizing for clipping
    final double finalWidth = type == 'selfie' ? 260 : 320;

    final realHoleRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 + yOffset),
      width: finalWidth,
      height: holeRect.height,
    );

    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          realHoleRect,
          Radius.circular(type == 'selfie' ? 130 : 16),
        ),
      );

    return Path.combine(PathOperation.difference, path, holePath);
  }

  @override
  bool shouldReclip(_MaskClipper oldClipper) => oldClipper.type != type;
}
