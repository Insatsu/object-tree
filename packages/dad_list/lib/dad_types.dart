import 'package:flutter/material.dart';
import 'package:dad_list/dad.dart';

typedef DadWidgetSetState = void Function(void Function());

typedef DadWidgetSetStateWrapper = void Function();

typedef DadWidgetBuilder<T extends Object> = Widget Function(BuildContext context, IDadItem<T> item);

