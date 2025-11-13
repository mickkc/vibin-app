import 'package:vibin_app/l10n/app_localizations.dart';

class MetadataFetchType {
  static const String exactMatch = "EXACT_MATCH";
  static const String caseInsensitiveMatch = "CASE_INSENSITIVE_MATCH";
  static const String firstResult = "FIRST_RESULT";
  static const String none = "NONE";

  static const List<String> values = [
    exactMatch,
    caseInsensitiveMatch,
    firstResult,
    none,
  ];

  static String format(String type, AppLocalizations lm) {
    switch (type) {
      case exactMatch:
        return lm.settings_server_metadata_matching_type_exact;
      case caseInsensitiveMatch:
        return lm.settings_server_metadata_matching_type_case_insensitive;
      case firstResult:
        return lm.settings_server_metadata_matching_type_first;
      case none:
        return lm.settings_server_metadata_matching_type_disabled;
      default:
        return type;
    }
  }
}