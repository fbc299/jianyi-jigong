class AppDateUtils {
  static String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static String formatMonth(DateTime date) {
    return '${date.year}年${date.month}月';
  }

  static String formatWeekday(DateTime date) {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return '周${weekdays[date.weekday - 1]}';
  }

  static DateTime startOfMonth(int year, int month) {
    return DateTime(year, month, 1);
  }

  static DateTime endOfMonth(int year, int month) {
    return DateTime(year, month + 1, 0);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
}
