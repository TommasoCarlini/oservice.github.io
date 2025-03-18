import 'package:flutter/material.dart';
import 'package:oservice/widgets/screen/addCollaboratorScreen.dart';
import 'package:oservice/widgets/screen/addExerciseScreen.dart';
import 'package:oservice/widgets/screen/addLessonScreen.dart';
import 'package:oservice/widgets/screen/collaboratorScreen.dart';
import 'package:oservice/widgets/screen/entityScreen.dart';
import 'package:oservice/widgets/screen/homeScreen.dart';

List<Widget> Contents(BuildContext context, double height, Function changeTab,
    TabController tabController) {
  return [
    HomeScreen(
      changeTab: changeTab,
      menu: tabController,
    ), // 0
    // EntityScreen(context, height, changeTab, tabController), // 1
    // CollaboratorScreen(context, height, changeTab, tabController), // 2
    // EntityScreen(context, height, changeTab, tabController), // 3
    // AddExerciseScreen(context, height, changeTab, tabController), // 4
    // AddLessonScreen(context, height, changeTab, tabController), // 5
    // AddCollaboratorScreen(
    //   height: height,
    //   changeTab: changeTab,
    //   menu: tabController,
    // ), // 6
    // AddCollaboratorScreen(
    //   height: height,
    //   changeTab: changeTab,
    //   menu: tabController,
    // ), // 7
    // AddLessonScreen(context, height, changeTab, tabController), // 8
    // AddExerciseScreen(context, height, changeTab, tabController), // 9
  ];
}
