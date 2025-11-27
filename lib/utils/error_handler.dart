import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

class ErrorHandler {
  static Future<void> showErrorDialog(BuildContext context, String errorMessage, {Object? error, StackTrace? stackTrace}) async {
    return showDialog(
      context: context,
      builder: (context) => ErrorDialog(
        errorMessage: errorMessage,
        error: (error != null && error is Exception) ? error : null,
        stackTrace: stackTrace,
      ),
    );
  }
}


class ErrorDialog extends StatelessWidget {
  final String errorMessage;
  final Exception? error;
  final StackTrace? stackTrace;

  const ErrorDialog({
    super.key,
    required this.errorMessage,
    this.error,
    this.stackTrace,
  });

  String _formatErrorDetails() {
    String message = "Error Message: $errorMessage\n\n"
        "Platform: ${Platform.operatingSystem} - ${Platform.operatingSystemVersion}\n"
        "Timestamp: ${DateTime.now().toIso8601String()}\n\n"
        "Error Details:\n${error.toString()}\n\n";

    if (error is DioException) {
      final dioError = error as DioException;
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


    message += "Stack Trace:\n$stackTrace";
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

    final lm = AppLocalizations.of(context)!;

    return AlertDialog(
      icon: Icon(
        Icons.error,
        size: 48, color: Theme.of(context).colorScheme.error
      ),
      constraints: BoxConstraints(
        maxWidth: 600
      ),
      title: Text(lm.dialog_error),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 16,
        children: [
          Text(errorMessage),
          if (error != null)
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
        TextButton(
          onPressed: () => _shareError(context),
          child: Text(lm.dialog_share)
        ),
        TextButton(
          onPressed: () => _copyErrorDetails(context),
          child: Text(lm.dialog_copy)
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(lm.dialog_close),
        ),
      ],
    );
  }
}