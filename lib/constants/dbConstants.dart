class DbConstants {
  final String type;

  const DbConstants._(this.type);

  static const String COLLABORATORS = 'collaborators';
  static const String ENTITIES = 'entities';
  static const String EXERCISES = 'exercises';
  static const String LESSONS = 'lessons';
  static const String LOCATIONS = 'locations';
  static const String SETTINGS = 'settings';
  static const String PAYMENTS = 'payments';
  static const String TAX_INFO = 'taxInfo';

  static const String SAVED_COLLECTIONS = 'savedLesson';
  static const String IS_SAVED_LESSON = 'isSavedLesson';
  static const String REGISTERED_LESSON = 'registeredLesson';

  static const String SAVED_LESSON = 'savedLesson';
  static const String SAVED_ENTITY = 'savedEntity';
  static const String SAVED_EXERCISE = 'savedExercise';
  static const String SAVED_LOCATION = 'savedLocation';
  static const String SAVED_COLLABORATOR = 'savedCollaborator';
  static const String SAVED_TAX_INFO = 'savedTaxInfo';

  static const String EDIT_LESSON = 'isEditingLesson';
  static const String EDIT_ENTITY = 'isEditingEntity';
  static const String EDIT_EXERCISE = 'isEditingExercise';
  static const String EDIT_LOCATION = 'isEditingLocation';
  static const String EDIT_COLLABORATOR = 'isEditingCollaborator';

  static const String DAYS_BEFORE = 'numberOfDaysBeforeToBeVisualized';
  static const String NEW_EVENT_NOTIFICATION = 'newEventNotification';
  static const String UPDATE_EVENT_NOTIFICATION = 'updateEventNotification';
  static const String DELETED_EVENT_NOTIFICATION = 'deletedEventNotification';
  static const String EVENT_REMINDERS = 'eventReminders';
  static const String PAYRATE_DEFAULT = 'payrate';
}