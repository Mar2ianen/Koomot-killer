# Komoot Killer UI MVP

Минимальный Flutter-прототип интерфейса для будущей GPX-читалки:

- Material 3;
- адаптивный layout под desktop/tablet/mobile;
- карта на `flutter_map`;
- OSM tile layer для локальной разработки;
- моковый маршрут с линией, стартом и финишем;
- панель статистики;
- высотный профиль;
- список сегментов и предупреждений.

Это пока **UI skeleton**, без настоящего парсинга GPX и без Rust-core. Его задача: быстро зафиксировать форму приложения, чтобы потом подключить реальный импорт GPX, OSM-анализ и маршрутизацию.

## Как запустить

```bash
cd kk_flutter_ui_mvp
flutter create --platforms=linux,windows,macos,web,android,ios .
flutter pub get
flutter run -d linux
```

Для web:

```bash
flutter run -d chrome
```

## Важное про OSM tiles

В прототипе используется `https://tile.openstreetmap.org/{z}/{x}/{y}.png`. Это удобно для разработки, но не годится как production backend. Для реального приложения лучше перейти на PMTiles, self-hosted tiles, Martin, OpenMapTiles, Protomaps или коммерческий tile provider.

## Куда дальше

1. Подключить реальный выбор `.gpx` файла.
2. Передать файл в Rust-core через `flutter_rust_bridge`.
3. Вернуть `RouteAnalysis` во Flutter.
4. Заменить моковый маршрут на реальные данные.
5. Добавить OSM surface analyzer.
