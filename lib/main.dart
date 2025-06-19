import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/app.dart';
import 'package:object_tree/data/repositories/db/db_repository.dart';
import 'package:object_tree/data/repositories/nodes_repository.dart';
import 'package:object_tree/domain/repositories/i_node_repository.dart';
import 'package:object_tree/feature/note_browser_page/bloc/browser_bloc.dart';
import 'package:object_tree/i18n/strings.g.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';

void main() async {
  final talker = TalkerFlutter.init();
  GetIt.I.registerSingleton(talker);

  GetIt.I<Talker>().debug("<Main is started>");

  Bloc.observer = TalkerBlocObserver(talker: talker);

  final INodeRepository repository = NodesRepository(db: DbProvider());
  // ! There is may not init() because i don't know so it's called late
  // Init will in route redirect
  GetIt.I.registerSingleton(repository);

  final browserbloc = BrowserBloc(repository);
  GetIt.I.registerSingleton(browserbloc);

  FlutterError.onError =
      ((details) => GetIt.I<Talker>().handle(details.exception, details.stack));

  await runZonedGuarded(() async {
    // !* Binding for begin initialize app but not create widget, so it can work with phone
    WidgetsFlutterBinding.ensureInitialized();

    await GetIt.I<INodeRepository>().init();
    LocaleSettings.useDeviceLocale();
    // * Run app
    runApp(const MainApp());
  }, (error, stack) => GetIt.I<Talker>().handle(error, stack));
}
