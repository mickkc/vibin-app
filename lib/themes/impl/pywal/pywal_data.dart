class PywalData {
  final String wallpaper;
  final String alpha;

  final PywalSpecialColors special;
  final PywalColors colors;

  PywalData({
    required this.wallpaper,
    required this.alpha,
    required this.special,
    required this.colors,
  });

  factory PywalData.fromJson(Map<String, dynamic> json) {
    return PywalData(
      wallpaper: json['wallpaper'],
      alpha: json['alpha'],
      special: PywalSpecialColors.fromJson(json['special']),
      colors: PywalColors.fromJson(json['colors']),
    );
  }
}

class PywalSpecialColors {
  final String background;
  final String foreground;
  final String cursor;

  PywalSpecialColors({
    required this.background,
    required this.foreground,
    required this.cursor,
  });

  factory PywalSpecialColors.fromJson(Map<String, dynamic> json) {
    return PywalSpecialColors(
      background: json['background'],
      foreground: json['foreground'],
      cursor: json['cursor'],
    );
  }
}

class PywalColors {
  final String color0;
  final String color1;
  final String color2;
  final String color3;
  final String color4;
  final String color5;
  final String color6;
  final String color7;
  final String color8;
  final String color9;
  final String color10;
  final String color11;
  final String color12;
  final String color13;
  final String color14;
  final String color15;

  PywalColors({
    required this.color0,
    required this.color1,
    required this.color2,
    required this.color3,
    required this.color4,
    required this.color5,
    required this.color6,
    required this.color7,
    required this.color8,
    required this.color9,
    required this.color10,
    required this.color11,
    required this.color12,
    required this.color13,
    required this.color14,
    required this.color15,
  });

  factory PywalColors.fromJson(Map<String, dynamic> json) {
    return PywalColors(
      color0: json['color0'],
      color1: json['color1'],
      color2: json['color2'],
      color3: json['color3'],
      color4: json['color4'],
      color5: json['color5'],
      color6: json['color6'],
      color7: json['color7'],
      color8: json['color8'],
      color9: json['color9'],
      color10: json['color10'],
      color11: json['color11'],
      color12: json['color12'],
      color13: json['color13'],
      color14: json['color14'],
      color15: json['color15'],
    );
  }
}