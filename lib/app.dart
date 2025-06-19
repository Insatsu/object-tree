import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/core/constants.dart';
import 'package:object_tree/core/routers.dart';
import 'package:object_tree/core/themes.dart';
import 'package:object_tree/domain/repositories/i_node_repository.dart';
import 'package:object_tree/domain/usecases/db_close.dart';
import 'package:object_tree/feature/general/bloc/root_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:object_tree/feature/general/data_widget.dart';

extension FirstWhereOrNullExnt<T> on List<T>{
  T? firstWhereOrNull(bool Function(T element) test){
    late T? result;
    try {
      result = firstWhere(test);
    } catch (e) {
      result = null;
    }
    return result;
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _router = goRoutes;

  late final RootBloc _bloc;
  @override
  void initState() {
    // * Define theme
    var themeString = GetIt.I<INodeRepository>().sharedPref.getTheme();
    ThemeData? theme;
    if (themeString == LIGHT_THEME) {
      theme = classicThemeLight;
    } else if (themeString == DARK_THEME) {
      theme = classicTheme;
    }

    _bloc = RootBloc(currentTheme: theme);

    GetIt.I.registerSingleton(_bloc);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DataWidget(
      shownScreenIndex: ValueNotifier(0),
      child: BlocSelector<RootBloc, RootState, ThemeData>(
        bloc: _bloc,
        selector: (state) {
          return _bloc.localTheme;
        },
        builder: (context, state) {
          /// Setting status bar color
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
              statusBarColor: state.colorScheme.surfaceContainer,
              systemNavigationBarColor: state.colorScheme.surfaceContainer,
              systemNavigationBarDividerColor: state.colorScheme.surfaceContainer,
              statusBarBrightness: state.brightness,
              statusBarIconBrightness: state.brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarIconBrightness: state.brightness));
      
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Object tree',
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            supportedLocales: <Locale>[
              Locale('en', 'US'), 
              Locale('ru', 'RU'), 
            ],
            theme: state,
            routerConfig: _router,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    closeDbUseCase(GetIt.I<INodeRepository>());
    super.dispose();
  }
}
