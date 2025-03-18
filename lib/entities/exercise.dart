import 'package:oservice/enums/exerciseType.dart';

class Exercise {
  late String id;
  final String title;
  final String description;
  final ExerciseType type;
  final List<String> material;

  Exercise({required this.title, required this.description, required this.type, required this.material});

  factory Exercise.fromMap(Map<String, dynamic> data) {
    return Exercise(
      title: data['title'],
      description: data['description'],
      type: ExerciseType.fromString(data['type']),
      material: List<String>.from(data['material']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type.type,
      'material': material,
    };
  }

  String buildMaterialText() {
    if (material.isEmpty) {
      return 'Nessun materiale';
    }
    String text = '';
    for (var material in material) {
      text += '$material, ';
    }
    return text.substring(0, text.length - 2);
  }
}