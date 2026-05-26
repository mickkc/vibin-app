import 'package:flutter/material.dart';
import 'package:vibin_app/dtos/album/album.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import '../dialogs/album_picker.dart';
import 'batch_action_interface.dart';

class ChangeAlbumAction implements BatchAction {
  Album? album;

  @override
  Widget build(BuildContext context) => _ChangeAlbumWidget(this);

  @override
  Map<String, dynamic> dataToJson() => {
    "actionType": "CHANGE_ALBUM",
    "data": {
      "id": album?.id
    }
  };

  @override
  String getName(AppLocalizations lm) => lm.batch_edit_actions_change_album;
}

class _ChangeAlbumWidget extends StatefulWidget {
  final ChangeAlbumAction action;
  const _ChangeAlbumWidget(this.action);

  @override
  State<_ChangeAlbumWidget> createState() => _ChangeAlbumWidgetState();
}

class _ChangeAlbumWidgetState extends State<_ChangeAlbumWidget> {

  late final _lm = AppLocalizations.of(context)!;

  late final TextEditingController _albumController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    _albumController = TextEditingController(text: _formatAlbum(widget.action.album));
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _albumController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _formatAlbum(Album? album) {
    if (album == null) return "";
    return "${album.title} - id: ${album.id} - ${album.artists.map((a) => a.name).join(", ")}";
  }

  void _openDialog() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlbumPicker(
          selectedAlbum: widget.action.album,
          onAlbumSelected: (album) {
            setState(() {
              widget.action.album = album;
              _albumController.text = _formatAlbum(album);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _focusNode.unfocus();
              });
            });
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 8,
      children: [
        Text("${_lm.album}:"),
        Expanded(
          child: TextField(
            controller: _albumController,
            readOnly: true,
            onTap: _openDialog,
            focusNode: _focusNode,
            decoration: InputDecoration(
              border: OutlineInputBorder()
            ),
          ),
        )
      ],
    );
  }
}