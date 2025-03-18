import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/lesson.dart';
import 'package:oservice/entities/person.dart';

class Collaborator extends Person {
  late String id;
  final List<Lesson> availabilities;
  final List<Map<String, double>> payments;
  final bool englishSpeaker;

  Collaborator({
    required super.name,
    required super.mail,
    required super.phone,
    required super.nickname,
    required this.availabilities,
    required this.payments,
    required this.englishSpeaker,
  });

  void addAvailability(Lesson lesson) {
    availabilities ?? [];
    availabilities.add(lesson);
  }

  void removeAvailability(Lesson lesson) {
    availabilities.remove(lesson);
  }

  static Future<Collaborator> fromMap(Map<String, dynamic> map) async {
    List<Map<String, double>> payments = [];
    try {
      for (var payment in map['payments']) {
        payments.add(payment);
      }
    } on Exception catch (e) {
      print("Errore durante la creazione dei pagamenti: $e");
    }
    List<Lesson> availabilities = [];
    try {
      for (var availability in map['availabilities']) {
        availabilities.add(Lesson.fromMap(availability));
      }
    } on Exception catch (e) {
      print("Errore durante la creazione delle disponibilità: $e");
    }
    return Collaborator(
      name: map['name'],
      mail: map['mail'],
      phone: map['phone'],
      nickname: map['nickname'] ?? map['name'],
      payments: payments,
      englishSpeaker: map['englishSpeaker'],
      availabilities: availabilities,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mail': mail.trim(),
      'phone': phone.trim(),
      'nickname': nickname,
      // 'lessons': lessons.map((lesson) => lesson.id).toList(),
      'payments': payments,
      'englishSpeaker': englishSpeaker,
      'availabilities': availabilities,
    };
  }

  String toString() {
    return 'Collaborator: $name';
  }
}
