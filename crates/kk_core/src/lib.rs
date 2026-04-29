//! Core route and OSM analysis code for Komoot Killer.
//!
//! The first Rust milestone is not routing. It is a local OSM road pack builder:
//! `.osm.pbf -> .kkosm`. The Flutter app will later use that pack to match GPX
//! tracks against OSM ways and split routes by surface, road class and turns.

pub mod geo;
pub mod gpx;
pub mod osm;
