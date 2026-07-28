import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safed_prixod/core/core.dart';
import 'package:safed_prixod/core/camera_permission.dart';
import 'package:safed_prixod/core/locale_provider.dart';
import 'package:safed_prixod/l10n/app_strings.dart';
import 'package:safed_prixod/features/orders/order_barcode_helpers.dart';

class BarcodeScanPage extends ConsumerStatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  ConsumerState<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends ConsumerState<BarcodeScanPage> {
  final _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
  );
  bool _handled = false;
  bool _checkingPermission = true;
  PermissionStatus? _cameraStatus;

  @override
  void initState() {
    super.initState();
    _loadCameraPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadCameraPermission() async {
    setState(() => _checkingPermission = true);
    final status = await Permission.camera.status;
    if (mounted) {
      setState(() {
        _cameraStatus = status;
        _checkingPermission = false;
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    setState(() => _checkingPermission = true);
    final status = await requestCameraPermission();
    if (mounted) {
      setState(() {
        _cameraStatus = status;
        _checkingPermission = false;
      });
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    final code = normalizeBarcode(raw);
    if (code.isEmpty) return;

    _handled = true;
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);

    return SafedScaffold(
      appBar: AppBar(
        title: Text(l10n.scanButton),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            label: Text(l10n.exitScanner),
          ),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppStrings l10n) {
    if (_checkingPermission) {
      return const Center(child: CircularProgressIndicator());
    }

    final status = _cameraStatus;
    if (status == null || !status.isGranted) {
      final permanentlyDenied = status?.isPermanentlyDenied ?? false;
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 56,
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 20),
            Text(
              permanentlyDenied
                  ? l10n.cameraPermissionDenied
                  : l10n.cameraPermissionRequired,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            if (permanentlyDenied)
              FilledButton(
                onPressed: openAppSettings,
                child: Text(l10n.openAppSettings),
              )
            else
              FilledButton(
                onPressed: _requestCameraPermission,
                child: Text(l10n.tryAgain),
              ),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(controller: _controller, onDetect: _onDetect),
        IgnorePointer(
          child: CustomPaint(
            painter: _ScanOverlayPainter(),
            child: const SizedBox.expand(),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Text(
                l10n.scanPageHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  shadows: const [
                    Shadow(blurRadius: 10, color: Colors.black54),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const frameWidth = 280.0;
    const frameHeight = 140.0;
    final left = (size.width - frameWidth) / 2;
    final top = (size.height - frameHeight) / 2 - 40;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, frameWidth, frameHeight),
      const Radius.circular(12),
    );

    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.45);
    final full = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Path()..addRRect(rect);
    canvas.drawPath(
      Path.combine(PathOperation.difference, full, hole),
      overlayPaint,
    );

    final borderPaint = Paint()
      ..color = AppTheme.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
