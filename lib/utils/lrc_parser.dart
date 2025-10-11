class LrcParser {

  static final timeRegExp = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\]');

  static ParsedLyrics parseLyrics(String rawLyrics) {
    final List<LyricLine> lyricsMap = [];
    final Map<String, String> otherMetadata = {};
    final lines = rawLyrics.split('\n');

    for (var line in lines) {
      if (line.trim().isEmpty) continue;

      final match = timeRegExp.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        final milliseconds = int.parse(match.group(3)!.padRight(3, '0'));
        final totalMilliseconds = (minutes * 60 + seconds) * 1000 +
            milliseconds;
        final lyricText = line.replaceAll(timeRegExp, '').trim();
        lyricsMap.add(LyricLine(Duration(milliseconds: totalMilliseconds), lyricText));
      }
      else if (line.startsWith('[') && line.endsWith(']')) {
        final splitIndex = line.indexOf(':');
        if (splitIndex != -1) {
          final key = line.substring(1, splitIndex).trim();
          final value = line.substring(splitIndex + 1, line.length - 1).trim();
          otherMetadata[key] = value;
        }
      }
      else {
        lyricsMap.add(LyricLine(Duration.zero, line));
      }
    }

    return ParsedLyrics(lines: lyricsMap, otherMetadata: otherMetadata);
  }

  static String writeLrc(ParsedLyrics lyrics) {
    final buffer = StringBuffer();
    final sortedLines = lyrics.lines..sort();

    for (var entry in lyrics.otherMetadata.entries) {
      buffer.writeln('[${entry.key}:${entry.value}]');
    }

    if (lyrics.isSynced) {
      for (var line in sortedLines) {
        final minutes = line.timestamp.inMinutes.toString().padLeft(2, '0');
        final seconds = (line.timestamp.inSeconds % 60).toString().padLeft(2, '0');
        final milliseconds = (line.timestamp.inMilliseconds % 1000).toString().padLeft(3, '0').substring(0, 2);
        buffer.writeln('[$minutes:$seconds.$milliseconds] ${line.text}');
      }
    }
    else {
      for (var line in sortedLines) {
        buffer.writeln(line.text);
      }
    }

    return buffer.toString();
  }
}

class ParsedLyrics {
  final List<LyricLine> lines;
  final Map<String, String> otherMetadata;

  ParsedLyrics({
    required this.lines,
    this.otherMetadata = const {},
  });

  bool get isSynced => lines.any((line) => line.timestamp > Duration.zero);

  void shiftAll(Duration offset) {
    if (!isSynced) return;
    for (var line in lines) {
      line.shift(offset);
    }
  }
}

class LyricLine implements Comparable<LyricLine> {
  Duration timestamp;
  final String text;

  LyricLine(this.timestamp, this.text);

  @override
  int compareTo(LyricLine other) {
    return timestamp.compareTo(other.timestamp);
  }

  void shift(Duration offset) {
    var newTimestamp = timestamp + offset;
    if (newTimestamp.isNegative) {
      newTimestamp = Duration.zero;
    }
    timestamp = newTimestamp;
  }
}