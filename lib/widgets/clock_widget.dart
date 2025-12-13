import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

class ClockWidget extends StatefulWidget {
  final TextStyle? textStyle;

  const ClockWidget({super.key, this.textStyle});

  @override
  State<ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> {
  
  final _timeStreamController = StreamController<DateTime>.broadcast();
  final _duration = const Duration(seconds: 1);

  late final formatter = DateFormat(AppLocalizations.of(context)!.datetime_format_time);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startClock();
  }
  
  void _startClock() {
    _timer = Timer.periodic(_duration, (timer) {
      _timeStreamController.add(DateTime.now());
    });
  }
  
  @override
  void dispose() {
    _timeStreamController.close();
    _timer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream: _timeStreamController.stream,
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final formattedTime = formatter.format(now);
        return Text(
          formattedTime,
          style: widget.textStyle
        );
      },
    );
  }
}
