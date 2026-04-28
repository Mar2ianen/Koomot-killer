# Tech Stack

## UI

### Основной выбор

- Flutter
- Material 3
- Desktop-first layout
- Mobile-adaptive layout

### Почему Flutter

- единая кодовая база;
- хороший desktop/mobile/web охват;
- быстрая отрисовка UI;
- нормальный Material 3;
- возможность собрать web-версию.

## Карта

### Базовый вариант

- MapLibre Flutter
- vector tiles
- route polyline overlay

### После MVP

- PMTiles для офлайна;
- Martin как tile server;
- OpenMapTiles/Protomaps как источник.

## Rust core

### MVP crates

```text
gpx
geo
geo-types
serde
serde_json
chrono
thiserror
```

### Геометрия и индексы после MVP

```text
rstar
petgraph
bincode/postcard
```

### OSM после MVP

```text
osm4routing2
osmpbfreader
fast-osmpbf
```

### Роутинг после MVP

```text
fast_paths
```

## Interop

### Native/mobile/desktop

```text
flutter_rust_bridge
```

### Web/WASM

```text
wasm-bindgen
serde-wasm-bindgen
```

## Storage

### MVP

- локальные файлы;
- in-memory analysis;
- простая папка с маршрутами.

### После MVP

- SQLite для библиотеки маршрутов;
- отдельные файлы для кэша анализа;
- PMTiles/MBTiles для офлайн-карт.

## Форматы

### Input

- GPX

### Output

- GPX
- JSON route analysis
- GeoJSON позже
- CSV report позже

## Не используем в MVP

- собственный tile renderer;
- PostGIS;
- полноценный backend;
- cloud sync;
- аккаунты.

