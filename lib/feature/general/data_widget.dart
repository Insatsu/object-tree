import 'package:flutter/widgets.dart';

class DataWidget extends InheritedWidget {
  const DataWidget(
      {super.key, required super.child, required this.shownScreenIndex});

  final ValueNotifier<int> shownScreenIndex;

  static DataWidget? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DataWidget>();
  }

  static DataWidget of(BuildContext context) {
    final DataWidget? result = maybeOf(context);
    assert(result != null, 'No DataWidget found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return false;
  }
}
