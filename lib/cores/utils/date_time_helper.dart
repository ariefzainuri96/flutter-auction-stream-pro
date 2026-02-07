import 'package:flutter/material.dart';
import 'string_extension.dart';
import 'package:intl/intl.dart';

class DateTimeHelper {
  static DateFormat format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
  static DateFormat localize = DateFormat('dd MMM yyyy', 'in_ID');
  static DateFormat localizeWithTime = DateFormat('dd MMM yyyy HH:mm', 'in_ID');

  static formatAndLocalizeDate({
    required String? dateString,
    bool isWithTime = false,
  }) {
    if (dateString.isNullOrEmpty) {
      return '';
    }
    DateTime formatted = format.parse(dateString!, true);

    return isWithTime
        ? localizeWithTime.format(formatted.toLocal())
        : localize.format(formatted.toLocal());
  }

  static String formattingDateString(
    String inputDate,
    String outputFormat, {
    String inputFormat = '',
    bool isUtc = true,
    String defaultReturn = '-',
  }) {
    try {
      DateTime dateTime = DateTime.now();

      if (inputFormat.isEmpty) {
        dateTime = DateTime.parse(inputDate);
      } else {
        DateFormat inputFormatter = DateFormat(inputFormat, 'in_ID');
        dateTime = inputFormatter.parse(inputDate);
      }

      if (isUtc) {
        dateTime = DateTime.utc(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
          dateTime.second,
        );

        dateTime = dateTime.toLocal();
      }

      DateFormat output = DateFormat(outputFormat, 'in_ID');
      String result = output.format(dateTime);
      return result;
    } catch (e) {
      debugPrint('error formattingDateTime: $e');
      return defaultReturn;
    }
  }

  static String formatDateTime(
    DateTime? dateTime, {
    String outputFormat = 'yyyy-MM-dd HH:mm:ss',
    bool isUtc = true,
  }) {
    try {
      if (dateTime == null) return '-';

      if (isUtc) {
        dateTime = DateTime.utc(
          dateTime.year,
          dateTime.month,
          dateTime.day,
          dateTime.hour,
          dateTime.minute,
          dateTime.second,
        );

        dateTime = dateTime.toLocal();
      }

      String formatted = DateFormat(outputFormat, 'in_ID').format(dateTime);

      return formatted;
    } catch (e) {
      debugPrint('error formattingDateTime: $e');
      return '-';
    }
  }

  static DateTime parseDateTime(
    String dateTime, {
    String inputFormat = 'yyyy-MM-dd HH:mm:ss',
    bool isUtc = true,
  }) {
    try {
      DateTime formatted = DateFormat(inputFormat, 'in-ID').parse(dateTime);

      // if isUtc = true, convert to local time
      if (isUtc) {
        formatted = DateTime.utc(
          formatted.year,
          formatted.month,
          formatted.day,
          formatted.hour,
          formatted.minute,
          formatted.second,
        );
      }

      return formatted.toLocal();
    } catch (e) {
      debugPrint('error parsingDateTime: $e');
      return DateTime.now();
    }
  }

  static String formatMiliSecondToMinuteSecond(int milliseconds) {
    try {
      final totalSeconds = milliseconds / 1000;
      final minutes = totalSeconds ~/ 60;
      final seconds = totalSeconds % 60;

      final minutesStr = minutes > 0 ? '${minutes}m ' : '';
      final secondsStr = '${seconds.toStringAsFixed(1)}s';

      return '$minutesStr$secondsStr';
    } catch (e) {
      return '-';
    }
  }
}
