import 'package:googleapis/calendar/v3.dart';
import 'package:oservice/entities/lesson.dart';
import 'package:oservice/entities/location.dart';
import 'package:oservice/entities/person.dart';
import 'package:oservice/enums/entityType.dart';

class Entity {
  late String id;
  late String calendarId;
  final String name;
  final String color;
  final Person owner;
  final Person referee;
  final Person secretary;
  late List<Lesson> lessons;
  final EntityType type;
  late Location location;

  Entity({
    required this.name,
    required this.color,
    required this.owner,
    required this.referee,
    required this.secretary,
    required this.lessons,
    required this.type,
  });

  factory Entity.fromMap(Map<String, dynamic> data) {
    return Entity(
      name: data['name'],
      color: data['color'],
      owner: Person.fromMap(data['owner']),
      referee: Person.fromMap(data['referee']),
      secretary: Person.fromMap(data['secretary']),
      lessons: List<Lesson>.from(data['lessons']),
      type: EntityType.fromString(data['type']),
    );
  }

  toMap() {
    return {
      'calendarId': calendarId,
      'name': name,
      'color': color,
      'owner': owner.toMap(),
      'referee': referee.toMap(),
      'secretary': secretary.toMap(),
      'lessons': lessons.map((lesson) => lesson.toMap()).toList(),
      'type': type.type,
      'location': location.id,
    };
  }

  void addId(String id) {
    try {
      this.id = id;
    } on Exception catch (e) {
      print("Errore durante l'aggiunta dell'ID: $e");
    }
  }

  void addLocation(Location location) {
    try {
      this.location = location;
    } on Exception catch (e) {
      print("Errore durante l'aggiunta della location: $e");
    }
  }

  void addLesson(Lesson lesson) {
    try {
      lessons.add(lesson);
    } on Exception catch (e) {
      print("Errore durante l'aggiunta della lezione: $e");
    }
  }

  void removeLesson(Lesson lesson) {
    try {
      lessons.remove(lesson);
    } on Exception catch (e) {
      print("Errore durante la rimozione della lezione: $e");
    }
  }

  Calendar mapToCalendar() {
    return Calendar()
    ..summary = name
    ..location = location.href;
  }
}