use crate::gpx_parser::parse_gpx;
use crate::osm_pack_bridge::{
    build_osm_pack_bytes_from_pbf as build_osm_pack,
    build_osm_pack_stats_from_pbf_path as build_osm_pack_stats_from_path,
    inspect_kkosm_bytes as inspect_kkosm, inspect_kkosm_path as inspect_kkosm_file,
};

#[derive(Debug, Clone)]
pub struct RouteAnalysisDto {
    pub name: String,
    pub points: Vec<RoutePointDto>,
    pub distance_km: f64,
    pub elevation_gain_m: f64,
    pub elevation_loss_m: f64,
    pub min_elevation_m: f64,
    pub max_elevation_m: f64,
    pub bounds: RouteBoundsDto,
    pub parts: Vec<RoutePartDto>,
    pub segments: Vec<RouteSegmentDto>,
    pub warnings: Vec<RouteWarningDto>,
}

#[derive(Debug, Clone)]
pub struct RouteBoundsDto {
    pub min_lat: f64,
    pub min_lon: f64,
    pub max_lat: f64,
    pub max_lon: f64,
}

#[derive(Debug, Clone)]
pub struct RoutePartDto {
    pub index: u32,
    pub start_index: u32,
    pub end_index: u32,
    pub point_count: u32,
}

#[derive(Debug, Clone)]
pub struct RoutePointDto {
    pub lat: f64,
    pub lon: f64,
    pub elevation_m: f64,
}

#[derive(Debug, Clone)]
pub struct RouteSegmentDto {
    pub title: String,
    pub distance_km: f64,
    pub elevation_gain_m: f64,
    pub surface_label: String,
    pub warning_level: String,
}

#[derive(Debug, Clone)]
pub struct RouteWarningDto {
    pub title: String,
    pub description: String,
    pub icon: String,
}

pub fn parse_gpx_bytes(bytes: Vec<u8>, fallback_name: String) -> Result<RouteAnalysisDto, String> {
    parse_gpx(&bytes, &fallback_name).map_err(|error| error.to_string())
}

#[derive(Debug, Clone)]
pub struct OsmPackBuildDto {
    pub pack_bytes: Vec<u8>,
    pub stats: OsmPackStatsDto,
    pub report: OsmImportReportDto,
}

#[derive(Debug, Clone)]
pub struct OsmImportReportDto {
    pub source: String,
    pub highway_ways: u32,
    pub road_segments: u32,
    pub skipped_degenerate_segments: u32,
    pub skipped_missing_nodes: u32,
    pub total_length_km: f64,
}

#[derive(Debug, Clone)]
pub struct OsmPackStatsDto {
    pub source: String,
    pub format_version: u32,
    pub road_segments: u32,
    pub total_length_km: f64,
    pub by_highway: Vec<OsmClassStatsDto>,
    pub by_surface: Vec<OsmClassStatsDto>,
}

#[derive(Debug, Clone)]
pub struct OsmClassStatsDto {
    pub class_name: String,
    pub segments: u32,
    pub length_km: f64,
}

pub fn build_osm_pack_bytes_from_pbf(
    bytes: Vec<u8>,
    source_name: String,
) -> Result<OsmPackBuildDto, String> {
    build_osm_pack(bytes, source_name).map_err(|error| error.to_string())
}

pub fn inspect_kkosm_bytes(bytes: Vec<u8>) -> Result<OsmPackStatsDto, String> {
    inspect_kkosm(bytes).map_err(|error| error.to_string())
}

pub fn build_osm_pack_stats_from_pbf_path(
    path: String,
    source_name: String,
) -> Result<OsmPackStatsDto, String> {
    build_osm_pack_stats_from_path(path, source_name).map_err(|error| error.to_string())
}

pub fn inspect_kkosm_path(path: String) -> Result<OsmPackStatsDto, String> {
    inspect_kkosm_file(path).map_err(|error| error.to_string())
}
