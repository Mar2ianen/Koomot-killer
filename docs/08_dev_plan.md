# Development Plan

## Этап 1: Rust core skeleton

Задачи:

- создать crate `kk_core`;
- добавить модели RouteAnalysis/RouteSegment;
- подключить `gpx`, `geo`, `serde`, `thiserror`;
- написать парсер GPX bytes -> RouteAnalysis;
- добавить тестовые GPX из `data/samples`.

Definition of Done:

- CLI или тест умеет прочитать GPX;
- возвращает дистанцию, точки, bbox;
- падает с понятной ошибкой на битом файле.

## Этап 2: Elevation analysis

Задачи:

- расчёт gain/loss;
- фильтрация микрошумов высоты;
- min/max elevation;
- distance-from-start для каждой точки;
- warnings по отсутствующей высоте.

Definition of Done:

- RouteAnalysis содержит профиль высоты;
- сегменты видят набор/сброс.

## Этап 3: Flutter shell

Задачи:

- создать Flutter app;
- включить Material 3;
- сделать главный layout;
- добавить open file/drop zone;
- показать empty state.

Definition of Done:

- приложение запускается на desktop;
- есть базовая тема;
- можно выбрать файл.

## Этап 4: Flutter ↔ Rust bridge

Задачи:

- подключить flutter_rust_bridge;
- прокинуть `analyze_gpx(bytes)`;
- сериализовать RouteAnalysis;
- обработать ошибки.

Definition of Done:

- Flutter получает реальные данные из Rust.

## Этап 5: Map view

Задачи:

- подключить MapLibre;
- показать карту;
- отрисовать polyline;
- старт/финиш;
- auto-fit bbox.

Definition of Done:

- GPX визуально отображается на карте.

## Этап 6: Stats and elevation profile

Задачи:

- stats cards;
- elevation chart;
- basic segment list;
- warnings panel.

Definition of Done:

- приложение уже полезно как GPX inspector.

## Этап 7: Packaging

Задачи:

- Linux desktop build;
- web build check;
- sample routes;
- README;
- screenshots.

Definition of Done:

- v0.1 можно показать и дать потыкать.

## После v0.1

Следующий крупный блок — OSM surface analyzer. До него не трогать полноценный роутинг.

