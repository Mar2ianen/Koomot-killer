# Architecture

## Целевая архитектура

```text
Flutter UI
  ├─ Desktop: Linux / Windows / macOS
  ├─ Mobile: Android / iOS
  └─ Web: Flutter Web / WASM

Map layer
  └─ MapLibre + vector tiles

Rust core
  ├─ GPX parser
  ├─ route model
  ├─ elevation analysis
  ├─ segments
  ├─ statistics
  ├─ future OSM matching
  └─ future routing

Interop
  ├─ flutter_rust_bridge для native/mobile/desktop
  └─ wasm-bindgen / WASM для web-билда
```

## Принцип разделения ответственности

### Flutter

Flutter отвечает за:

- UI;
- навигацию;
- карту;
- панели;
- графики;
- выбор файла;
- отображение результата.

Flutter не должен считать тяжёлую геометрию и анализ маршрута.

### Rust

Rust отвечает за:

- парсинг GPX;
- нормализацию данных;
- расчёт дистанции;
- расчёт набора/сброса;
- генерацию сегментов;
- подготовку polyline;
- будущий OSM matching;
- будущий роутинг.

## Высокоуровневый поток данных

```text
User selects GPX
  ↓
Flutter reads file bytes
  ↓
Rust core parses GPX
  ↓
Rust core returns RouteAnalysis
  ↓
Flutter renders:
  - map polyline
  - stats cards
  - elevation profile
  - segments table
```

## Структура репозитория

```text
komoot-killer/
  apps/
    flutter_app/
      lib/
        main.dart
        screens/
        widgets/
        map/
        theme/

  crates/
    kk_core/
      src/
        lib.rs
        gpx.rs
        route.rs
        elevation.rs
        stats.rs
        segments.rs
        errors.rs

    kk_ffi/
      src/
        lib.rs
        api.rs

    kk_wasm/
      src/
        lib.rs

  data/
    samples/
      test_route.gpx

  docs/
```

## Runtime-варианты

### Native/Desktop

```text
Flutter Desktop
  ↓ FFI
Rust core native library
```

### Mobile

```text
Flutter Mobile
  ↓ generated bridge
Rust core native library
```

### Web

```text
Flutter Web
  ↓ JS interop / WASM bridge
Rust core compiled to WASM
```

## Будущая архитектура роутинга

```text
OSM .pbf
  ↓
osm4routing2 / custom extractor
  ↓
normalized graph
  ↓
profile weights
  ↓
fast_paths prepared graph
  ↓
route result
  ↓
RouteAnalysis + map polyline
```

## Карты и тайлы

MVP:

- MapLibre view;
- готовый dev tile source;
- polyline overlay.

После MVP:

- PMTiles для локальных регионов;
- Martin для self-hosted vector tiles;
- OpenMapTiles/Protomaps как источник стилей и тайлов.

## Риски

### Риск 1: закопаться в роутинге

Митигация: не делать роутинг до стабильного GPX viewer.

### Риск 2: закопаться в рендере карт

Митигация: использовать MapLibre.

### Риск 3: Flutter Web + WASM interop может быть неудобным

Митигация: сначала сделать native desktop, потом web.

### Риск 4: OSM matching сложнее, чем кажется

Митигация: начать с эвристического matching только для отчёта, не для построения маршрута.

