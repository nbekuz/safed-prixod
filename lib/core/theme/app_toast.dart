import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safed_prixod/core/api/api_error.dart';
import 'package:safed_prixod/core/theme/app_theme.dart';

enum AppToastType { success, error, warning, info }

class AppToastData {
  const AppToastData({required this.message, required this.type});
  final String message;
  final AppToastType type;
}

final appToastProvider =
    StateNotifierProvider<AppToastNotifier, AppToastData?>((ref) {
  return AppToastNotifier();
});

class AppToastNotifier extends StateNotifier<AppToastData?> {
  AppToastNotifier() : super(null);

  void show(String message, AppToastType type) =>
      state = AppToastData(message: message, type: type);

  void success(String message) => show(message, AppToastType.success);
  void error(String message) => show(message, AppToastType.error);
  void warning(String message) => show(message, AppToastType.warning);
  void info(String message) => show(message, AppToastType.info);
  void clear() => state = null;
}

void showApiError(WidgetRef ref, Object? error) {
  ref.read(appToastProvider.notifier).error(messageFromObject(error));
}

void showApiSuccess(WidgetRef ref, String message) {
  ref.read(appToastProvider.notifier).success(message);
}

class AppToastOverlay extends ConsumerStatefulWidget {
  const AppToastOverlay({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends ConsumerState<AppToastOverlay> {
  AppToastData? _model;
  bool _visible = false;
  Timer? _hideTimer;

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _present(AppToastData data) {
    _hideTimer?.cancel();
    setState(() {
      _model = data;
      _visible = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    _hideTimer = Timer(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      setState(() => _visible = false);
    });
  }

  Color _bg(AppToastType type) {
    switch (type) {
      case AppToastType.success:
        return AppTheme.primaryGreen;
      case AppToastType.error:
        return AppTheme.priceRed;
      case AppToastType.warning:
        return const Color(0xFFF59E0B);
      case AppToastType.info:
        return AppTheme.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppToastData?>(appToastProvider, (_, next) {
      if (next != null) _present(next);
    });

    return Stack(
      children: [
        widget.child,
        if (_model != null)
          Positioned(
            top: MediaQuery.paddingOf(context).top + 12,
            left: 16,
            right: 16,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                child: Material(
                  color: _bg(_model!.type),
                  borderRadius: BorderRadius.circular(14),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Text(
                      _model!.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
