# Rust OSM parser baseline

This is the first Rust-side building block for route analysis.

The goal is not routing yet. The goal is to convert a regional `.osm.pbf` file into a compact local `.kkosm` road pack that can later be used for GPX matching, surface analysis and smart segmentation.

## Pipeline

```text
Geofabrik .osm.pbf
  -> kk_osm_pack
  -> region.kkosm
  -> GPX matcher later
  -> surface/highway/turn based segments
```

## Current scope

The parser reads OSM ways with `highway=*`, loads their dependent nodes, normalizes the most important tags and splits ways into simple road segments.

Stored per segment:

- `way_id`
- segment index inside the way
- from/to coordinates as `lat/lon * 1e7`
- bbox
- length in meters
- highway class
- surface class
- surface source/confidence hint
- smoothness
- access
- bicycle access
- optional way name

## Build

```bash
cargo check -p kk_core
```

## Create a local OSM pack

```bash
cargo run -p kk_core --bin kk_osm_pack -- \
  --input data/local/spb.osm.pbf \
  --output data/local/spb.kkosm
```

Short form:

```bash
cargo run -p kk_core --bin kk_osm_pack -- \
  data/local/spb.osm.pbf \
  data/local/spb.kkosm
```

## Inspect pack stats

```bash
cargo run -p kk_core --bin kk_osm_stats -- data/local/spb.kkosm
```

The stats command prints JSON with counts and length grouped by highway and surface class.

## Next steps

1. Add an R-tree over road segment bounding boxes.
2. Add GPX step to nearest OSM segment matching.
3. Score candidates by distance and bearing.
4. Aggregate matched steps into human-readable route segments.
5. Expose the analyzer to Flutter through FFI.

## Notes

`.kkosm` is currently a bincode file. That is good enough for early development and much faster to load than reparsing PBF every time.

Later we can move to a mmap-friendly format with `rkyv` or a custom zero-copy layout.
