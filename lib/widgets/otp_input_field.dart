import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// SMS kod: 1 raqam → keyingi maydon; 5 ta to‘lganda [onCompleted].
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    super.key,
    this.length = 5,
    this.initialCode,
    this.onCompleted,
    this.onChanged,
  });

  final int length;
  final String? initialCode;
  final void Function(String code)? onCompleted;
  final void Function(String code)? onChanged;

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _initControllers();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyInitial());
  }

  @override
  void didUpdateWidget(covariant OtpInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.length != widget.length) {
      _disposeControllers();
      _initControllers();
      _applyInitial();
    } else if (oldWidget.initialCode != widget.initialCode) {
      _applyInitial();
    }
  }

  void _initControllers() {
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _controllers = List.generate(widget.length, (_) => TextEditingController());
  }

  void _disposeControllers() {
    for (final n in _focusNodes) {
      n.dispose();
    }
    for (final c in _controllers) {
      c.dispose();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _applyInitial() {
    final raw = widget.initialCode;
    if (raw == null || raw.isEmpty) return;
    final digits = raw
        .replaceAll(RegExp(r'\D'), '')
        .split('')
        .take(widget.length)
        .toList();
    for (var i = 0; i < widget.length; i++) {
      _controllers[i].text = i < digits.length ? digits[i] : '';
    }
    widget.onChanged?.call(_getCode());
    if (digits.length >= widget.length) {
      widget.onCompleted?.call(_getCode());
    } else if (digits.isNotEmpty) {
      _focusNodes[digits.length.clamp(0, widget.length - 1)].requestFocus();
    }
  }

  String _getCode() => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value
          .replaceAll(RegExp(r'\D'), '')
          .split('')
          .take(widget.length)
          .toList();
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
        _controllers[i].selection = TextSelection.collapsed(
          offset: _controllers[i].text.length,
        );
      }
      _focusNodes[widget.length - 1].requestFocus();
      widget.onChanged?.call(_getCode());
      if (digits.length >= widget.length) widget.onCompleted?.call(_getCode());
      return;
    }
    if (value.isNotEmpty) {
      _controllers[index].text = value[value.length - 1];
      _controllers[index].selection = const TextSelection.collapsed(offset: 1);
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        widget.onCompleted?.call(_getCode());
      }
    }
    widget.onChanged?.call(_getCode());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.length, (i) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: SizedBox(
              width: 48,
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (v) => _onChanged(i, v),
              ),
            ),
          );
        }),
      ),
    );
  }
}
