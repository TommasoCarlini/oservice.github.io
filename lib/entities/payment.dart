class Payment {
  late String id;
  final String name;
  final int amount;
  final DateTime date;
  final bool paid;
  final String lessonId;

  Payment({
    required this.name,
    required this.amount,
    required this.date,
    required this.paid,
    required this.lessonId,
  });

  factory Payment.fromMap(Map<String, dynamic> data) {
    return Payment(
      name: data['name'],
      amount: data['amount'],
      date: data['date'].toDate(),
      paid: data['paid'],
      lessonId: data['lessonId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'date': date,
      'paid': paid,
      'lessonId': lessonId,
    };
  }
}