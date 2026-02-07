String formatDateTimeToMinutesSeconds(DateTime dateTime) {
  // Create a Duration from the minute, second, and millisecond parts
  Duration duration = Duration(
    minutes: dateTime.minute,
    seconds: dateTime.second,
    milliseconds: dateTime.millisecond,
  );

  // Format into Xm Ys
  String formatted = '${duration.inMinutes}m ${duration.inSeconds % 60}s';
  return formatted;
}
