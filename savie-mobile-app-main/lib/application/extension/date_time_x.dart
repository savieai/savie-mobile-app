extension DateTimeX on DateTime {
  DateTime get toDate => DateTime(year, month, day).copyWith(isUtc: false);

  bool get isToday {
    final DateTime now = DateTime.now();
    return DateTime(year, month, day) == DateTime(now.year, now.month, now.day);
  }

  bool get isYesterday {
    final DateTime yesterday = DateTime.now().subtract(const Duration(days: 1));
    return DateTime(year, month, day) ==
        DateTime(yesterday.year, yesterday.month, yesterday.day);
  }

  bool get isThisYear {
    final DateTime now = DateTime.now();
    return year == now.year;
  }
}
