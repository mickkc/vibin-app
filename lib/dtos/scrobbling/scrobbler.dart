class Scrobbler {
  final String id;
  final String name;
  final bool available;

  Scrobbler({
    required this.id,
    required this.name,
    required this.available
  });

  factory Scrobbler.fromJson(Map<String, dynamic> json) {
    return Scrobbler(
      id: json['id'],
      name: json['name'],
      available: json['available']
    );
  }
}