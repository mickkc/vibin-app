import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/pages/loading_overlay.dart';

import '../api/api_manager.dart';
import '../extensions.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

class TrackDownloader {

  static Future<void> downloadTrack(BuildContext context, int trackId) async {

    final lm = AppLocalizations.of(context)!;
    final apiManager = getIt<ApiManager>();
    final loadingOverlay = getIt<LoadingOverlay>();

    try {
      loadingOverlay.show(context, message: lm.track_actions_downloading);

      final track = await apiManager.service.getTrack(trackId);
      final bytes = await apiManager.service.downloadTrack(trackId);

      if (!context.mounted) return;

      final saveFile = await FilePicker.platform.saveFile(
          dialogTitle: lm.track_actions_download,
          fileName: track.path.split("/").last,
          bytes: Uint8List.fromList(bytes.data),
          type: FileType.audio
      );

      if (saveFile == null) return;

      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        final file = File(saveFile);
        await file.writeAsBytes(bytes.data);
      }

      if (context.mounted) {
        showSnackBar(context, lm.track_actions_download_success);
      }
    }
    catch (e) {
      log("Error downloading track: $e", error: e, level: Level.error.value);
      if (context.mounted) {
        showSnackBar(context, lm.track_actions_download_error);
      }
    }
    finally {
      loadingOverlay.hide();
    }
  }

}