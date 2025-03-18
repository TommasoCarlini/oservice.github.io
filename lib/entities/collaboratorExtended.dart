import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/collaborator.dart';
import 'package:oservice/entities/lesson.dart';

class CollaboratorExtended extends Collaborator {
  List<String>? lessons;

  CollaboratorExtended({
    required super.name,
    required super.mail,
    required super.phone,
    required super.nickname,
    required super.availabilities,
    required super.payments,
    required super.englishSpeaker,
  });

  static Future<CollaboratorExtended> fromMap(Map<String, dynamic> map) async {
    List<Lesson> lessons = [];

    try {
      for (var lessonId in map['lessons']) {
        Lesson lesson = await FirebaseHelper.getLessonById(lessonId);
        lessons.add(lesson);
      }
    } on Exception catch (e) {
      print("Errore durante la creazione delle lezioni: $e");
    }

    List<Map<String, double>> payments = [];
    try {
      payments ?? [];
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
    return CollaboratorExtended(
      name: map['name'],
      mail: map['mail'],
      phone: map['phone'],
      nickname: map['nickname'],
      availabilities: availabilities,
      payments: payments,
      englishSpeaker: map['englishSpeaker'],
    );
  }

  @override
  String toString() {
    return 'CollaboratorExtended{name: $name, mail: $mail, phone: $phone, nickname: $nickname, availabilities: $availabilities, payments: $payments, englishSpeaker: $englishSpeaker, lessons: $lessons}';
  }

  static Future<CollaboratorExtended> fromCollaborator(
      Collaborator collaborator) async {
    List<Lesson> lessons = [];

    // try {
    //   for (var lessonId in collaborator.lessons) {
    //     Lesson lesson = await FirebaseHelper.getLessonById(lessonId);
    //     lessons.add(lesson);
    //   }
    // } on Exception catch (e) {
    //   print("Errore durante la creazione delle lezioni: $e");
    // }

    return CollaboratorExtended(
      name: collaborator.name,
      mail: collaborator.mail,
      phone: collaborator.phone,
      nickname: collaborator.nickname,
      availabilities: collaborator.availabilities,
      payments: collaborator.payments,
      englishSpeaker: collaborator.englishSpeaker,
    );
  }

  void addLesson(String lessonId) {
    lessons ??= [];
    lessons!.add(lessonId);
  }

  void removeLesson(String lessonId) {
    lessons!.remove(lessonId);
  }
}
