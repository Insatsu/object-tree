import 'package:object_tree/data/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedpreferencesRepository {
  SharedpreferencesRepository._();
  factory SharedpreferencesRepository() => _instance;

  static final SharedpreferencesRepository _instance =
      SharedpreferencesRepository._();

  SharedPreferences? _prefs;

  SharedPreferences get prefs => _prefs!;

  List<String> get previousPaths => getPreviousPaths();

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  List<String> getPreviousPaths() {
    List<String> _previousPaths = prefs.getStringList(KeyStore.previousPaths) ??
        KeyStore.previousPathsDefault;

    for(int i =0; i <_previousPaths.length; i++){
      if(!FileSystemRepository.isDirectoryExistByPath(_previousPaths[i])){
        removeFromPreviousPaths(i);
      }
    }

    return _previousPaths;
    
  }

  String? getPath() {
    return prefs.getString(KeyStore.currentPath) ?? KeyStore.currentPathDefault;
  }

  Future<void> setNewPathAndUpdatePrevious(String newValue) async {
    await prefs.setString(KeyStore.currentPath, newValue);
    await updatePreviousPaths(newValue);
  }

  Future<void> updatePreviousPaths(String value) async {
    List<String> previousPaths = prefs.getStringList(KeyStore.previousPaths) ??
        KeyStore.previousPathsDefault;
    if (previousPaths.indexOf(value) == 0) {
      return;
    }
    if (previousPaths.length < 2) {
      await addToPreviousPaths(value);
      return;
    }

    previousPaths.remove(value);
    prefs.setStringList(KeyStore.previousPaths, previousPaths);
    await addToPreviousPaths(value);
    return;
  }

  Future<void> addToPreviousPaths(String newValue) async {
    List<String> previousPaths = prefs.getStringList(KeyStore.previousPaths) ??
        KeyStore.previousPathsDefault;

    previousPaths.insert(0, newValue);

    if (previousPaths.length > 3) {
      // Для уверенности
      previousPaths = previousPaths.getRange(0, 3).toList();
    }

    await prefs.setStringList(KeyStore.previousPaths, previousPaths);
  }

  Future<void> removeFromPreviousPaths(int index) async {
    List<String> previousPaths = prefs.getStringList(KeyStore.previousPaths) ??
        KeyStore.previousPathsDefault;
    if (previousPaths.isEmpty) {
      return;
    }

    previousPaths.removeAt(index);
    prefs.setStringList(KeyStore.previousPaths, previousPaths);
    return;
  }

  // * Themes
  Future<void> setTheme(String newValue) async {
    await prefs.setString(KeyStore.currentTheme, newValue);
  }

  String? getTheme() {
    return prefs.getString(KeyStore.currentTheme);
  }
}
