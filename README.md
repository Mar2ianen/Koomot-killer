# Komoot Killer MVP

![Status](https://img.shields.io/badge/status-planning%20%2F%20prototype-blue)
![License](https://img.shields.io/badge/license-MIT%20OR%20Apache--2.0-green)
![Stack](https://img.shields.io/badge/stack-Rust%20%2B%20Flutter%20%2B%20MapLibre-orange)

Локальный и быстрый GPX viewer / route inspector для вело, гревела и офлайн-ориентированной работы с маршрутами.

Идея MVP простая: сначала не строим собственный роутер. Сначала делаем удобную читалку GPX с картой, статистикой, высотным профилем и базовой диагностикой маршрута. После этого добавляем OSM-анализ покрытия, затем редактор, и только потом экспериментируем с роутингом.

## Главный принцип

Не писать свой рендер карт и не пытаться сразу сделать свой Valhalla. Используем готовые решения для карты и тайлов, а собственную ценность создаем в Rust-ядре: анализ GPX, сегменты, метрики, профиль высоты, предупреждения, скоринг и будущий routing layer.

## MVP v0.1 Route Viewer

Первая рабочая версия должна уметь:

- открывать `.gpx` файлы;
- показывать маршрут на карте;
- считать дистанцию, набор и сброс высоты;
- строить высотный профиль;
- разбивать маршрут на сегменты;
- показывать базовые предупреждения по градиентам и сомнительным данным;
- готовить основу под дальнейший OSM-анализ и роутинг.

## Планируемый стек

| Слой | Выбор |
| --- | --- |
| UI | Flutter |
| Core | Rust |
| Flutter/Rust bridge | flutter_rust_bridge |
| Web target | WebAssembly |
| Map view | MapLibre |
| Tiles | PMTiles / Martin / self-hosted vector tiles |
| GPX | Rust GPX parser + собственная модель маршрута |
| Будущий routing | сначала анализ GPX, потом osm4routing2 / fast_paths / собственный scoring |

## Состав документации

- `docs/01_product_brief.md` - концепция продукта.
- `docs/02_mvp_scope.md` - что входит и не входит в MVP.
- `docs/03_architecture.md` - архитектура Flutter + Rust + MapLibre.
- `docs/04_tech_stack.md` - рекомендуемый стек.
- `docs/05_data_model.md` - базовые структуры данных.
- `docs/06_design_system_material3.md` - дизайн-система в стиле Material 3.
- `docs/07_roadmap.md` - роадмап версий.
- `docs/08_dev_plan.md` - порядок разработки.
- `design_refs/` - визуальные референсы интерфейса.

## Что не входит в первый MVP

- собственный routing engine;
- свой tile renderer;
- аккаунты и социальные функции;
- подписки;
- turn-by-turn навигация;
- офлайн-карты всего мира;
- сложное редактирование маршрута мышкой.

## Карты, OSM и лицензии данных

Код проекта распространяется под лицензией `MIT OR Apache-2.0`.

Данные OpenStreetMap имеют отдельные условия. Если приложение использует OSM-данные или производные базы, нужно сохранять корректную атрибуцию:

```text
Map data © OpenStreetMap contributors
```

OpenStreetMap data is available under the Open Data Commons Open Database License.

Важно: публичные tile-серверы OpenStreetMap не предназначены для массового скачивания, предзагрузки и коммерческого/продуктового бэкенда. Для приложения лучше использовать self-hosted vector tiles, PMTiles, Martin, OpenMapTiles, Protomaps или другой легальный источник тайлов.

## Roadmap

```text
v0.1 Route Viewer
  GPX import, map view, stats, elevation profile

v0.2 OSM Surface Analyzer
  surface/highway/tracktype/smoothness/access analysis

v0.3 Route Editor
  manual editing, segment operations, GPX export

v0.4 Rust Routing Prototype
  OSM graph import, fast_paths experiments, custom weights

v0.5 Gravel Profile Router
  gravel/road/commute profiles, scoring, route comparison
```

## License

Licensed under either of:

- MIT license, see `LICENSE-MIT`
- Apache License, Version 2.0, see `LICENSE-APACHE`

at your option.
