import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

class ErrorHandler {
  static Future<void> showErrorDialog(BuildContext context, String errorMessage, {Object? error, StackTrace? stackTrace, bool showDetails = false}) async {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        errorMessage: errorMessage,
        error: error,
        stackTrace: stackTrace,
        showDetails: showDetails,
      ),
    );
  }
}

class ErrorDialog extends StatefulWidget {
  final String errorMessage;
  final Object? error;
  final StackTrace? stackTrace;
  final bool showDetails;

  const ErrorDialog({
    super.key,
    required this.errorMessage,
    this.error,
    this.stackTrace,
    this.showDetails = false
  });

  @override
  State<StatefulWidget> createState() => _ErrorDialogState();
}

class _ErrorDialogState extends State<ErrorDialog> {

  late final _hasDetails = widget.error != null || widget.stackTrace != null;
  late var _showDetails = _hasDetails && widget.showDetails;

  late final _lm = AppLocalizations.of(context)!;

  String _formatErrorDetails() {
    String message = "Error Message: ${widget.errorMessage}\n\n"
        "Platform: ${kIsWeb ? "Web" : Platform.operatingSystem} - ${kIsWeb ? "Web" : Platform.operatingSystemVersion}\n"
        "Timestamp: ${DateTime.now().toIso8601String()}\n\n"
        "Error Details:\n${widget.error.toString()}\n\n";

    if (widget.error is DioException) {
      final dioError = widget.error as DioException;
      message += "Dio Exception Details:\n"
          "Type: ${dioError.type}\n"
          "Path: ${dioError.requestOptions.path}\n"
          "Method: ${dioError.requestOptions.method}\n"
          "Query Parameters: ${dioError.requestOptions.queryParameters}\n"
          "Data: ${dioError.requestOptions.data}\n";
      if (dioError.response != null) {
        message += "Response Data: ${dioError.response?.data}\n"
            "Response Status Message: ${dioError.response?.statusMessage}\n"
            "Response Status Code: ${dioError.response?.statusCode}\n\n"
            "Response Headers:\n${dioError.response?.headers}\n";
      }
      message += "\n";
    }


    message += "Stack Trace:\n${widget.stackTrace}";
    return message;
  }

  Future<void> _copyErrorDetails(BuildContext context) async {
    try {
      await Clipboard.setData(ClipboardData(text: _formatErrorDetails()));
    }
    catch (e, st) {
      if (context.mounted) {
        ErrorHandler.showErrorDialog(context, "Failed to copy error details to clipboard.", error: e, stackTrace: st);
      }
    }
  }

  Future<void> _shareError(BuildContext context) async {
    try {
      Navigator.pop(context);
      await SharePlus.instance.share(ShareParams(
        text: _formatErrorDetails(),
        subject: 'Error Report',
      ));
    }
    catch (e, st) {
      if (context.mounted) {
        ErrorHandler.showErrorDialog(context, "Failed to share error details.", error: e, stackTrace: st);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return AlertDialog(
      icon: Icon(
        Icons.error,
        size: 48, color: Theme.of(context).colorScheme.error
      ),
      constraints: BoxConstraints(
        maxWidth: 600
      ),
      title: Text(_lm.dialog_error),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          Text(widget.errorMessage),
          if (_showDetails && _hasDetails)
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              height: 300,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(
                  _formatErrorDetails(),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            )
        ],
      ),
      actions: [
        if (!_showDetails) ... [
          if (_hasDetails)
            TextButton(
                onPressed: () => setState(() { _showDetails = true; }),
                child: Text(_lm.dialog_error_details)
            )
        ]
        else ... [
          TextButton(
            onPressed: () => _shareError(context),
            child: Text(_lm.dialog_share)
          ),
          TextButton(
            onPressed: () => _copyErrorDetails(context),
            child: Text(_lm.dialog_copy)
          ),
        ],
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_lm.dialog_close),
        ),
      ],
    );
  }
}