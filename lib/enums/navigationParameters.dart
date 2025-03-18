
import 'package:oservice/enums/menu.dart';

class NavigationParametersEnum {

  const NavigationParametersEnum._();

  static const NavigationParametersEnum NO_PARAMETER = NavigationParametersEnum._();
  static const NavigationParametersEnum LESSON = NavigationParametersEnum._();
  static const NavigationParametersEnum ENTITY = NavigationParametersEnum._();
  static const NavigationParametersEnum COLLABORATOR = NavigationParametersEnum._();
  static const NavigationParametersEnum LOCATION = NavigationParametersEnum._();
}

class NavigationParameters {
  final NavigationParametersEnum type;
  final dynamic object;
  final Menu menu;

  NavigationParameters(this.type, this.object, this.menu);
}