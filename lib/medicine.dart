class Medicine {
  String name;
  List<bool> days;
  String dosage;
  String time;
  final List<String> dayLetters = ["S", "M", "T", "W", "T", "F", "S"];

  Medicine({
    required this.name,
    required this.days,
    required this.dosage,
    required this.time,
  });
}

