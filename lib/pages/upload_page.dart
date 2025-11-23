import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/dtos/uploads/pending_upload.dart';
import 'package:vibin_app/pages/column_page.dart';
import 'package:vibin_app/pages/edit/track_edit_page.dart';
import 'package:vibin_app/pages/loading_overlay.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/network_image.dart';

import '../api/api_manager.dart';
import '../extensions.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../utils/dialogs.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {

  List<PendingUpload> _pendingUploads = [];

  bool _initialized = false;

  late final _lm = AppLocalizations.of(context)!;
  final _apiManager = getIt<ApiManager>();
  final _loadingOverlay = getIt<LoadingOverlay>();
  final _encoder = Base64Encoder();

  @override
  void initState() {

    super.initState();

    _apiManager.service.getPendingUploads()
      .then((uploads) {
        setState(() {
          _pendingUploads = uploads;
          _initialized = true;
        });
      })
      .catchError((e, st) {
        log("An error occurred while fetching pending uploads: $e", error: e, level: Level.error.value);
        if (mounted) ErrorHandler.showErrorDialog(context, _lm.uploads_fetch_error, error: e, stackTrace: st);
        setState(() {
          _initialized = true;
        });
      });
  }

  void _openEditDialog(PendingUpload upload) async {
    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TrackEditPage(
              pendingUpload: upload,
              onSave: (data) async {

                try {
                  final updatedUpload = await _apiManager.service.updatePendingUpload(upload.id, data);
                  setState(() {
                    final index = _pendingUploads.indexWhere((u) => u.id == upload.id);
                    if (index != -1) {
                      _pendingUploads[index] = updatedUpload;
                    }
                  });
                }
                catch (e, st) {
                  log("An error occurred while saving pending upload: $e", error: e, level: Level.error.value);
                  if (context.mounted) ErrorHandler.showErrorDialog(context, _lm.uploads_edit_save_error, error: e, stackTrace: st);
                }
              },
            ),
          ),
        );
      }
    );
  }

  void _uploadFiles() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: _lm.uploads_upload_file,
      type: FileType.audio,
      allowMultiple: true,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;

    if (mounted) _loadingOverlay.show(context, message: _lm.uploads_tracks_uploading);

    try {
      List<PendingUpload> newPendingUploads = [];

      for (final file in result.files) {
        try {
          final fileContentBytes = file.bytes;

          if (fileContentBytes == null) {
            log("File bytes are null for file: ${file.name}", level: Level.error.value);
            if (mounted) await ErrorHandler.showErrorDialog(context, _lm.uploads_upload_error(file.name));
            continue;
          }

          final base64 = _encoder.convert(fileContentBytes);

          final pendingUpload = await _apiManager.service.createUpload(
              base64, file.name);
          newPendingUploads.add(pendingUpload);
        }
        catch (e, st) {
          if (e is DioException) {
            if (e.response?.statusCode == 409 && mounted) {
              await ErrorHandler.showErrorDialog(context, _lm.uploads_upload_error_file_exists);
            }
            else if (e.response?.statusCode == 400 && mounted) {
              await ErrorHandler.showErrorDialog(context, _lm.uploads_upload_error_invalid_file);
            }
            continue;
          }

          log("An error occurred while uploading file: $e", error: e, level: Level.error.value);
          if (mounted) ErrorHandler.showErrorDialog(context, _lm.uploads_upload_error(file.name), error: e, stackTrace: st);
        }
      }

      if (newPendingUploads.isNotEmpty) {
        setState(() {
          _pendingUploads.addAll(newPendingUploads);
        });
      }
      else {
        if (mounted) showSnackBar(context, _lm.uploads_all_uploads_failed);
      }
    }
    finally {
      _loadingOverlay.hide();
    }
  }

  void _applyUpload(PendingUpload upload) async {

    if (mounted) _loadingOverlay.show(context);

    try {
      final result = await _apiManager.service.applyPendingUpload(upload.id);

      if (result.success) {
        setState(() {
          _pendingUploads.removeWhere((u) => u.id == upload.id);
        });
        if (mounted) {
          showActionSnackBar(
            context,
            _lm.uploads_apply_success(upload.title),
            _lm.uploads_apply_success_open_track,
            () {
              GoRouter.of(context).push("/tracks/${result.id}");
            }
          );
        }
      }
      else {
        if (result.didFileAlreadyExist) {
          if (mounted) ErrorHandler.showErrorDialog(context, _lm.uploads_apply_failed_file_exists);
        }
        else {
          if (mounted) ErrorHandler.showErrorDialog(context, _lm.uploads_apply_error(upload.title));
        }
      }
    }
    catch (e, st) {
      log("An error occurred while applying pending upload: $e", error: e, level: Level.error.value);
      if (mounted) ErrorHandler.showErrorDialog(context, _lm.uploads_apply_error(upload.title), error: e, stackTrace: st);
    }
    finally {
      _loadingOverlay.hide();
    }
  }

  Future<void> _deleteUpload(PendingUpload upload) async {
    final confirmed = await Dialogs.showConfirmDialog(context, _lm.uploads_delete_confirm_title, _lm.uploads_delete_confirm_message);
    if (!confirmed) return;

    if (mounted) _loadingOverlay.show(context);

    try {
      await _apiManager.service.deletePendingUpload(upload.id);
      setState(() {
        _pendingUploads.removeWhere((u) => u.id == upload.id);
      });
      if (mounted) showSnackBar(context, _lm.uploads_delete_success);
    }
    catch (e, st) {
      log("An error occurred while deleting pending upload: $e", error: e, level: Level.error.value);
      if (mounted) ErrorHandler.showErrorDialog(context, _lm.uploads_delete_error, error: e, stackTrace: st);
    }
    finally {
      _loadingOverlay.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColumnPage(
      children: [

        ElevatedButton.icon(
          onPressed: _uploadFiles,
          label: Text(_lm.uploads_upload_file),
          icon: const Icon(Icons.upload_file),
        ),

        if (!_initialized)
          const Center(child: CircularProgressIndicator())
        else if (_pendingUploads.isEmpty)
          Center(
            child: Text(_lm.uploads_no_uploads),
          )
        else
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _pendingUploads.length,
            itemBuilder: (context, index) {
              final upload = _pendingUploads[index];
              return ListTile(
                leading: upload.coverUrl != null ? NetworkImageWidget(
                  url: upload.coverUrl!,
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(4),
                ) : const Icon(Icons.upload_file),
                title: Text(upload.title),
                subtitle: Text("${upload.album?.title} - ${upload.artists.map((a) => a.name).join(", ")}"),
                onTap: () => _openEditDialog(upload),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    IconButton(
                      onPressed: () => _deleteUpload(upload),
                      icon: const Icon(Icons.delete)
                    ),
                    IconButton(
                      onPressed: () => _applyUpload(upload),
                      icon: const Icon(Icons.done)
                    ),
                  ],
                ),
              );
            },
          )
      ]
    );
  }
}