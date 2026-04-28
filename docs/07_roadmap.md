# Roadmap

## v0.1 Route Viewer

Цель: открыть GPX, показать маршрут и статистику.

Фичи:

- GPX import;
- route polyline;
- bbox/auto zoom;
- distance;
- elevation gain/loss;
- elevation profile;
- km segments;
- warnings;
- GPX export.

## v0.2 OSM Surface Analyzer

Цель: понять, по чему едет маршрут.

Фичи:

- OSM PBF import по региону;
- matching GPX к OSM ways;
- highway/surface/tracktype/smoothness;
- unknown surface ratio;
- access/private/bicycle flags;
- отчёт по покрытию.

## v0.3 Route Editor

Цель: минимальная ручная правка маршрутов.

Фичи:

- удаление точек;
- split/merge tracks;
- drag control points;
- undo/redo;
- route versions;
- export edited GPX.

## v0.4 Rust Routing Prototype

Цель: первый собственный роутинг.

Фичи:

- OSM .pbf -> graph;
- osm4routing2 extractor;
- fast_paths graph;
- snap start/end;
- road/gravel profiles;
- route result on map.

## v0.5 Gravel Profile Router

Цель: профильный гревел-роутер.

Фичи:

- gravel_fast;
- gravel_safe;
- road_endurance;
- avoid_primary;
- avoid_unknown_surface;
- tire-fit scoring;
- warnings before export.

## v0.6 Offline Packs

Цель: офлайн-регионы.

Фичи:

- PMTiles region packs;
- local route library;
- cached analyses;
- offline map style;
- package manager for regions.

## v1.0

Цель: стабильный инструмент для ежедневного использования.

Фичи:

- route library;
- GPX viewer/editor;
- OSM analyzer;
- basic routing;
- offline regions;
- desktop/mobile/web builds;
- docs and reproducible data pipeline.

