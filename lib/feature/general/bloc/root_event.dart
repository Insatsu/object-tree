part of 'root_bloc.dart';

sealed class RootEvent extends Equatable {
  const RootEvent();
}

class RootInit extends RootEvent {
  const RootInit();

  @override
  List<Object?> get props => [];
}
class RootSetDarkTheme extends RootEvent {
  const RootSetDarkTheme();

  @override
  List<Object?> get props => [];
}

class RootSetLightTheme extends RootEvent {
  const RootSetLightTheme();

  @override
  List<Object?> get props => [];
}
