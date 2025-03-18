import 'package:flutter/material.dart';
import 'package:oservice/entities/collaborator.dart';

class EnglishWarningIcon extends StatelessWidget {
  final bool englishLesson;
  final List<Collaborator> chosenCollaborators;

  const EnglishWarningIcon({super.key, required this.chosenCollaborators, required this.englishLesson});

  bool get isEnglishWarning => chosenCollaborators.any((collaborator) => !collaborator.englishSpeaker);

  @override
  Widget build(BuildContext context) {
    if (englishLesson && isEnglishWarning) {
      return Tooltip(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: Theme.of(context).primaryTextTheme.labelSmall,
        message: 'Almeno un collaboratore non parla inglese',
        child: Icon(
          Icons.warning,
          color: Colors.red,
        ),
      );
    }
    return SizedBox();
  }
}