import 'package:flutter/material.dart';
import 'package:oservice/entities/collaborator.dart';

class MiddleNameWarning extends StatelessWidget {
  const MiddleNameWarning({super.key});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: Theme.of(context).primaryTextTheme.labelSmall,
      message: 'Controlla il nome',
      child: Icon(
        Icons.warning,
        color: Colors.yellow,
      ),
    );
  }
}
