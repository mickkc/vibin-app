import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

import '../auth/auth_state.dart';
import '../main.dart';

class DeleteUserDialog extends StatefulWidget {
  final int userId;
  final void Function(bool confirmed, bool deleteData) onClose;

  const DeleteUserDialog({
    super.key,
    required this.onClose,
    required this.userId,
  });

  static void show(BuildContext context, final int userId, void Function(bool confirmed, bool deleteData) onClose) {
    showDialog(
      context: context,
      builder: (context) => DeleteUserDialog(
        userId: userId,
        onClose: onClose,
      ),
    );
  }

  @override
  State<DeleteUserDialog> createState() => _DeleteUserDialogState();
}

class _DeleteUserDialogState extends State<DeleteUserDialog> {

  bool _deleteData = false;

  final _authState = getIt<AuthState>();
  late final _lm = AppLocalizations.of(context)!;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      constraints: const BoxConstraints(
        maxWidth: 600,
      ),
      title: Text(
          widget.userId == _authState.user?.id
              ? _lm.delete_user_confirmation_self
              : _lm.delete_user_confirmation
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(_lm.delete_user_confirmation_warning),

          if (widget.userId == _authState.user?.id)
            Text(_lm.delete_user_self_warning),

          CheckboxListTile(
            title: Text(
                widget.userId == _authState.user?.id
                    ? _lm.delete_user_delete_data_self
                    : _lm.delete_user_delete_data
            ),
            value: _deleteData,
            onChanged: (value) {
              setState(() {
                _deleteData = value ?? false;
              });
            },
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onClose(false, false);
            Navigator.pop(context);
          },
          child: Text(_lm.dialog_cancel),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onClose(true, _deleteData);
            Navigator.pop(context);
          },
          child: Text(_lm.dialog_delete),
        )
      ],
    );
  }
}