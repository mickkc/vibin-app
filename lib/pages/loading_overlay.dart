import 'package:flutter/material.dart';

class LoadingOverlay {

  OverlayEntry? _overlayEntry;
  double? _progress;

  void show(BuildContext context, {String? message}) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        child: Stack(
          children: [
            ModalBarrier(
              dismissible: false,
              color: Colors.black.withAlpha(100),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(value: _progress),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(message),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _progress = null;
  }

  void setProgress(double? progress) {
    _progress = progress;
    _overlayEntry?.markNeedsBuild();
  }
}
