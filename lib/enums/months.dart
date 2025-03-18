class Month {
  final String name;
  final int number;

  const Month._(this.name, this.number);

  static const Month JANUARY = Month._('Gennaio', 1);
  static const Month FEBRUARY = Month._('Febbraio', 2);
  static const Month MARCH = Month._('Marzo', 3);
  static const Month APRIL = Month._('Aprile', 4);
  static const Month MAY = Month._('Maggio', 5);
  static const Month JUNE = Month._('Giugno', 6);
  static const Month JULY = Month._('Luglio', 7);
  static const Month AUGUST = Month._('Agosto', 8);
  static const Month SEPTEMBER = Month._('Settembre', 9);
  static const Month OCTOBER = Month._('Ottobre', 10);
  static const Month NOVEMBER = Month._('Novembre', 11);
  static const Month DECEMBER = Month._('Dicembre', 12);

  static const List<Month> values = [
    JANUARY,
    FEBRUARY,
    MARCH,
    APRIL,
    MAY,
    JUNE,
    JULY,
    AUGUST,
    SEPTEMBER,
    OCTOBER,
    NOVEMBER,
    DECEMBER,
  ];

  static Month fromNumber(int number) {
    return values.firstWhere((element) => element.number == number);
  }

  static Month fromName(String name) {
    return values.firstWhere((element) => element.name == name);
  }

  @override
  String toString() {
    return name;
  }

  static Month getCurrentMonth() {
    return fromNumber(DateTime.now().month);
  }
}