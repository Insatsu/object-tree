import 'package:equatable/equatable.dart';
import 'package:path/path.dart';

abstract class BrowserItemEntity extends Equatable {
  const BrowserItemEntity(
      {required this.relativePath});

  final String relativePath;

  String get title => basenameWithoutExtension(relativePath);
  int get level => relativePath.split('/').length - 1;
  String get itemExtension => extension(relativePath);

  @override
  List<Object?> get props => [relativePath];
}
