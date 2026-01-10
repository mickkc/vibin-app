import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:super_sliver_list/super_sliver_list.dart';
import 'package:vibin_app/dtos/tasks/task_action.dart';
import 'package:vibin_app/dtos/tasks/task_dto.dart';
import 'package:vibin_app/dtos/tasks/task_progress.dart';
import 'package:vibin_app/extensions.dart';
import 'package:vibin_app/l10n/app_localizations.dart';
import 'package:vibin_app/pages/column_page.dart';
import 'package:vibin_app/utils/datetime_utils.dart';
import 'package:vibin_app/utils/error_handler.dart';
import 'package:vibin_app/widgets/settings/settings_title.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

  final Map<String, TaskProgress> _taskProgressMap = {};

  WebSocketChannel? _socketChannel;
  StreamSubscription? _socketSubscription;

  List<Task> _tasks = [];

  @override
  void initState() {
    _apiManager.service.getAllTasks()
      .then((tasks) {
        setState(() {
          _tasks = tasks;
        });
      })
      .catchError((e, st) {
        log("An error occurred while fetching tasks: $e", error: e, level: Level.error.value);
        if (mounted) ErrorHandler.showErrorDialog(context, _lm.settings_task_fetch_error, error: e, stackTrace: st);
      });

    try {
      _socketChannel = WebSocketChannel.connect(
        Uri.parse("${_apiManager.baseUrl.replaceFirst("http", "ws")}/api/tasks/progress?token=${_apiManager.accessToken}"),
      );
      _socketSubscription = _socketChannel?.stream.listen((message) {
        try {
          if (message is! String) return;

          final taskAction = TaskAction.fromJson(json.decode(message));
          switch (taskAction.action) {
            case "start":
              setState(() {
                _taskProgressMap[taskAction.taskId] = taskAction.progress ?? TaskProgress(
                  taskId: taskAction.taskId,
                  progress: null,
                  message: null
                );
              });
              break;
            case "progress":
              setState(() {
                _taskProgressMap[taskAction.taskId] = taskAction.progress!;
              });
              break;
            case "complete":
              try {
                _taskProgressMap.remove(taskAction.taskId);
                final task = _tasks.firstWhere((t) => t.id == taskAction.taskId);
                setState(() {
                  task.lastResult = taskAction.result;
                });
              }
              catch (e, st) {
                log("An error occurred while updating task on completion: $e", error: e, level: Level.error.value);
                if (mounted) ErrorHandler.showErrorDialog(context, _lm.settings_task_ws_message_error, error: e, stackTrace: st);
              }
              break;
          }
        }
        catch (e, st) {
          log("An error occurred while parsing task progress message: $e", error: e, level: Level.error.value);
          if (mounted) ErrorHandler.showErrorDialog(context, _lm.settings_task_ws_message_error, error: e, stackTrace: st);
        }
      }, onError: (e, st) {
        log("An error occurred in task progress WebSocket: $e", error: e, level: Level.error.value);
        if (mounted) ErrorHandler.showErrorDialog(context, _lm.settings_task_ws_connection_error, error: e, stackTrace: st);
      });
    }
    catch (e, st) {
      log("An error occurred while connecting to task progress WebSocket: $e", error: e, level: Level.error.value);
      if (mounted) ErrorHandler.showErrorDialog(context, _lm.settings_task_ws_connection_failed, error: e, stackTrace: st);
    }

    super.initState();
  }

  @override
  void dispose() {
    _socketSubscription?.cancel();
    _socketChannel?.sink.close();
    super.dispose();
  }

  void _runTaskNow(Task task) async {
    try {
      await _apiManager.service.runTaskNow(task.id);
      setState(() {
        task.lastRun = DateTimeUtils.getUtcNow();
      });
    }
    catch (e) {
      log("An error occurred while running task: $e", error: e, level: Level.error.value);
      if (mounted) ErrorHandler.showErrorDialog(context, _lm.settings_task_run_now_failed, error: e);
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
    catch (e, st) {
      log("An error occurred while updating task enabled state: $e", error: e, level: Level.error.value);
      if (mounted) ErrorHandler.showErrorDialog(context, _lm.settings_task_toggle_failed, error: e, stackTrace: st);
    }
  }

  void _cancelTask(String taskId) async {
    try {
      await _apiManager.service.cancelTask(taskId);
      if (mounted) showSnackBar(context, _lm.settings_task_cancel_success);
    }
    catch (e, st) {
      log("An error occurred while cancelling task: $e", error: e, level: Level.error.value);
      if (mounted) ErrorHandler.showErrorDialog(context, _lm.settings_task_cancel_failed, error: e, stackTrace: st);
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

        if (_taskProgressMap.isNotEmpty) ... [
          SuperListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _taskProgressMap.length,
            itemBuilder: (context, index) {
              final taskProgress = _taskProgressMap.values.elementAt(index);
              return ListTile(
                title: Text(taskProgress.taskId),
                subtitle: taskProgress.message != null ? Text(taskProgress.message!) : null,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    IconButton(
                      onPressed: () => _cancelTask(taskProgress.taskId),
                      icon: const Icon(Icons.cancel),
                      tooltip: _lm.dialog_cancel,
                    ),
                    Stack(
                      children: [
                        CircularProgressIndicator(
                          value: taskProgress.progress,
                        ),
                        if (taskProgress.progress != null)
                          Positioned.fill(
                            child: Center(
                              child: Text(
                                "${(taskProgress.progress! * 100).toStringAsFixed(0)}%",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          const Divider(),
        ],

        SuperListView.builder(
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
                "${_lm.settings_task_next_run} ${task.nextRun != null ? DateTimeUtils.convertUtcUnixToLocalTimeString(task.nextRun!, _lm.datetime_format_full) : _lm.settings_task_run_never}\n"
                "${_lm.settings_task_interval} ${task.interval != null ? getDurationString(task.interval!) : _lm.settings_task_run_never}\n"
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