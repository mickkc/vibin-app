

class NonTrackListen {
  final String key;
  final dynamic value;

  NonTrackListen({
    required this.key,
    required this.value,
  });

  factory NonTrackListen.fromJson(Map<String, dynamic> json) {
    return NonTrackListen(
      key: json['key'],
      value: json['value']
    );
  }
}