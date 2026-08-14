import '../main.dart';

class DurationConverter {

  static const Map<String, int> _secondsMap = {
    'y': 31556952,
    'M': 2629746,
    'w': 604800,
    'd': 86400,
    'h': 3600,
    'm': 60,
    's': 1,
  };

  static const List<String> _keysDesc = ['y', 'M', 'w', 'd', 'h', 'm', 's'];

  static int? parseDuration(String durationStr) {
    final cleanedDurationStr = durationStr.replaceAll(RegExp(r'(?<=[a-zA-Z])[a-zA-Z]+|\s'), '');

    if (cleanedDurationStr != durationStr) {
      logger.debug("Cleaned up duration string: '$durationStr' -> '$cleanedDurationStr'.");
    }

    if (cleanedDurationStr.isEmpty) {
      logger.warning("Could not parse '$durationStr' as a duration: Empty string after processing.");
      return null;
    }

    var numberBuffer = '';
    var durationSeconds = 0;

    for (final c in cleanedDurationStr.split('')) {
      if (_isDigit(c)) {
        numberBuffer += c;
      } else {
        if (numberBuffer.isEmpty) {
          logger.warning("Could not parse '$durationStr' as a duration: Unit without amount: $c.");
          return null;
        }

        if (c == 'M') {
          durationSeconds += int.parse(numberBuffer) * _secondsMap[c]!;
        } else {
          final seconds = _secondsMap[c.toLowerCase()];
          if (seconds == null) {
            logger.warning("Could not parse '$durationStr' as a duration: Invalid unit: $c.");
            return null;
          }
          durationSeconds += int.parse(numberBuffer) * seconds;
        }

        numberBuffer = '';
      }
    }

    if (numberBuffer.isNotEmpty) {
      logger.warning("Could not parse '$durationStr' as a duration: Amount without value: $numberBuffer.");
      return null;
    }

    return durationSeconds;
  }

  static String formatDurationFull(int duration) {
    if (duration < 0) {
      throw ArgumentError('Duration can not be negative! Value: $duration');
    }
    if (duration == 0) return '0s';

    var remainingDuration = duration;
    var output = '';

    do {
      for (final key in _keysDesc) {
        final value = _secondsMap[key]!;
        if (value > remainingDuration) continue;

        final amount = remainingDuration ~/ value;
        output += '$amount$key ';

        remainingDuration -= amount * value;
        break;
      }
    } while (remainingDuration > 0);

    return output.trim();
  }

  static bool _isDigit(String c) {
    final code = c.codeUnitAt(0);
    return code >= 0x30 && code <= 0x39;
  }

}