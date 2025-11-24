class SharedWidget {
  final String id;
  final List<String> types;
  final int? bgColor;
  final int? fgColor;
  final int? accentColor;

  SharedWidget({
    required this.id,
    required this.types,
    this.bgColor,
    this.fgColor,
    this.accentColor,
  });

  factory SharedWidget.fromJson(Map<String, dynamic> json) {
    return SharedWidget(
      id: json['id'] as String,
      types: List<String>.from(json['types'] as List),
      bgColor: json['bgColor'] as int?,
      fgColor: json['fgColor'] as int?,
      accentColor: json['accentColor'] as int?,
    );
  }
}