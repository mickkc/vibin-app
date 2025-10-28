import 'package:intl/intl.dart';

class DateTimeUtils {

  static String convertUtcUnixToLocalTimeString(int utcUnixTimestamp, String format) {

    final utcDateTime = DateTime.fromMillisecondsSinceEpoch(utcUnixTimestamp * 1000, isUtc: true);

    final localDateTime = utcDateTime.toLocal();

    final formatter = DateFormat(format);
    return formatter.format(localDateTime);
  }

  static int getUtcNow() {
    return DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  }

}