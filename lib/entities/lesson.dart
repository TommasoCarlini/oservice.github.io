
import 'dart:collection';

import 'package:googleapis/calendar/v3.dart';
import 'package:oservice/db/firebaseHelper.dart';
import 'package:oservice/entities/collaborator.dart';
import 'package:oservice/entities/entity.dart';
import 'package:oservice/entities/exercise.dart';
import 'package:oservice/entities/location.dart';

class Lesson {
  late String id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  late Location location;
  late List<Exercise> exercises;
  late List<Collaborator> collaborators;
  final int collaboratorsNeeded;
  final bool isInEnglish;
  late String eventId;
  late bool isInCalendar;
  final int numberOfParticipants;
  final String notes;
  final double salary;
  late Entity entity;
  Collaborator? responsible;
  Map<String, int>? payments;

  Lesson({
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.collaboratorsNeeded,
    required this.isInEnglish,
    required this.numberOfParticipants,
    required this.notes,
    required this.salary,
  });

  factory Lesson.fromMap(Map<String, dynamic> data) {
    return Lesson(
      title: data['title'],
      description: data['description'],
      startDate: data['startDate'].toDate(),
      endDate: data['endDate'].toDate(),
      collaboratorsNeeded: data['collaboratorsNeeded'],
      isInEnglish: data['isInEnglish'],
      numberOfParticipants: data['numberOfParticipants'],
      notes: data['notes'],
      salary: data['salary'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'location': location.id,
      'exercises': exercises.map((e) => e.id).toList(),
      'collaborators': collaborators.map((c) => c.id).toList(),
      'collaboratorsNeeded': collaboratorsNeeded,
      'responsible': getResponsibleId(),
      'isInEnglish': isInEnglish,
      'eventId': eventId,
      'isInCalendar': isInCalendar,
      'numberOfParticipants': numberOfParticipants,
      'notes': notes,
      'salary': salary,
      'entity': entity.id,
      'payments': getPayments(),
      'registered': getPayments().isEmpty ? false : true,
    };
  }

  String? getResponsibleId() {
    try {
      return responsible?.id;
    }
    catch(e) {
      return null;
    }
  }

  Map<String, int> getPayments() {
    Map<String, int> paymentsMap = {};
    payments?.forEach((key, value) {
      paymentsMap[key] = value.toInt();
    });
    return paymentsMap;
  }

  void addId(String id) {
    try {
      this.id = id;
    } on Exception catch (e) {
      print("Errore durante l'aggiunta dell'ID: $e");
    }
  }

  void addEventId(eventId) {
    try {
      this.eventId = eventId;
    } on Exception catch (e) {
      print("Errore durante l'aggiunta dell'id evento: $e");
    }
  }


  void addEntity(Entity entity) {
    try {
      this.entity = entity;
    } on Exception catch (e) {
      print("Errore durante l'aggiunta dell'entità: $e");
    }
  }

  void addLocation(Location location) {
    try {
      this.location = location;
    } on Exception catch (e) {
      print("Errore durante l'aggiunta della location: $e");
    }
  }

  void addExercise(Exercise exercise) {
    try {
      exercises.add(exercise);
    } on Exception catch (e) {
      print("Errore durante l'aggiunta dell'esercizio: $e");
    }
  }

  void populateCollaborators(List<Collaborator> collaborators) {
    try {
      this.collaborators = collaborators;
    } on Exception catch (e) {
      print("Errore durante il popolamento dei collaboratori: $e");
    }
  }

  void addCollaborator(Collaborator collaborator) {
    try {
      collaborators ??= [];
      collaborators.add(collaborator);
    } on Exception catch (e) {
      print("Errore durante l'aggiunta del collaboratore: $e");
    }
  }

  void addResponsible(Collaborator collaborator) {
    try {
      responsible = collaborator;
    } on Exception catch (e) {
      print("Errore durante l'aggiunta del responsabile: $e");
    }
  }

  void addPayment(String collaborator, int amount) {
    try {
      payments ??= LinkedHashMap();
      payments![collaborator] = amount;
    } on Exception catch (e) {
      print("Errore durante l'aggiunta del pagamento: $e");
    }
  }

  void removePayment(String collaborator) {
    try {
      payments?.remove(collaborator);
    } on Exception catch (e) {
      print("Errore durante la rimozione del pagamento: $e");
    }
  }

  void removeCollaborator(Collaborator collaborator) {
    try {
      collaborators.remove(collaborator);
    } on Exception catch (e) {
      print("Errore durante la rimozione del collaboratore: $e");
    }
  }

  void removeExercise(Exercise exercise) {
    try {
      exercises.remove(exercise);
    } on Exception catch (e) {
      print("Errore durante la rimozione dell'esercizio: $e");
    }
  }

  Future<Event> mapToEvent() async {
    EventDateTime start = EventDateTime()..dateTime = startDate;
    EventDateTime end = EventDateTime()..dateTime = endDate;
    EventReminders reminders = await FirebaseHelper.getEventReminders();
    String prefix = isIncomplete() ? "❌" : "✔";
    return Event()
      ..summary = "$prefix ${entity.name} - $title"
      ..description = createDescription()
      ..start = start
      ..end = end
      ..location = location.href
      ..reminders = reminders
      ..attendees = collaborators.map((c) {
        return EventAttendee()..email = c.mail;
      }).toList() as List<EventAttendee>?
    ;
  }

  String createDescription() {
    return "${buildReferenceText()}"
    "${buildCollaboratorsText()}"
    "${buildExercisesText()}"
    "${buildParticipantsText()}"
    "${buildNotesText()}"
    ;
  }

  String buildReferenceText() {
    if (entity.referee.name.isEmpty) {
      return "";
    }
    return "Referente: ${entity.referee.name} - ${entity.referee.phone}\n\n";
  }

  String buildCollaboratorsText() {
    try {
      if (collaborators.isEmpty) {
        return "";
      }
      if (collaborators.length == 1) {
        return "Collaboratore:\n - ${collaborators.first.name}\n\n";
      }
      if (responsible != null) {
        List<Collaborator> collaboratorsTemp = collaborators.toList();
        collaboratorsTemp.removeWhere((element) => element.name == responsible?.name);
        return "Collaboratori:\n - ${responsible?.name} (Resp.),\n - ${collaboratorsTemp.map((e) => e.name).join(",\n - ")}\n\n";
      } else {
        return "Collaboratori:\n - ${collaborators.map((e) => e.name).join(",\n - ")}\n\n";
      }
    }
    catch (e) {
      return "Collaboratori:\n - ${collaborators.map((e) => e.name).join(",\n - ")}\n\n";
    }
  }

  String buildExercisesText() {
    if (exercises.isEmpty) {
      return "";
    }
    return "Esercizi:\n - ${exercises.map((e) => e.title).join(",\n - ")}\n\n";
  }

  String buildParticipantsText() {
    if (numberOfParticipants == 1) {
      return "1 partecipante";
    }
    return "${numberOfParticipants} partecipanti\n\n";
  }

  String buildNotesText() {
    if (notes.isEmpty) {
      return "";
    }
    return "Note:\n$notes";
  }

  bool isIncomplete() {
    return collaboratorsNeeded > collaborators.length;
  }

  bool isRegistered() {
    return getPayments().isNotEmpty;
  }
}