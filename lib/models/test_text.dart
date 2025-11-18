class TestText {
  final String text;
  final String difficulty;
  final Duration duration;

  TestText({
    required this.text,
    required this.difficulty,
    required this.duration,
  });
}

class MonthLabel {
  final String name;
  final int startWeek;
  final int weekCount;

  MonthLabel(this.name, this.startWeek, this.weekCount);
}

class MonthWeek {
  final String monthName;
  final int weekIndex;
  final int width;

  MonthWeek(this.monthName, this.weekIndex, this.width);
}
