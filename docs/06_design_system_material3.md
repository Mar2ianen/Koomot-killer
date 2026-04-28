# Material 3 Design System

## Общий вайб

Приложение должно ощущаться как быстрый инженерный инструмент, а не как тяжёлая социальная платформа.

Ключевые ощущения:

- чисто;
- быстро;
- локально;
- технично;
- без «подписочного маркетинга»;
- данные важнее украшательства.

## Тема

Основной вариант: тёмная тема с Material 3 surface layering.

Причины:

- карты и треки хорошо читаются;
- удобно для вечернего планирования;
- меньше визуального шума;
- подходит под desktop-first утилиту.

Светлая тема должна быть позже, но токены проектируем сразу.

## Цветовые роли

```text
Primary:
  акцент маршрута, основные кнопки, выбранные элементы

Secondary:
  вспомогательные действия, чипы, фильтры

Tertiary:
  высота, аналитика, специальные подсветки

Surface:
  фон приложения, панели, карточки

Error:
  критичные предупреждения маршрута

Warning:
  сомнительные участки, GPS gaps, крутые спуски
```

## Навигационная структура

### Desktop

```text
NavigationRail слева
  - Library
  - Open GPX
  - Inspect
  - Settings

Main map area
  - большая карта
  - route overlay
  - floating controls

Right inspector panel
  - stats
  - warnings
  - segments

Bottom sheet / panel
  - elevation profile
```

### Mobile

```text
Top app bar
  - название маршрута
  - меню

Map-first screen
  - карта занимает большую часть
  - нижний draggable sheet

Bottom navigation
  - Map
  - Stats
  - Segments
  - Export
```

## Компоненты

### Stats cards

Карточки с главными числами:

- distance;
- elevation gain;
- elevation loss;
- max elevation;
- points;
- warnings.

### Chips

Чипы для быстрых статусов:

- GPX;
- Elevation OK;
- Surface unknown;
- Gravel-ready;
- Needs review.

### Warning list

Список предупреждений с severity:

- info;
- warning;
- critical.

### Segment table

Таблица или список:

- km range;
- distance;
- gain;
- avg grade;
- difficulty.

### Elevation profile

График высоты должен быть одним из центральных элементов MVP.

Требования:

- интерактивный hover/drag;
- связь с точкой на карте;
- подсветка сложных участков;
- later: overlay по покрытию.

## Типографика

Стиль: Material 3, но без избыточной «мобильной игрушечности».

- Display/Headline: редкое использование, только для пустых состояний и onboarding.
- Title: заголовки панелей.
- Body: описания и предупреждения.
- Label: чипы, кнопки, метрики.
- Monospace: опционально для GPX/OSM debug-информации.

## Layout principles

- Карта всегда главный объект.
- Статистика должна быть видна без прокрутки.
- Предупреждения не должны кричать, пока не критичные.
- На desktop правая панель постоянная.
- На mobile аналитика уходит в bottom sheet.
- Не перегружать первый экран.

## Empty state

Пустой экран должен сразу объяснять сценарий:

> Drop GPX here or open a file

Дополнительно:

- sample route;
- recent files;
- ссылка на docs.

## Design refs

Сгенерированные мокапы лежат в `design_refs/`:

- `material3_design_refs.html` — интерактивный HTML с четырьмя референсами: desktop viewer, route inspector, import empty state, mobile detail.

