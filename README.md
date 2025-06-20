# Граф объектов

Приложение для отображения графа связей между объектами. 

## Возможности
- работа с объектами, их создание, удаление, редактирование, перемещение
- форматирование содержания согласно Markdown разметке
- работа со связями между объектами
- интерактивный граф объектов и связей с их разбитием на кластеры связности
- отображение локальных графов отдельных объектов


**Объект** - файл на устройстве пользователя в выбранной им папке с расширением "md". 

Все объекты отображаются на главном экране, на котором также можно создавать папки. Смена названия и удаление элемента доступно через меню.
Если элемент - папка, в меню добавлюятся пункты для создания в ней новых объекта и папки.
Для перемещениея необходимо зажать касание на элементе и потянуть в нужную папку. 

### Дополнительно
- смена темы
- показ расширения для файлов, у которых оно отлично от "md"
- цвет точек на графе отражает количество и типы связей объекта:
  - фиолетовый - связей нет
  - синий - исходящих связей больше входящих
  - оранжевый - входящих связей больше либо равно исходящим
 

#### Библиотеки и технологии 
Flutter, Dart, Isolates, Flutter Bloc, Go router, SQFLite, File picker, Slang, Equatable, Flutter marckdown, url_launcher, Get_it, Talker flutter


