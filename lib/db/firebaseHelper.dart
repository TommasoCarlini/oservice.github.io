import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:oservice/constants/dbConstants.dart';
import 'package:oservice/entities/collaborator.dart';
import 'package:oservice/entities/collaboratorExtended.dart';
import 'package:oservice/entities/entity.dart';
import 'package:oservice/entities/exercise.dart';
import 'package:oservice/entities/lesson.dart';
import 'package:oservice/entities/payment.dart';
import 'package:oservice/entities/taxinfo.dart';
import 'package:oservice/utils/responseHandler.dart';
import 'package:oservice/entities/location.dart';

class FirebaseHelper {
  FirebaseHelper.initialize() {
    Firebase.initializeApp();
  }

  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static Future<List<Collaborator>> getAllCollaborators() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.COLLABORATORS);
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await collection.get();
    List<Collaborator> collaborators = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot
    in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        Collaborator collaborator = await Collaborator.fromMap(data)
          ..id = queryDocumentSnapshot.id;
        collaborators.add(collaborator);
      } on Exception catch (e) {
        print("Error: $e");
      }
    }
    return collaborators;
  }

  static Future<List<Entity>> getAllEntities() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.ENTITIES);
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await collection.get();
    List<Entity> entities = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot
    in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        Entity entity = Entity.fromMap(data)
          ..id = queryDocumentSnapshot.id
          ..calendarId = data['calendarId']
          ..location = await getLocationById(data['location']);
        entities.add(entity);
      } on Exception catch (e) {
        print("Error: $e");
      }
    }
    return entities;
  }

  static Future<List<Entity>> getEntitiesByField(String id,
      String field) async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.ENTITIES);
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await collection.where(field, isEqualTo: id).get();
    List<Entity> entities = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot
    in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        Entity entity = Entity.fromMap(data)
          ..id = queryDocumentSnapshot.id
          ..calendarId = data['calendarId']
          ..location = await getLocationById(data['location']);
        entities.add(entity);
      } on Exception catch (e) {
        print("Error: $e");
      }
    }
    return entities;
  }

  static Future<List<Location>> getAllLocations() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.LOCATIONS);
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await collection.get();
    List<Location> locations = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot
    in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        Location location = Location.fromMap(data)
          ..id = queryDocumentSnapshot.id;
        locations.add(location);
      } on Exception catch (e) {
        print("Error: $e");
      }
    }
    return locations;
  }

  static Future<List<Lesson>> getAllLessons() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.LESSONS);
    int daysBefore = await getNumberOfDaysBeforeToBeVisualized();
    Timestamp today = Timestamp.fromDate(DateTime(DateTime
        .now()
        .year,
        DateTime
            .now()
            .month, DateTime
            .now()
            .day - daysBefore));
    Timestamp oneWeekFromNow =
    Timestamp.fromDate(DateTime.now().add(Duration(days: 7)));
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await collection
        .where('endDate', isGreaterThanOrEqualTo: today)
        .where("startDate", isLessThanOrEqualTo: oneWeekFromNow)
        .orderBy("startDate")
        .get();
    List<Lesson> lessons = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot
    in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        Lesson lesson = Lesson.fromMap(data)
          ..collaborators = []
          ..isInCalendar = data['isInCalendar']
          ..payments = Map<String, int>.from(data['payments']);
        lesson.addId(queryDocumentSnapshot.id);
        lesson.addEventId(data['eventId']);
        lesson.addLocation(await getLocationById(data['location']));
        lesson.addEntity(await getEntityById(data['entity']));
        lesson.collaborators = await populateCollaborators(data);
        if (data['responsible'] != null) {
          lesson.addResponsible(await getCollaboratorById(data['responsible']));
        }
        lesson.exercises = await populateExercises(data);
        lessons.add(lesson);
      } on Exception catch (e) {
        print("Error: $e");
      }
    }
    return lessons;
  }

  static Future<List<Lesson>> getAllPastLessons() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.LESSONS);
    int daysBefore = await getNumberOfDaysBeforeToBeVisualizedInArchive();
    Timestamp today = Timestamp.fromDate(DateTime(
        DateTime
            .now()
            .year, DateTime
        .now()
        .month, DateTime
        .now()
        .day));
    Timestamp targetDay = Timestamp.fromDate(DateTime(DateTime
        .now()
        .year,
        DateTime
            .now()
            .month, DateTime
            .now()
            .day - daysBefore));
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await collection
        .where("startDate", isLessThan: today)
        .where("endDate", isGreaterThanOrEqualTo: targetDay)
        .orderBy("startDate", descending: true)
        .get();
    List<Lesson> lessons = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot
    in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        Lesson lesson = Lesson.fromMap(data)
          ..id = queryDocumentSnapshot.id
          ..collaborators = []
          ..isInCalendar = data['isInCalendar']
          ..payments = Map<String, int>.from(data['payments']);
        lesson.addId(queryDocumentSnapshot.id);
        lesson.addEventId(data['eventId']);
        lesson.addLocation(await getLocationById(data['location']));
        lesson.addEntity(await getEntityById(data['entity']));
        lesson.collaborators = await populateCollaborators(data);
        if (data['responsible'] != null) {
          lesson.addResponsible(await getCollaboratorById(data['responsible']));
        }
        lesson.exercises = await populateExercises(data);
        lessons.add(lesson);
      } on Exception catch (e) {
        print("Error: $e");
      }
    }
    return lessons;
  }

  static Future<List<Lesson>> getAllUnpaidLessons() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.LESSONS);
    Timestamp today = Timestamp.fromDate(DateTime(
        DateTime
            .now()
            .year, DateTime
        .now()
        .month, DateTime
        .now()
        .day));
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await collection
        .where("startDate", isLessThan: today)
        .where("registered", isEqualTo: false)
        .orderBy("startDate", descending: true)
        .get();
    List<Lesson> lessons = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot
    in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        Lesson lesson = Lesson.fromMap(data)
          ..id = queryDocumentSnapshot.id
          ..collaborators = []
          ..isInCalendar = data['isInCalendar']
          ..payments = Map<String, int>.from(data['payments']);
        lesson.addId(queryDocumentSnapshot.id);
        lesson.addEventId(data['eventId']);
        lesson.addLocation(await getLocationById(data['location']));
        lesson.addEntity(await getEntityById(data['entity']));
        lesson.collaborators = await populateCollaborators(data);
        if (data['responsible'] != null) {
          lesson.addResponsible(await getCollaboratorById(data['responsible']));
        }
        lesson.exercises = await populateExercises(data);
        lessons.add(lesson);
      } on Exception catch (e) {
        print("Error: $e");
      }
    }
    return lessons;
  }

  static Future<List<Lesson>> getLessonsByField(String id, String field) async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.LESSONS);
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
    await collection.where(field, isEqualTo: id).get();
    List<Lesson> lessons = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot
    in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        Lesson lesson = Lesson.fromMap(data)
          ..collaborators = []
          ..isInCalendar = data['isInCalendar']
          ..payments = Map<String, int>.from(data['payments']);
        lesson.addId(queryDocumentSnapshot.id);
        lesson.addEventId(data['eventId']);
        lesson.addLocation(await getLocationById(data['location']));
        lesson.addEntity(await getEntityById(data['entity']));
        lesson.collaborators = await populateCollaborators(data);
        if (data['responsible'] != null) {
          lesson.addResponsible(await getCollaboratorById(data['responsible']));
        }
        lesson.exercises = await populateExercises(data);
        lessons.add(lesson);
      } on Exception catch (e) {
        print("Error: $e");
      }
    }
    return lessons;
  }

  static Future<List<Lesson>> getAllIncompleteLessons() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.LESSONS);
    Timestamp today = Timestamp.fromDate(DateTime(
        DateTime
            .now()
            .year, DateTime
        .now()
        .month, DateTime
        .now()
        .day));
    Timestamp oneWeekFromNow =
    Timestamp.fromDate(DateTime.now().add(Duration(days: 7)));
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await collection
        .where('endDate', isGreaterThanOrEqualTo: today)
        .where("startDate", isLessThanOrEqualTo: oneWeekFromNow)
        .orderBy("startDate")
        .get();
    List<Lesson> lessons = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot
    in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        Lesson lesson = Lesson.fromMap(data)
          ..collaborators = []
          ..isInCalendar = data['isInCalendar']
          ..payments = Map<String, int>.from(data['payments']);
        lesson.addId(queryDocumentSnapshot.id);
        lesson.addEventId(data['eventId']);
        lesson.addLocation(await getLocationById(data['location']));
        lesson.addEntity(await getEntityById(data['entity']));
        lesson.collaborators = await populateCollaborators(data);
        if (data['responsible'] != null) {
          lesson.addResponsible(await getCollaboratorById(data['responsible']));
        }
        lesson.exercises = await populateExercises(data);
        lessons.add(lesson);
      } on Exception catch (e) {
        print("Error: $e");
      }
    }
    return lessons;
  }

  static Future<List<Exercise>> getAllExercises() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.EXERCISES);
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await collection.get();
    List<Exercise> exercises = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot
    in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        Exercise exercise = Exercise.fromMap(data)
          ..id = queryDocumentSnapshot.id;
        exercises.add(exercise);
      } on Exception catch (e) {
        print("Error: $e");
      }
    }
    return exercises;
  }

  Future<Result<String>> addExercise(Exercise exercise) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.EXERCISES);
      await collection.add(exercise.toMap());
      return Success(data: exercise.title);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  Future<Result<String>> addCollaborator(Collaborator collaborator) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.COLLABORATORS);
      DocumentReference<
          Map<String, dynamic>> documentReference = await collection.add(
          collaborator.toMap());
      return Success(data: documentReference.id);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  Future<Result<String>> addEntity(Entity entity) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.ENTITIES);
      await collection.add(entity.toMap());
      return Success(data: entity.name);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  Future<Result<String>> updateEntity(Entity entity) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.ENTITIES);
      await collection.doc(entity.id).update(entity.toMap());
      return Success(data: entity.name);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  Future<Result<String>> addLesson(Lesson lesson) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.LESSONS);
      DocumentReference<Map<String, dynamic>> documentReference =
      await collection.add(lesson.toMap());
      return Success(data: documentReference.id);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  Future<Result<String>> addTaxInfo(TaxInfo taxInfo) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.TAX_INFO);
      DocumentReference<Map<String, dynamic>> documentReference =
      await collection.add(taxInfo.toMap());
      return Success(data: documentReference.id);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  Future<Result<String>> updateLesson(Lesson lesson) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.LESSONS);
      await collection.doc(lesson.id).update(lesson.toMap());
      return Success(data: lesson.id);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  Future<Result<String>> addLocation(Location location) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.LOCATIONS);
      DocumentReference<Map<String, dynamic>> documentReference =
      await collection.add(location.toMap());
      return Success(data: documentReference.id);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  Future<Result<String>> updateLocation(Location location) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.LOCATIONS);
      await collection.doc(location.id).update(location.toMap());
      return Success(data: location.id);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  Future<Result<String>> saveLesson(Lesson lesson) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SAVED_COLLECTIONS);
      await collection.doc(DbConstants.SAVED_LESSON).update(lesson.toMap());
      return Success(data: DbConstants.SAVED_LESSON);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<Location> getLocationById(String id) {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.LOCATIONS);
    return collection
        .doc(id)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return Location.fromMap(data)
        ..id = id;
    });
  }

  static Future<Entity> getEntityById(String id) {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.ENTITIES);
    return collection
        .doc(id)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return Entity.fromMap(data)
        ..location = await getLocationById(data['location'])
        ..id = id
        ..calendarId = data['calendarId'];
    });
  }

  static Future<Exercise> getExerciseById(String id) {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.EXERCISES);
    return collection
        .doc(id)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return Exercise.fromMap(data)
        ..id = id;
    });
  }

  static Future<Collaborator> getCollaboratorById(String id) {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.COLLABORATORS);
    return collection
        .doc(id)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return await Collaborator.fromMap(data)
        ..id = id;
    });
  }

  static Future<CollaboratorExtended> getCollaboratorExtendedById(String id) {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.COLLABORATORS);
    return collection
        .doc(id)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return await CollaboratorExtended.fromMap(data)
        ..id = id
        ..lessons = populateLessons(data['lessons']);
    });
  }

  static Future<TaxInfo> getTaxInfoById(String id) {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.TAX_INFO);
    return collection
        .doc(id)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return TaxInfo.fromMap(data)
        ..id = id;
    });
  }

  static Future<TaxInfo?> getTaxInfoByCollaboratorId(
      String collaboratorId) async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.TAX_INFO);
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await collection
        .where("collaboratorId", isEqualTo: collaboratorId)
        .get();
    if (querySnapshot.docs.isEmpty) {
      return null;
    }
    QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot =
        querySnapshot.docs.first;
    Map<String, dynamic> data = queryDocumentSnapshot.data();
    return TaxInfo.fromMap(data)
      ..id = queryDocumentSnapshot.id;
  }

  static List<String> populateLessons(List<dynamic> lessons) {
    List<String> lessonsList = [];
    for (String lesson in lessons) {
      lessonsList.add(lesson);
    }
    return lessonsList;
  }

  static Future<Lesson> getLessonById(String id) {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.LESSONS);
    return collection
        .doc(id)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      Lesson lesson = Lesson.fromMap(data)
        ..collaborators = [];
      lesson.addId(id);
      lesson.addLocation(await getLocationById(data['location']));
      lesson.addEntity(await getEntityById(data['entity']));
      lesson.collaborators = await populateCollaborators(data);
      lesson.exercises = await populateExercises(data);
      lesson.eventId = data['eventId'];
      lesson.isInCalendar = data['isInCalendar'];
      if (data['responsible'] != null) {
        lesson.addResponsible(await getCollaboratorById(data['responsible']));
      }
      return lesson;
    });
  }

  static Future<Lesson> getSavedLesson() {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.SAVED_LESSON)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      Lesson lesson = Lesson.fromMap(data)
        ..collaborators = [];
      lesson.addId("");
      lesson.addLocation(await getLocationById(data['location']));
      lesson.addEntity(await getEntityById(data['entity']));
      lesson.collaborators = await populateCollaborators(data);
      lesson.eventId = data['eventId'];
      lesson.isInCalendar = data['isInCalendar'];
      lesson.exercises = await populateExercises(data);
      if (data['responsible'] != null) {
        lesson.addResponsible(await getCollaboratorById(data['responsible']));
      } else {
        lesson.responsible = null;
      }
      return lesson;
    });
  }

  static Future<Result<String>> deleteLesson(String id) async {
    try {
      await db.collection(DbConstants.LESSONS).doc(id).delete();
      return Success(data: id);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<Result<String>> deleteEntity(String id) async {
    try {
      await db.collection(DbConstants.ENTITIES).doc(id).delete();
      return Success(data: id);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<Result<String>> deleteCollaborator(String id) async {
    try {
      await db.collection(DbConstants.COLLABORATORS).doc(id).delete();
      return Success(data: id);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<Result<String>> deleteLocation(String id) async {
    try {
      await db.collection(DbConstants.LOCATIONS).doc(id).delete();
      return Success(data: id);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<Result<String>> deleteExercise(String id) async {
    try {
      await db.collection(DbConstants.EXERCISES).doc(id).delete();
      return Success(data: id);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<Result<String>> deletePayment(String id) async {
    try {
      await db.collection(DbConstants.PAYMENTS).doc(id).delete();
      return Success(data: id);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<List<Collaborator>> populateCollaborators(
      Map<String, dynamic> data) async {
    List<Collaborator> collaborators = [];
    if (data["collaborators"] == null) {
      return collaborators;
    }
    for (String id in data["collaborators"]) {
      Collaborator collaborator = await getCollaboratorById(id);
      collaborators.add(collaborator);
    }
    return collaborators;
  }

  static Future<List<Exercise>> populateExercises(
      Map<String, dynamic> data) async {
    List<Exercise> exercises = [];
    if (data["exercises"] == null) {
      return exercises;
    }
    for (String id in data["exercises"]) {
      Exercise exercise = await getExerciseById(id);
      exercises.add(exercise);
    }
    return exercises;
  }

  static updateCollaboratorsLesson(List<Collaborator> chosenCollaborators,
      String lessonId) async {
    for (Collaborator collaborator in chosenCollaborators) {
      CollaboratorExtended collaboratorExtended =
      await CollaboratorExtended.fromCollaborator(collaborator);
      collaboratorExtended.addLesson(lessonId);
      db.collection(DbConstants.COLLABORATORS).doc(collaborator.id).update({
        "lessons":
        collaboratorExtended.lessons!.map((lesson) => lessonId).toList(),
      });
    }
  }

  static removeCollaboratorsLesson(List<Collaborator> chosenCollaborators,
      String lessonId) async {
    for (Collaborator collaborator in chosenCollaborators) {
      CollaboratorExtended collaboratorExtended =
      await FirebaseHelper.getCollaboratorExtendedById(collaborator.id);
      try {
        collaboratorExtended.removeLesson(lessonId);
        db.collection(DbConstants.COLLABORATORS).doc(collaborator.id).update({
          "lessons":
          collaboratorExtended.lessons!.map((lesson) => lessonId).toList(),
        });
      } on Exception catch (e) {
        print("Errore durante la rimozione della lezione: $e");
      }
    }
  }

  static Future<Result<String>> setIsLessonSaved(bool value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SAVED_COLLECTIONS);
      await collection
          .doc(DbConstants.IS_SAVED_LESSON)
          .update({"value": value});
      return Success(data: value.toString());
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<bool> getIsLessonSaved() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.IS_SAVED_LESSON)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["value"];
    });
  }

  static Future<Result<String>> setIsLessonEditing(bool value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SAVED_COLLECTIONS);
      await collection.doc(DbConstants.EDIT_LESSON).update({"value": value});
      return Success(data: value.toString());
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<bool> getIsLessonEditing() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.EDIT_LESSON)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["value"];
    });
  }

  static Future<Result<String>> setIsCollaboratorSaved(bool value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SAVED_COLLECTIONS);
      await collection
          .doc(DbConstants.EDIT_COLLABORATOR)
          .update({"value": value});
      return Success(data: value.toString());
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<bool> getIsCollaboratorSaved() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.EDIT_COLLABORATOR)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["value"];
    });
  }

  static Future<Result<String>> setIsExerciseSaved(bool value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SAVED_COLLECTIONS);
      await collection.doc(DbConstants.EDIT_EXERCISE).update({"value": value});
      return Success(data: value.toString());
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<bool> getIsExerciseSaved() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.EDIT_EXERCISE)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["value"];
    });
  }

  static Future<Result<String>> setIsLocationSaved(bool value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SAVED_COLLECTIONS);
      await collection.doc(DbConstants.EDIT_LOCATION).update({"value": value});
      return Success(data: value.toString());
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<bool> getIsLocationSaved() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.EDIT_LOCATION)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["value"];
    });
  }

  static Future<Result<String>> setIsEntitySaved(bool value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SAVED_COLLECTIONS);
      await collection.doc(DbConstants.EDIT_ENTITY).update({"value": value});
      return Success(data: value.toString());
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<bool> getIsEntitySaved() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.EDIT_ENTITY)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["value"];
    });
  }

  static Future<bool> getIsEditLessonMode() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.EDIT_LESSON)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["value"];
    });
  }

  static Future<Result<String>> setIdSavedLesson(String value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SAVED_COLLECTIONS);
      await collection.doc(DbConstants.EDIT_LESSON).update({"id": value});
      return Success(data: value);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<String> getIdSavedLesson() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.EDIT_LESSON)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["id"];
    });
  }

  static Future<bool> getIsEditCollaboratorMode() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.EDIT_COLLABORATOR)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["value"];
    });
  }

  static Future<Result<String>> setIdSavedCollaborator(String value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SAVED_COLLECTIONS);
      await collection.doc(DbConstants.EDIT_COLLABORATOR).update({"id": value});
      return Success(data: value);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<String> getIdSavedCollaborator() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.EDIT_COLLABORATOR)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["id"];
    });
  }

  static Future<bool> getIsEditExerciseMode() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.EDIT_EXERCISE)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["value"];
    });
  }

  static Future<Result<String>> setIdSavedExercise(String value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SAVED_COLLECTIONS);
      await collection.doc(DbConstants.EDIT_EXERCISE).update({"id": value});
      return Success(data: value);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<String> getIdSavedExercise() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.EDIT_EXERCISE)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["id"];
    });
  }

  static Future<bool> getIsEditLocationMode() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.EDIT_LOCATION)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["value"];
    });
  }

  static Future<Result<String>> setIdSavedLocation(String value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SAVED_COLLECTIONS);
      await collection.doc(DbConstants.EDIT_LOCATION).update({"id": value});
      return Success(data: value);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<String> getIdSavedLocation() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.EDIT_LOCATION)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["id"];
    });
  }

  static Future<bool> getIsEditEntityMode() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.EDIT_ENTITY)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["value"];
    });
  }

  static Future<Result<String>> setIdSavedEntity(String value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SAVED_COLLECTIONS);
      await collection.doc(DbConstants.EDIT_ENTITY).update({"id": value});
      return Success(data: value);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<String> getIdSavedEntity() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.EDIT_ENTITY)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["id"];
    });
  }

  static Future<String> getEventIdSavedLesson() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.SAVED_LESSON)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["eventId"];
    });
  }

  static Future<int> getNumberOfDaysBeforeToBeVisualized() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SETTINGS);
    return collection
        .doc(DbConstants.DAYS_BEFORE)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return int.parse(data["value"].toString());
    });
  }

  static Future<int> getNumberOfDaysBeforeToBeVisualizedInArchive() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SETTINGS);
    return collection
        .doc(DbConstants.DAYS_BEFORE)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return int.parse(data["archiveValue"].toString());
    });
  }

  static Future<bool> getNewEventNotification() {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SETTINGS);
    return collection
        .doc(DbConstants.NEW_EVENT_NOTIFICATION)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["value"];
    });
  }

  static Future<bool> getDeletedEventNotification() {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SETTINGS);
    return collection
        .doc(DbConstants.DELETED_EVENT_NOTIFICATION)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["value"];
    });
  }

  static Future<calendar.EventReminders> getEventReminders() {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SETTINGS);
    return collection
        .doc(DbConstants.EVENT_REMINDERS)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      List<calendar.EventReminder> eventReminderList = [];
      for (int hour in data["value"]) {
        calendar.EventReminder eventReminder = calendar.EventReminder()
          ..method = 'email'
          ..minutes = 60 * hour;
        eventReminderList.add(eventReminder);
      }
      calendar.EventReminders eventReminders = calendar.EventReminders()
        ..overrides = eventReminderList
        ..useDefault = false;
      return eventReminders;
    });
  }

  static Future<Result<String>> setEventReminders(List<int> reminders) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SETTINGS);
      await collection
          .doc(DbConstants.EVENT_REMINDERS)
          .update({"value": reminders});
      return Success(data: reminders.toString());
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<Result<String>> setNewEventNotification(bool value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SETTINGS);
      await collection
          .doc(DbConstants.NEW_EVENT_NOTIFICATION)
          .update({"value": value});
      return Success(data: value.toString());
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<Result<String>> setDeletedEventNotification(bool value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SETTINGS);
      await collection
          .doc(DbConstants.DELETED_EVENT_NOTIFICATION)
          .update({"value": value});
      return Success(data: value.toString());
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<Result<String>> setNumberOfDaysBeforeToBeVisualized(
      int value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SETTINGS);
      await collection.doc(DbConstants.DAYS_BEFORE).update({"value": value});
      return Success(data: value.toString());
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<Result<String>> setNumberOfDaysBeforeToBeVisualizedInArchive(
      int value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SETTINGS);
      await collection
          .doc(DbConstants.DAYS_BEFORE)
          .update({"archiveValue": value});
      return Success(data: value.toString());
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<Result<String>> setDefaultPayrate(String value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SETTINGS);
      await collection
          .doc(DbConstants.PAYRATE_DEFAULT)
          .update({"value": value});
      return Success(data: value);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<Result<String>> setIdRegisteredLesson(String value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SAVED_COLLECTIONS);
      await collection.doc(DbConstants.REGISTERED_LESSON).update({"id": value});
      return Success(data: value);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<String> getIdRegisteredLesson() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.REGISTERED_LESSON)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["id"];
    });
  }

  static Future<String> getDefaultPayrate() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SETTINGS);
    return collection
        .doc(DbConstants.PAYRATE_DEFAULT)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["value"];
    });
  }

  static String getYearAndMonth() {
    DateTime now = DateTime.now();
    return "${now.year} ${now.month}";
  }

  static Future<String> addPayment(Map<String, dynamic> payment) async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.PAYMENTS);
    DocumentReference<Map<String, dynamic>> documentReference =
    await collection.add(payment);
    return documentReference.id;
  }

  static Future<Result<String>> updatePayment(Payment payment) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.PAYMENTS);
      await collection.doc(payment.id).update(payment.toMap());
      return Success(data: payment.id);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }

  static Future<List<Payment>> retrievePayments(int year, int month) async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.PAYMENTS);
    Timestamp firstDay = Timestamp.fromDate(DateTime(year, month, 01));
    Timestamp lastDay = Timestamp.fromDate(DateTime(year, month + 1, 01));
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await collection
        .where("date", isLessThan: lastDay)
        .where("date", isGreaterThanOrEqualTo: firstDay)
        .get();
    List<Payment> payments = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot
    in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        Payment payment = Payment.fromMap(data)
          ..id = queryDocumentSnapshot.id;
        payments.add(payment);
      } on Exception catch (e) {
        print("Error: $e");
      }
    }
    return payments;
  }

  static Future<List<Payment>> retrievePaymentsByCollaborator(int year, int month, String collaboratorName) async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.PAYMENTS);
    Timestamp firstDay = Timestamp.fromDate(DateTime(year, month, 01));
    Timestamp lastDay = Timestamp.fromDate(DateTime(year, month + 1, 01));
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await collection
        .where("date", isLessThan: lastDay)
        .where("date", isGreaterThanOrEqualTo: firstDay)
        .where("name", isEqualTo: collaboratorName)
        .get();
    List<Payment> payments = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot
    in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        Payment payment = Payment.fromMap(data)
          ..id = queryDocumentSnapshot.id;
        payments.add(payment);
      } on Exception catch (e) {
        print("Error: $e");
      }
    }
    return payments;
  }

  static Future<List<Payment>> retrieveYearlyPayments() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.PAYMENTS);
    int year = DateTime
        .now()
        .year;
    Timestamp firstDay = Timestamp.fromDate(DateTime(year, 01, 01));
    Timestamp lastDay = Timestamp.fromDate(DateTime(year, 12, 31));
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await collection
        .where("date", isLessThan: lastDay)
        .where("date", isGreaterThanOrEqualTo: firstDay)
        .get();
    List<Payment> payments = [];
    for (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot
    in querySnapshot.docs) {
      try {
        Map<String, dynamic> data = queryDocumentSnapshot.data();
        Payment payment = Payment.fromMap(data)
          ..id = queryDocumentSnapshot.id;
        payments.add(payment);
      } on Exception catch (e) {
        print("Error: $e");
      }
    }
    return payments;
  }

  static Future<String> getIdSavedTaxInfo() async {
    CollectionReference<Map<String, dynamic>> collection =
    db.collection(DbConstants.SAVED_COLLECTIONS);
    return collection
        .doc(DbConstants.SAVED_TAX_INFO)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) async {
      Map<String, dynamic> data = documentSnapshot.data()!;
      return data["id"];
    });
  }

  static Future<Result<String>> setIdSavedTaxInfo(String value) async {
    try {
      CollectionReference<Map<String, dynamic>> collection =
      db.collection(DbConstants.SAVED_COLLECTIONS);
      await collection.doc(DbConstants.SAVED_TAX_INFO).update({"id": value});
      return Success(data: value);
    } on Exception catch (e) {
      return Error(exception: e);
    }
  }


}
