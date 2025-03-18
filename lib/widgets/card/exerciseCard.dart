import 'package:flutter/material.dart';
import 'package:oservice/entities/exercise.dart';
import 'package:oservice/enums/exerciseType.dart';
import 'package:oservice/widgets/card/exerciseCardAction.dart';

class ExerciseCard extends StatefulWidget {
  final Function changeTab;
  final TabController menu;
  final Exercise exercise;
  final Future<void> Function() refreshExercises;

  const ExerciseCard({
    super.key,
    required this.changeTab,
    required this.menu,
    required this.exercise,
    required this.refreshExercises,
  });

  @override
  _ExerciseCardState createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      color: Theme.of(context).cardColor,
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: widget.exercise.type == ExerciseType.PRATICA
              ? Icon(Icons.directions_run_rounded,
                  color: Theme.of(context).primaryColorLight)
              : Icon(Icons.menu_book,
                  color: Theme.of(context).primaryColorLight),
        ),
        title: Row(
          children: [
            Tooltip(
              message: widget.exercise.description,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: Theme.of(context).primaryTextTheme.labelSmall,
              child: Text(
                widget.exercise.title,
                style: TextStyle(
                  color: Theme.of(context).primaryColorLight,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 10)
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.format_list_numbered_rounded,
                    color: Theme.of(context).primaryColorLight),
                Text(
                  widget.exercise.buildMaterialText(),
                  style: TextStyle(color: Theme.of(context).primaryColorLight),
                ),
              ],
            ),
          ],
        ),
        trailing: ExerciseCardAction(
          changeTab: widget.changeTab,
          menu: widget.menu,
          exercise: widget.exercise,
          refreshExercises: widget.refreshExercises,
        ),
      ),
    );
  }
}
