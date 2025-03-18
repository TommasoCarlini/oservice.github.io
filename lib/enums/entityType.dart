class EntityType {
  final String type;

  const EntityType._(this.type);

  static const EntityType SCHOOL = EntityType._('Scuola');
  static const EntityType PRIVATE = EntityType._('Privato');
  static const EntityType AZIENDA = EntityType._('Azienda');

  static fromString(data) {
    switch (data) {
      case 'Scuola':
        return SCHOOL;
      case 'Privato':
        return PRIVATE;
      case 'Azienda':
        return AZIENDA;
      default:
        return SCHOOL;
    }
  }

  static List<EntityType> values() {
    return [SCHOOL, PRIVATE, AZIENDA];
  }
}