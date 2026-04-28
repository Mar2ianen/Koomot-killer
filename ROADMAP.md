# Roadmap

## v0.1 Route Viewer

- GPX import.
- MapLibre map view.
- Distance, elevation gain and elevation loss.
- Elevation profile.
- Segment table and basic warnings.

## v0.2 OSM Surface Analyzer

- Match GPX to OSM ways.
- Read `highway`, `surface`, `tracktype`, `smoothness`, `bicycle` and `access` tags.
- Estimate asphalt, gravel, dirt and unknown shares.
- Highlight suspicious route parts.

## v0.3 Route Editor

- Move, delete and split points.
- Join and crop tracks.
- Add waypoints and notes.
- Export cleaned GPX.

## v0.4 Rust Routing Prototype

- Import regional OSM PBF.
- Build compact road graph.
- Evaluate `osm4routing2`, `osmpbfreader`, `fast-osmpbf` and `fast_paths`.
- Add first road and gravel cost functions.

## v0.5 Gravel Profile Router

- Road, gravel fast, gravel safe and commute profiles.
- Route comparison.
- Human-readable route explanations.
