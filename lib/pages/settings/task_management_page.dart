import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:vibin_app/dtos/task_dto.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/pages/column_page.dart';
import 'package:vibin_app/utils/datetime_utils.dart';
import 'package:vibin_app/widgets/settings/settings_title.dart';

import '../../api/api_manager.dart';
import '../../main.dart';

class TaskManagementPage extends StatefulWidget {
  const TaskManagementPage({super.key});

  @override
  State<TaskManagementPage> createState() => _TaskManagementPageState();
}

class _TaskManagementPageState extends State<TaskManagementPage> {

  final _apiManager = getIt<ApiManager>();
  late final _lm = AppLocalizations.of(context)!;
  late final _theme = Theme.of(context);

  List<Task> _tasks = [];

  @override
  void initState() {
    _apiManager.service.getAllTasks()
      .then((tasks) {
        setState(() {
          _tasks = tasks;
        });
      })
      .catchError((e) {
        log("An error occurred while fetching tasks: $e", error: e, level: Level.error.value);
        if (mounted) showErrorDialog(context, _lm.settings_task_fetch_error);
      });
    super.initState();
  }

  void _runTaskNow(Task task) async {
    try {
      final result = await _apiManager.service.runTaskNow(task.id);
      setState(() {
        task.lastRun = DateTimeUtils.getUtcNow();
        task.lastResult = result;
      });
    }
    catch (e) {
      log("An error occurred while running task: $e", error: e, level: Level.error.value);
      if (mounted) showSnackBar(context, _lm.settings_task_run_now_failed);
    }
  }

  void _setTaskEnabled(Task task, bool? enabled) async {

    if (enabled == null) return;

    try {
      await _apiManager.service.setTaskEnabled(task.id, enabled);
      setState(() {
        task.enabled = enabled;
      });
    }
    catch (e) {
      log("An error occurred while updating task enabled state: $e", error: e, level: Level.error.value);
      if (mounted) showSnackBar(context, _lm.settings_task_toggle_failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColumnPage(
      children: [
        SettingsTitle(
          title: _lm.settings_app_manage_tasks_title,
          subtitle: _lm.settings_app_manage_tasks_description,
        ),

        const Divider(),

        ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            final task = _tasks[index];
            return ListTile(
              leading: task.lastResult != null
                  ? Icon(
                      task.lastResult!.success ? Icons.check_circle : Icons.error,
                      color: task.lastResult!.success ? _theme.colorScheme.primary : _theme.colorScheme.error
                  ) : null,
              title: Text(task.id),
              subtitle: Text(
                "${_lm.settings_task_last_run} ${task.lastRun != null ? DateTimeUtils.convertUtcUnixToLocalTimeString(task.lastRun!, _lm.datetime_format_full) : _lm.settings_task_run_never}\n"
                "${_lm.settings_task_next_run} ${task.enabled ? DateTimeUtils.convertUtcUnixToLocalTimeString(task.nextRun, _lm.datetime_format_full) : _lm.settings_task_run_never}\n"
                "${_lm.settings_task_interval} ${getDurationString(task.interval)}\n"
                "${_lm.settings_task_message} ${task.lastResult?.message ?? _lm.settings_task_no_message}"
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  IconButton(
                    onPressed: () => _runTaskNow(task),
                    icon: const Icon(Icons.play_circle),
                    tooltip: _lm.settings_task_run_now,
                  ),
                  Tooltip(
                    message: task.enabled ? _lm.settings_task_toggle_disable : _lm.settings_task_toggle_enable,
                    child: Checkbox(
                      value: task.enabled,
                      onChanged: (enable) => _setTaskEnabled(task, enable),
                    ),
                  ),
                ],
              )
            );
          },
        )
      ]
    );
  }
}