use crate::gpx_parser::parse_gpx;

#[derive(Debug, Clone)]
pub struct RouteAnalysisDto {
    pub name: String,
    pub points: Vec<RoutePointDto>,
    pub distance_km: f64,
    pub elevation_gain_m: f64,
    pub elevation_loss_m: f64,
    pub min_elevation_m: f64,
    pub max_elevation_m: f64,
    pub segments: Vec<RouteSegmentDto>,
    pub warnings: Vec<RouteWarningDto>,
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

pub fn parse_gpx_bytes(
    bytes: Vec<u8>,
    fallback_name: String,
) -> Result<RouteAnalysisDto, String> {
    parse_gpx(&bytes, &fallback_name).map_err(|error| error.to_string())
}
