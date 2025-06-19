/// Generated file. Do not edit.
///
/// Original: assets/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 2
/// Strings: 102 (51 per locale)
///
/// Built on 2025-04-20 at 17:16 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, Translations> {
	en(languageCode: 'en', build: Translations.build),
	ru(languageCode: 'ru', build: _StringsRu.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, Translations> build;

	/// Gets current instance managed by [LocaleSettings].
	Translations get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
Translations get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class TranslationProvider extends BaseTranslationProvider<AppLocale, Translations> {
	TranslationProvider({required super.child}) : super(settings: LocaleSettings.instance);

	static InheritedLocaleData<AppLocale, Translations> of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	Translations get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, Translations> {
	LocaleSettings._() : super(utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale setLocaleRaw(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRaw(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	@Deprecated('Use [AppLocaleUtils.supportedLocales]') static List<Locale> get supportedLocales => instance.supportedLocales;
	@Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]') static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, Translations> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// translations

// Path: <root>
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	// Translations
	late final _StringsGlobalErrorEn global_error = _StringsGlobalErrorEn._(_root);
	late final _StringsBottomNavigationEn bottom_navigation = _StringsBottomNavigationEn._(_root);
	late final _StringsHeadersEn headers = _StringsHeadersEn._(_root);
	late final _StringsBrowserDrawerEn browser_drawer = _StringsBrowserDrawerEn._(_root);
	late final _StringsBrowserContentEn browser_content = _StringsBrowserContentEn._(_root);
	late final _StringsNoteTreeDrawerEn note_tree_drawer = _StringsNoteTreeDrawerEn._(_root);
	late final _StringsNoteTreeEn note_tree = _StringsNoteTreeEn._(_root);
	late final _StringsNoteDrawerEn note_drawer = _StringsNoteDrawerEn._(_root);
	late final _StringsNoteContentEn note_content = _StringsNoteContentEn._(_root);
	late final _StringsStartEn start = _StringsStartEn._(_root);
}

// Path: global_error
class _StringsGlobalErrorEn {
	_StringsGlobalErrorEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get root_directory_not_exist => 'Root directory doesn\'t exist';
}

// Path: bottom_navigation
class _StringsBottomNavigationEn {
	_StringsBottomNavigationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get home => 'Browser';
	String get tree => 'Tree';
}

// Path: headers
class _StringsHeadersEn {
	_StringsHeadersEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get browser => 'Browser';
	String get tree => 'Tree';
	String get edit_note => 'Edit';
	String get create_note => 'Create';
}

// Path: browser_drawer
class _StringsBrowserDrawerEn {
	_StringsBrowserDrawerEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get header => 'Actions';
	String get change_theme_dark => 'Change to dark theme';
	String get change_theme_ligth => 'Change to light theme';
	String get hint_delete_path => 'Delete directory path';
	String get hint_edit_path => 'Edit directory path';
	String get hint_create_note => 'Create note';
	String get hint_create_folder => 'Create folder';
}

// Path: browser_content
class _StringsBrowserContentEn {
	_StringsBrowserContentEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get loading => 'Loading';
	String get empty => 'Empty';
	String get plug => 'Choose the directory';
	String get empty_folder => '(Folder is empty)';
	String get dialog_delete_title => 'Are you sure?';
	String get dialog_delete_cancel => 'No';
	String get dialog_delete_confirm => 'Delete anyway';
	String get dublicate_item_in_target_folder => 'There is an object with the same name in the target folder';
	String get dublicate_item_title => 'Dublicate title';
	String get ban_symbol_item_title => 'Title contains bad symbols';
	String get menu_delete => 'Delete';
	String get menu_rename => 'Rename';
	String get menu_create_note => 'Create a note';
	String get menu_create_folder => 'Create a folder';
}

// Path: note_tree_drawer
class _StringsNoteTreeDrawerEn {
	_StringsNoteTreeDrawerEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get search_menu => 'Search and choose';
	String get show_all => 'Show global tree';
	String get history => 'Previously selected';
	String get history_empty => 'There\'s nothing';
}

// Path: note_tree
class _StringsNoteTreeEn {
	_StringsNoteTreeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get loading => 'Loading';
	String get error_on_load_tree => 'There was a problem with loading the tree';
}

// Path: note_drawer
class _StringsNoteDrawerEn {
	_StringsNoteDrawerEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get header => 'Actions';
	String get backLinked_notes => 'Backlinked notes';
	String get forwardLink_notes => 'Link notes';
	String get add_forwardLinked_note => 'Link note';
	String get dialog_delete_title => 'Are you sure?';
	String get dialog_delete_cancel => 'No';
	String get dialog_delete_confirm => 'Delete anyway';
	String get searh_snackbar_sccessfuly => 'Successfuly appended';
	String get searh_snackbar_error => 'Some problem...';
	String get show_local_tree => 'Show local tree';
}

// Path: note_content
class _StringsNoteContentEn {
	_StringsNoteContentEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title_snackbar_error => 'Some problem...';
	String get title_empty => 'Title shoud not be empty';
	String get title_snackbar_dublicate => 'This name already exist';
	String get ban_symbol_item_title => 'Title contains bad symbols';
}

// Path: start
class _StringsStartEn {
	_StringsStartEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get choose_directory => 'Choose a directory where notes will be saved to begining use app';
	String get choose_directory_btn => 'Choose a directory';
	String get choose_directory_history => 'Or choose one of the previoust paths';
}

// Path: <root>
class _StringsRu implements Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_StringsRu.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key);

	@override late final _StringsRu _root = this; // ignore: unused_field

	// Translations
	@override late final _StringsGlobalErrorRu global_error = _StringsGlobalErrorRu._(_root);
	@override late final _StringsBottomNavigationRu bottom_navigation = _StringsBottomNavigationRu._(_root);
	@override late final _StringsHeadersRu headers = _StringsHeadersRu._(_root);
	@override late final _StringsBrowserDrawerRu browser_drawer = _StringsBrowserDrawerRu._(_root);
	@override late final _StringsBrowserContentRu browser_content = _StringsBrowserContentRu._(_root);
	@override late final _StringsNoteTreeDrawerRu note_tree_drawer = _StringsNoteTreeDrawerRu._(_root);
	@override late final _StringsNoteTreeRu note_tree = _StringsNoteTreeRu._(_root);
	@override late final _StringsNoteDrawerRu note_drawer = _StringsNoteDrawerRu._(_root);
	@override late final _StringsNoteContentRu note_content = _StringsNoteContentRu._(_root);
	@override late final _StringsStartRu start = _StringsStartRu._(_root);
}

// Path: global_error
class _StringsGlobalErrorRu implements _StringsGlobalErrorEn {
	_StringsGlobalErrorRu._(this._root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override String get root_directory_not_exist => 'Корневой директории не существует';
}

// Path: bottom_navigation
class _StringsBottomNavigationRu implements _StringsBottomNavigationEn {
	_StringsBottomNavigationRu._(this._root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override String get home => 'Главная';
	@override String get tree => 'Древо';
}

// Path: headers
class _StringsHeadersRu implements _StringsHeadersEn {
	_StringsHeadersRu._(this._root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override String get browser => 'Главная';
	@override String get tree => 'Древо';
	@override String get edit_note => 'Редактирование';
	@override String get create_note => 'Создание';
}

// Path: browser_drawer
class _StringsBrowserDrawerRu implements _StringsBrowserDrawerEn {
	_StringsBrowserDrawerRu._(this._root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override String get header => 'Действия';
	@override String get change_theme_dark => 'Сменить на тёмную тему';
	@override String get change_theme_ligth => 'Сменить на светлую тему';
	@override String get hint_delete_path => 'Удалить путь директории';
	@override String get hint_edit_path => 'Изменить путь директории';
	@override String get hint_create_note => 'Создать объект';
	@override String get hint_create_folder => 'Создать папку';
}

// Path: browser_content
class _StringsBrowserContentRu implements _StringsBrowserContentEn {
	_StringsBrowserContentRu._(this._root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Загрузка';
	@override String get empty => 'Пусто';
	@override String get plug => 'Выберите директорию';
	@override String get empty_folder => '(Папка пуста)';
	@override String get dialog_delete_title => 'Вы уверены?';
	@override String get dialog_delete_cancel => 'Нет';
	@override String get dialog_delete_confirm => 'Удалить';
	@override String get dublicate_item_in_target_folder => 'Объект с таким названием уже есть в целовом месте';
	@override String get dublicate_item_title => 'Объект с таким названием уже есть';
	@override String get ban_symbol_item_title => 'Название содержит запрещённые символы';
	@override String get menu_delete => 'Удалить';
	@override String get menu_rename => 'Переименовать';
	@override String get menu_create_note => 'Создать объект';
	@override String get menu_create_folder => 'Создать папку';
}

// Path: note_tree_drawer
class _StringsNoteTreeDrawerRu implements _StringsNoteTreeDrawerEn {
	_StringsNoteTreeDrawerRu._(this._root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override String get search_menu => 'Найти и выбрать';
	@override String get show_all => 'Отобразить глобальное древо';
	@override String get history => 'Ранее выбранные';
	@override String get history_empty => 'Пусто';
}

// Path: note_tree
class _StringsNoteTreeRu implements _StringsNoteTreeEn {
	_StringsNoteTreeRu._(this._root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Загрузка...';
	@override String get error_on_load_tree => 'Возникла проблема при загрузке древа';
}

// Path: note_drawer
class _StringsNoteDrawerRu implements _StringsNoteDrawerEn {
	_StringsNoteDrawerRu._(this._root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override String get header => 'Действия';
	@override String get backLinked_notes => 'Связанные объекты';
	@override String get forwardLink_notes => 'Привязанные объекты';
	@override String get add_forwardLinked_note => 'Привязаться к объекту';
	@override String get dialog_delete_title => 'Вы уверены?';
	@override String get dialog_delete_cancel => 'Нет';
	@override String get dialog_delete_confirm => 'Удалить';
	@override String get searh_snackbar_sccessfuly => 'Успешно добавлено';
	@override String get searh_snackbar_error => 'Возникла проблема...';
	@override String get show_local_tree => 'Отобразить локальное древо';
}

// Path: note_content
class _StringsNoteContentRu implements _StringsNoteContentEn {
	_StringsNoteContentRu._(this._root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override String get title_snackbar_error => 'Возникла проблема';
	@override String get title_empty => 'Название не должно быть пустым';
	@override String get title_snackbar_dublicate => 'Данное название уже используется';
	@override String get ban_symbol_item_title => 'Название содержит запрещённые символы';
}

// Path: start
class _StringsStartRu implements _StringsStartEn {
	_StringsStartRu._(this._root);

	@override final _StringsRu _root; // ignore: unused_field

	// Translations
	@override String get choose_directory => 'Выберите директорию, где будут храниться объекты';
	@override String get choose_directory_btn => 'Выбрать директорию';
	@override String get choose_directory_history => 'Или выберите один из предыдущих путей';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'global_error.root_directory_not_exist': return 'Root directory doesn\'t exist';
			case 'bottom_navigation.home': return 'Browser';
			case 'bottom_navigation.tree': return 'Tree';
			case 'headers.browser': return 'Browser';
			case 'headers.tree': return 'Tree';
			case 'headers.edit_note': return 'Edit';
			case 'headers.create_note': return 'Create';
			case 'browser_drawer.header': return 'Actions';
			case 'browser_drawer.change_theme_dark': return 'Change to dark theme';
			case 'browser_drawer.change_theme_ligth': return 'Change to light theme';
			case 'browser_drawer.hint_delete_path': return 'Delete directory path';
			case 'browser_drawer.hint_edit_path': return 'Edit directory path';
			case 'browser_drawer.hint_create_note': return 'Create note';
			case 'browser_drawer.hint_create_folder': return 'Create folder';
			case 'browser_content.loading': return 'Loading';
			case 'browser_content.empty': return 'Empty';
			case 'browser_content.plug': return 'Choose the directory';
			case 'browser_content.empty_folder': return '(Folder is empty)';
			case 'browser_content.dialog_delete_title': return 'Are you sure?';
			case 'browser_content.dialog_delete_cancel': return 'No';
			case 'browser_content.dialog_delete_confirm': return 'Delete anyway';
			case 'browser_content.dublicate_item_in_target_folder': return 'There is an object with the same name in the target folder';
			case 'browser_content.dublicate_item_title': return 'Dublicate title';
			case 'browser_content.ban_symbol_item_title': return 'Title contains bad symbols';
			case 'browser_content.menu_delete': return 'Delete';
			case 'browser_content.menu_rename': return 'Rename';
			case 'browser_content.menu_create_note': return 'Create a note';
			case 'browser_content.menu_create_folder': return 'Create a folder';
			case 'note_tree_drawer.search_menu': return 'Search and choose';
			case 'note_tree_drawer.show_all': return 'Show global tree';
			case 'note_tree_drawer.history': return 'Previously selected';
			case 'note_tree_drawer.history_empty': return 'There\'s nothing';
			case 'note_tree.loading': return 'Loading';
			case 'note_tree.error_on_load_tree': return 'There was a problem with loading the tree';
			case 'note_drawer.header': return 'Actions';
			case 'note_drawer.backLinked_notes': return 'Backlinked notes';
			case 'note_drawer.forwardLink_notes': return 'Link notes';
			case 'note_drawer.add_forwardLinked_note': return 'Link note';
			case 'note_drawer.dialog_delete_title': return 'Are you sure?';
			case 'note_drawer.dialog_delete_cancel': return 'No';
			case 'note_drawer.dialog_delete_confirm': return 'Delete anyway';
			case 'note_drawer.searh_snackbar_sccessfuly': return 'Successfuly appended';
			case 'note_drawer.searh_snackbar_error': return 'Some problem...';
			case 'note_drawer.show_local_tree': return 'Show local tree';
			case 'note_content.title_snackbar_error': return 'Some problem...';
			case 'note_content.title_empty': return 'Title shoud not be empty';
			case 'note_content.title_snackbar_dublicate': return 'This name already exist';
			case 'note_content.ban_symbol_item_title': return 'Title contains bad symbols';
			case 'start.choose_directory': return 'Choose a directory where notes will be saved to begining use app';
			case 'start.choose_directory_btn': return 'Choose a directory';
			case 'start.choose_directory_history': return 'Or choose one of the previoust paths';
			default: return null;
		}
	}
}

extension on _StringsRu {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'global_error.root_directory_not_exist': return 'Корневой директории не существует';
			case 'bottom_navigation.home': return 'Главная';
			case 'bottom_navigation.tree': return 'Древо';
			case 'headers.browser': return 'Главная';
			case 'headers.tree': return 'Древо';
			case 'headers.edit_note': return 'Редактирование';
			case 'headers.create_note': return 'Создание';
			case 'browser_drawer.header': return 'Действия';
			case 'browser_drawer.change_theme_dark': return 'Сменить на тёмную тему';
			case 'browser_drawer.change_theme_ligth': return 'Сменить на светлую тему';
			case 'browser_drawer.hint_delete_path': return 'Удалить путь директории';
			case 'browser_drawer.hint_edit_path': return 'Изменить путь директории';
			case 'browser_drawer.hint_create_note': return 'Создать объект';
			case 'browser_drawer.hint_create_folder': return 'Создать папку';
			case 'browser_content.loading': return 'Загрузка';
			case 'browser_content.empty': return 'Пусто';
			case 'browser_content.plug': return 'Выберите директорию';
			case 'browser_content.empty_folder': return '(Папка пуста)';
			case 'browser_content.dialog_delete_title': return 'Вы уверены?';
			case 'browser_content.dialog_delete_cancel': return 'Нет';
			case 'browser_content.dialog_delete_confirm': return 'Удалить';
			case 'browser_content.dublicate_item_in_target_folder': return 'Объект с таким названием уже есть в целовом месте';
			case 'browser_content.dublicate_item_title': return 'Объект с таким названием уже есть';
			case 'browser_content.ban_symbol_item_title': return 'Название содержит запрещённые символы';
			case 'browser_content.menu_delete': return 'Удалить';
			case 'browser_content.menu_rename': return 'Переименовать';
			case 'browser_content.menu_create_note': return 'Создать объект';
			case 'browser_content.menu_create_folder': return 'Создать папку';
			case 'note_tree_drawer.search_menu': return 'Найти и выбрать';
			case 'note_tree_drawer.show_all': return 'Отобразить глобальное древо';
			case 'note_tree_drawer.history': return 'Ранее выбранные';
			case 'note_tree_drawer.history_empty': return 'Пусто';
			case 'note_tree.loading': return 'Загрузка...';
			case 'note_tree.error_on_load_tree': return 'Возникла проблема при загрузке древа';
			case 'note_drawer.header': return 'Действия';
			case 'note_drawer.backLinked_notes': return 'Связанные объекты';
			case 'note_drawer.forwardLink_notes': return 'Привязанные объекты';
			case 'note_drawer.add_forwardLinked_note': return 'Привязаться к объекту';
			case 'note_drawer.dialog_delete_title': return 'Вы уверены?';
			case 'note_drawer.dialog_delete_cancel': return 'Нет';
			case 'note_drawer.dialog_delete_confirm': return 'Удалить';
			case 'note_drawer.searh_snackbar_sccessfuly': return 'Успешно добавлено';
			case 'note_drawer.searh_snackbar_error': return 'Возникла проблема...';
			case 'note_drawer.show_local_tree': return 'Отобразить локальное древо';
			case 'note_content.title_snackbar_error': return 'Возникла проблема';
			case 'note_content.title_empty': return 'Название не должно быть пустым';
			case 'note_content.title_snackbar_dublicate': return 'Данное название уже используется';
			case 'note_content.ban_symbol_item_title': return 'Название содержит запрещённые символы';
			case 'start.choose_directory': return 'Выберите директорию, где будут храниться объекты';
			case 'start.choose_directory_btn': return 'Выбрать директорию';
			case 'start.choose_directory_history': return 'Или выберите один из предыдущих путей';
			default: return null;
		}
	}
}
