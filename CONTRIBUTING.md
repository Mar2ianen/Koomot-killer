# Contributing

The project is in an early planning/prototype stage. Keep changes small, practical and easy to review.

## Current direction

- Start with a fast local GPX viewer and route inspector.
- Keep heavy parsing and route analysis in Rust.
- Keep UI in Flutter.
- Use MapLibre and existing tile formats instead of writing a custom map renderer.
- Add routing only after the GPX viewer and analysis model are stable.

## Contribution rules

- Prefer small pull requests.
- Explain the user-facing value of the change.
- Avoid adding GPL/LGPL runtime dependencies unless there is a clear discussion first.
- Preserve OSM attribution requirements when working with map data.
- Do not use public OpenStreetMap tile servers as a bulk download or production backend.

## Code style

Rust code should be boring, explicit and testable. Flutter code should follow Material 3 patterns and keep business logic out of widgets where possible.

## License

Unless stated otherwise, contributions are accepted under `MIT OR Apache-2.0`.
