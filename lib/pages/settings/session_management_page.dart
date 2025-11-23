import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/api/api_manager.dart';
import 'package:vibin_app/api/client_data.dart';
import 'package:vibin_app/auth/auth_state.dart';
import 'package:vibin_app/dtos/sessions/session.dart';
import 'package:vibin_app/dtos/sessions/sessions_response.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/main.dart';
import 'package:vibin_app/utils/datetime_utils.dart';
import 'package:vibin_app/utils/dialogs.dart';
import 'package:vibin_app/widgets/future_content.dart';
import 'package:vibin_app/widgets/settings/settings_title.dart';

import '../../l10n/app_localizations.dart';

class SessionManagementPage extends StatefulWidget {
  const SessionManagementPage({super.key});

  @override
  State<SessionManagementPage> createState() => _SessionManagementPageState();
}

class _SessionManagementPageState extends State<SessionManagementPage> {

  final _apiManager = getIt<ApiManager>();
  final _authState = getIt<AuthState>();
  late final _lm = AppLocalizations.of(context)!;
  late Future<SessionsResponse> _sessionsFuture = _apiManager.service.getAllSessions();

  void _refreshSessions() {
    setState(() {
      _sessionsFuture = _apiManager.service.getAllSessions();
    });
  }

  Future<void> _revokeSession(Session session) async {
    await _apiManager.service.deleteSession(session.id);
    _refreshSessions();
  }

  Future<void> _revokeCurrentSession(Session session) async {
    final confirmed = await Dialogs.showConfirmDialog(context, _lm.settings_sessions_revoke, _lm.settings_sessions_revoke_warning_current);
    if (!confirmed) return;
    _authState.logout();
  }

  Future<void> _revokeAllSessions() async {
    try {
      final clientData = getIt<ClientData>();
      final confirmed = await Dialogs.showConfirmDialog(context, _lm.settings_sessions_revoke_all, _lm.settings_sessions_revoke_all_confirmation);
      if (!confirmed) return;
      await _apiManager.service.deleteAllSessions(clientData.deviceId);
      _refreshSessions();
    }
    catch (e) {
      log("An error occurred while revoking all sessions: $e", error: e, level: Level.error.value);
      if (mounted) showSnackBar(context, _lm.settings_sessions_revoke_failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 32,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SettingsTitle(
          title: _lm.settings_app_manage_sessions_title,
          subtitle: _lm.settings_app_manage_sessions_description,
        ),

        ElevatedButton.icon(
          onPressed: _revokeAllSessions,
          icon: const Icon(Icons.logout),
          label: Text(_lm.settings_sessions_revoke_all)
        ),

        const Divider(),

        FutureContent(
          future: _sessionsFuture,
          hasData: (r) => r.sessions.isNotEmpty,
          builder: (context, response) {
            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: response.sessions.length,
              itemBuilder: (context, index) {
                final session = response.sessions[index];
                final isCurrentSession = index == response.currentSessionIndex;
                return ListTile(
                  title: Text(
                    '${_lm.settings_sessions_last_used} ${DateTimeUtils.convertUtcUnixToLocalTimeString(session.lastUsed, _lm.datetime_format_full)}',
                    style: isCurrentSession ? TextStyle(color: Theme.of(context).colorScheme.primary) : null,
                  ),
                  subtitle: Text('${_lm.settings_sessions_created_at} ${DateTimeUtils.convertUtcUnixToLocalTimeString(session.createdAt, _lm.datetime_format_full)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: _lm.settings_sessions_revoke,
                        onPressed: () async {
                          try {
                            if (isCurrentSession) {
                              await _revokeCurrentSession(session);
                            } else {
                              await _revokeSession(session);
                            }
                          }
                          catch (e) {
                            log("An error occurred while revoking session: $e", error: e, level: Level.error.value);
                            if (context.mounted) showSnackBar(context, _lm.settings_sessions_revoke_failed);
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }

        ),
      ],
    );
  }
}