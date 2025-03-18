class ExerciseType {
  final String type;

  const ExerciseType._(this.type);

  static const ExerciseType PRATICA = ExerciseType._('Pratica');
  static const ExerciseType TEORICA = ExerciseType._('Teorica');
  static const ExerciseType GARA = ExerciseType._('Gara');

  static List<String> exercises() {
    return [
      PRATICA.type,
      TEORICA.type,
      GARA.type,
    ];
  }

  static ExerciseType fromString(String text) {
    switch (text) {
      case 'Pratica':
        return PRATICA;
      case 'Teorica':
        return TEORICA;
      case 'Gara':
        return GARA;
      default:
        return PRATICA;
    }
  }
}