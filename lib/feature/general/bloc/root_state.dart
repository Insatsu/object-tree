part of 'root_bloc.dart';

sealed class RootState extends Equatable {
  const RootState();
}

class RootInitial extends RootState {
  const RootInitial();
  @override
  List<Object?> get props => [];
}
class RootInited extends RootState {
  const RootInited();
  @override
  List<Object?> get props => [];
}

class RootChangedTheme extends RootState {
  const RootChangedTheme({required this.themeIndex});
  final int themeIndex;
  @override
  List<Object?> get props => [themeIndex];
}

