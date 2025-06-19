import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/core/constants.dart';
import 'package:object_tree/core/themes.dart';
import 'package:object_tree/domain/repositories/i_node_repository.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'root_event.dart';
part 'root_state.dart';

class RootBloc extends Bloc<RootEvent, RootState> {
  RootBloc({required ThemeData? currentTheme})
      : localTheme = currentTheme ?? classicThemeLight,
        super(const RootInitial()) {
    on<RootInit>((event, emit) async {
      // localTheme = classicThemeLight;
      emit(const RootInited());
      GetIt.I<Talker>().info("Root inited");
    });
    on<RootSetDarkTheme>((event, emit) {
      localTheme = classicTheme;
      GetIt.I<INodeRepository>().sharedPref.setTheme(DARK_THEME);

      emit(const RootChangedTheme(themeIndex: 1));
    });

    on<RootSetLightTheme>((event, emit) {
      localTheme = classicThemeLight;
      GetIt.I<INodeRepository>().sharedPref.setTheme(LIGHT_THEME);

      emit(const RootChangedTheme(themeIndex: 0));
    });
  }

  ThemeData localTheme;

  bool get isDarkTheme => localTheme == classicTheme;
}
