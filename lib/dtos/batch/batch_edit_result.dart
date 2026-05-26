import 'batch_edit_result_change.dart';

class BatchEditResult {
  final int affectedTracks;
  final int affectedFields;
  final List<BatchEditResultChange> changes;
  final bool didWriteToDatabase;
  final String? error;

  BatchEditResult({
    required this.affectedTracks,
    required this.affectedFields,
    required this.changes,
    required this.didWriteToDatabase,
    this.error
  });

  factory BatchEditResult.fromJson(Map<String, dynamic> json) {
    return BatchEditResult(
      affectedTracks: json['affectedTracks'],
      affectedFields: json['affecteddFields'],
      changes: (json['changes'] as List<dynamic>)
          .map((change) { return BatchEditResultChange.fromJson(change); })
          .toList(),
      didWriteToDatabase: json['didWriteToDatabase'],
      error: json['error']
    );
  }
}