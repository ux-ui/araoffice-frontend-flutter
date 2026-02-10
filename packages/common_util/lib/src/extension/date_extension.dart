import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String toFormattedString({
    String format = 'yyyy-MM-dd HH:mm:ss',
    String? local,
  }) {
    return DateFormat(format, local).format(this);
  }

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  int get weekOfMonth {
    final firstDayOfMonth = DateTime(year, month, 1);
    final firstWeekDay = 7 - firstDayOfMonth.weekday + 1;
    final diff = day - firstWeekDay;
    return (diff / 7).ceil() + 1;
  }
}
