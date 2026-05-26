class BatchEdit {
  final List<int>? trackIds;
  final String? query;

  final List<Map<String, dynamic>> actions;
  final bool dryRun;

  BatchEdit(this.trackIds, this.query, this.actions, this.dryRun);

  Map<String, dynamic> toJson() {
    return {
      'trackIds': trackIds,
      'query': query,
      'actions': actions,
      'dryRun': dryRun,
    };
  }
}