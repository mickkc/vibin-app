import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/widgets/colored_icon_button.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../../l10n/app_localizations.dart';

class ImageEditField extends StatelessWidget {
  final String? fallbackImageUrl;
  final String? imageUrl;
  final String? label;
  final double size;
  final void Function(String?) onImageChanged;

  const ImageEditField({
    super.key,
    this.fallbackImageUrl,
    this.imageUrl,
    this.label,
    this.size = 128,
    required this.onImageChanged
  });

  static final _urlRegex = RegExp(
    r'^(https?:\/\/)?' // protocol
    r'((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|' // domain name
    r'((\d{1,3}\.){3}\d{1,3}))' // OR ip (v4) address
    r'(\:\d+)?(\/[-a-z\d%_.~+]*)*' // port and path
    r'(\?[;&a-z\d%_.~+=-]*)?' // query string
    r'(\#[-a-z\d_]*)?$', // fragment locator
    caseSensitive: false,
  );

  void _enterUrl(BuildContext context) async {
    final lm = AppLocalizations.of(context)!;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(lm.edit_image_enter_url),
          content: TextField(
            keyboardType: TextInputType.url,
            autofocus: true,
            onSubmitted: (value) {
              if (_setUrl(value)) {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(lm.dialog_cancel),
            )
          ],
        );
      }
    );
  }

  Future<ImageUploadResult> _uploadImage() async {
    try {
      PlatformFile? result = await FilePicker.pickFile(
        type: FileType.image,
      );

      if (result == null) return ImageUploadResult.noFileSelected;

      final size = await result.length();
      if (size == null) return ImageUploadResult.error;

      if (size > 5 * 1024 * 1024) {
        return ImageUploadResult.fileTooLarge;
      }
      if (result.extension == null || result.extension!.isEmpty) {
        return ImageUploadResult.unsupportedFileType;
      }
      if (!['jpg', 'jpeg', 'png', 'gif'].contains(result.extension!.toLowerCase())) {
        return ImageUploadResult.unsupportedFileType;
      }
      final bytes = await result.readAsBytes();
      if (bytes.isNotEmpty) {
        final base64Data = base64Encode(bytes);
        onImageChanged("data:image/${result.extension?.toLowerCase()};base64,$base64Data");
        return ImageUploadResult.success;
      }
      else {
        return ImageUploadResult.error;
      }
    }
    catch (e, st) {
      logger.handle(e, st, "Error uploading image");
      return ImageUploadResult.error;
    }
  }

  bool _setUrl(String url) {
    if (url.isNotEmpty && _urlRegex.hasMatch(url)) {
      onImageChanged(url);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final lm = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Text(label!, style: theme.textTheme.labelMedium),
        SizedBox(
          width: size,
          height: size,
          child: imageUrl != null && imageUrl!.isNotEmpty
              ? NetworkImageWidget(url: imageUrl!, width: size, height: size, fit: BoxFit.cover)
              : (fallbackImageUrl != null && (imageUrl == null || imageUrl!.isNotEmpty)
                ? NetworkImageWidget(url: fallbackImageUrl!, width: size, height: size, fit: BoxFit.cover)
                : Container(
                    color: theme.colorScheme.surfaceContainerHigh,
                    child: Center(
                      child: Icon(Icons.image_not_supported_outlined, size: size / 2))
                    )
                )
        ),
        SizedBox(height: 8),
        SizedBox(
          width: size,
          child: Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ColoredIconButton(
                onPressed: () async {
                  final result = await _uploadImage();
                  String? message = switch(result) {
                    ImageUploadResult.success => null,
                    ImageUploadResult.fileTooLarge => lm.edit_image_too_large,
                    ImageUploadResult.unsupportedFileType => lm.edit_image_invalid_extension,
                    ImageUploadResult.noFileSelected => null,
                    ImageUploadResult.error => lm.edit_image_error,
                  };
                  if (message != null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message))
                    );
                  }
                },
                icon: Icons.upload_file,
                backgroundColor: theme.colorScheme.primaryContainer,
                iconColor: theme.colorScheme.onPrimaryContainer,
                tooltip: lm.edit_image_upload,
              ),
              ColoredIconButton(
                onPressed: () { _enterUrl(context); },
                icon: Icons.link,
                backgroundColor: theme.colorScheme.primaryContainer,
                iconColor: theme.colorScheme.onPrimaryContainer,
                tooltip: lm.edit_image_enter_url,
              ),
              ColoredIconButton(
                onPressed: (){ onImageChanged(null); },
                icon: Icons.refresh,
                backgroundColor: theme.colorScheme.secondaryContainer,
                iconColor: theme.colorScheme.onSecondaryContainer,
                tooltip: lm.edit_image_reset,
              ),
              ColoredIconButton(
                onPressed: (){ onImageChanged(""); },
                icon: Icons.delete,
                backgroundColor: theme.colorScheme.errorContainer,
                iconColor: theme.colorScheme.onErrorContainer,
                tooltip: lm.edit_image_remove,
              ),
            ]
          ),
        )
      ],
    );
  }
}

enum ImageUploadResult {
  success,
  fileTooLarge,
  unsupportedFileType,
  noFileSelected,
  error
}