use std::collections::BTreeMap;
use std::env;
use std::process::ExitCode;

use kk_core::osm::{HighwayClass, OsmPack, SurfaceClass};
use serde::Serialize;

#[derive(Debug, Serialize)]
struct PackStats {
    source: String,
    format_version: u32,
    road_segments: usize,
    total_length_km: f64,
    by_highway: BTreeMap<HighwayClass, ClassStats>,
    by_surface: BTreeMap<SurfaceClass, ClassStats>,
}

#[derive(Debug, Default, Serialize)]
struct ClassStats {
    segments: usize,
    length_km: f64,
}

fn main() -> ExitCode {
    match run() {
        Ok(()) => ExitCode::SUCCESS,
        Err(error) => {
            eprintln!("error: {error}");
            ExitCode::FAILURE
        }
    }
}

fn run() -> Result<(), Box<dyn std::error::Error>> {
    let path = env::args().nth(1).ok_or("missing .kkosm path")?;
    let pack = OsmPack::load_bincode(path)?;

    let mut by_highway: BTreeMap<HighwayClass, ClassStats> = BTreeMap::new();
    let mut by_surface: BTreeMap<SurfaceClass, ClassStats> = BTreeMap::new();

    for segment in &pack.road_segments {
        let length_km = f64::from(segment.length_m) / 1000.0;

        let highway_stats = by_highway.entry(segment.highway).or_default();
        highway_stats.segments += 1;
        highway_stats.length_km += length_km;

        let surface_stats = by_surface.entry(segment.surface).or_default();
        surface_stats.segments += 1;
        surface_stats.length_km += length_km;
    }

    let stats = PackStats {
        source: pack.meta.source,
        format_version: pack.meta.format_version,
        road_segments: pack.meta.road_segments,
        total_length_km: pack.meta.total_length_m / 1000.0,
        by_highway,
        by_surface,
    };

    println!("{}", serde_json::to_string_pretty(&stats)?);

    Ok(())
}
