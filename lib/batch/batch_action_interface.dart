import 'package:flutter/material.dart';
import 'package:vibin_app/l10n/app_localizations.dart';

abstract interface class BatchAction {
  String getName(AppLocalizations lm);
  Map<String, dynamic> dataToJson();
  Widget build(BuildContext context);
}
