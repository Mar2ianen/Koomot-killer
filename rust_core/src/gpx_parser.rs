use std::io::{BufReader, Cursor};

use gpx::{read, Gpx};
use thiserror::Error;

use crate::api::{
    RouteAnalysisDto, RouteBoundsDto, RoutePartDto, RoutePointDto, RouteSegmentDto, RouteWarningDto,
};

const MAX_GPX_BYTES: usize = 50 * 1024 * 1024;

#[derive(Debug, Error)]
pub enum GpxParseError {
    #[error("failed to read GPX XML: {0}")]
    Read(#[from] gpx::errors::GpxError),

    #[error("GPX does not contain enough valid coordinates")]
    NotEnoughPoints,

    #[error("GPX file is too large: {size} bytes, max supported size is {max} bytes")]
    FileTooLarge { size: usize, max: usize },
}

pub fn parse_gpx(bytes: &[u8], fallback_name: &str) -> Result<RouteAnalysisDto, GpxParseError> {
    if bytes.len() > MAX_GPX_BYTES {
        return Err(GpxParseError::FileTooLarge {
            size: bytes.len(),
            max: MAX_GPX_BYTES,
        });
    }

    let cursor = Cursor::new(bytes);
    let reader = BufReader::new(cursor);
    let gpx = read(reader)?;

    let parsed = extract_route_parts(&gpx);

    if parsed.points.len() < 2 {
        return Err(GpxParseError::NotEnoughPoints);
    }

    let stats = calculate_stats(&parsed.parts);
    let segments = build_segments(&parsed.parts);
    let bounds = calculate_bounds(&parsed.points).ok_or(GpxParseError::NotEnoughPoints)?;
    let parts = build_route_parts(&parsed.parts);

    Ok(RouteAnalysisDto {
        name: extract_route_name(&gpx, fallback_name),
        points: parsed.points,
        distance_km: stats.distance_m / 1000.0,
        elevation_gain_m: stats.elevation_gain_m,
        elevation_loss_m: stats.elevation_loss_m,
        min_elevation_m: stats.min_elevation_m,
        max_elevation_m: stats.max_elevation_m,
        bounds,
        parts,
        segments,
        warnings: build_warnings(
            parsed.has_missing_elevation,
            stats.point_count,
            parsed.parts.len(),
        ),
    })
}

fn extract_route_parts(gpx: &Gpx) -> ParsedRoute {
    let mut parts = Vec::new();
    let mut has_missing_elevation = false;

    for track in &gpx.tracks {
        for segment in &track.segments {
            let parsed = segment
                .points
                .iter()
                .map(|point| {
                    let geo_point = point.point();
                    let elevation = point.elevation;

                    (
                        RoutePointDto {
                            lat: geo_point.y(),
                            lon: geo_point.x(),
                            elevation_m: elevation.unwrap_or(0.0),
                        },
                        elevation.is_none(),
                    )
                })
                .collect::<Vec<_>>();

            let points = fill_missing_elevation(parsed, &mut has_missing_elevation);

            if points.len() >= 2 {
                parts.push(points);
            }
        }
    }

    if parts.is_empty() {
        for route in &gpx.routes {
            let parsed = route
                .points
                .iter()
                .map(|point| {
                    let geo_point = point.point();
                    let elevation = point.elevation;

                    (
                        RoutePointDto {
                            lat: geo_point.y(),
                            lon: geo_point.x(),
                            elevation_m: elevation.unwrap_or(0.0),
                        },
                        elevation.is_none(),
                    )
                })
                .collect::<Vec<_>>();

            let points = fill_missing_elevation(parsed, &mut has_missing_elevation);

            if points.len() >= 2 {
                parts.push(points);
            }
        }
    }

    if parts.is_empty() && gpx.waypoints.len() >= 2 {
        let parsed = gpx
            .waypoints
            .iter()
            .map(|point| {
                let geo_point = point.point();
                let elevation = point.elevation;

                (
                    RoutePointDto {
                        lat: geo_point.y(),
                        lon: geo_point.x(),
                        elevation_m: elevation.unwrap_or(0.0),
                    },
                    elevation.is_none(),
                )
            })
            .collect::<Vec<_>>();

        let points = fill_missing_elevation(parsed, &mut has_missing_elevation);

        if points.len() >= 2 {
            parts.push(points);
        }
    }

    let points = parts
        .iter()
        .flatten()
        .cloned()
        .collect::<Vec<RoutePointDto>>();

    ParsedRoute {
        parts,
        points,
        has_missing_elevation,
    }
}

fn fill_missing_elevation(
    parsed: Vec<(RoutePointDto, bool)>,
    has_missing_elevation: &mut bool,
) -> Vec<RoutePointDto> {
    let mut last_elevation = 0.0;
    let mut points = Vec::with_capacity(parsed.len());

    for (mut point, elevation_missing) in parsed {
        if elevation_missing {
            *has_missing_elevation = true;
            point.elevation_m = last_elevation;
        } else {
            last_elevation = point.elevation_m;
        }

        points.push(point);
    }

    points
}

fn extract_route_name(gpx: &Gpx, fallback_name: &str) -> String {
    if let Some(name) = gpx
        .tracks
        .iter()
        .find_map(|track| track.name.as_ref())
        .filter(|name| !name.trim().is_empty())
    {
        return name.trim().to_owned();
    }

    if let Some(name) = gpx
        .routes
        .iter()
        .find_map(|route| route.name.as_ref())
        .filter(|name| !name.trim().is_empty())
    {
        return name.trim().to_owned();
    }

    if let Some(name) = gpx
        .metadata
        .as_ref()
        .and_then(|metadata| metadata.name.as_ref())
        .filter(|name| !name.trim().is_empty())
    {
        return name.trim().to_owned();
    }

    let without_extension = fallback_name
        .strip_suffix(".gpx")
        .or_else(|| fallback_name.strip_suffix(".GPX"))
        .unwrap_or(fallback_name)
        .trim();

    if without_extension.is_empty() {
        "Imported GPX route".to_owned()
    } else {
        without_extension.to_owned()
    }
}

fn calculate_stats(parts: &[Vec<RoutePointDto>]) -> RouteStats {
    let mut distance_m = 0.0;
    let mut elevation_gain_m = 0.0;
    let mut elevation_loss_m = 0.0;
    let mut point_count = 0usize;

    let first = parts.iter().flatten().next();
    let mut min_elevation_m = first.map_or(0.0, |point| point.elevation_m);
    let mut max_elevation_m = first.map_or(0.0, |point| point.elevation_m);

    for points in parts {
        point_count += points.len();

        for point in points {
            min_elevation_m = min_elevation_m.min(point.elevation_m);
            max_elevation_m = max_elevation_m.max(point.elevation_m);
        }

        for pair in points.windows(2) {
            let previous = &pair[0];
            let current = &pair[1];

            distance_m += distance_meters(previous, current);

            let elevation_delta = current.elevation_m - previous.elevation_m;

            if elevation_delta > 0.3 {
                elevation_gain_m += elevation_delta;
            } else if elevation_delta < -0.3 {
                elevation_loss_m += elevation_delta.abs();
            }
        }
    }

    RouteStats {
        distance_m,
        elevation_gain_m,
        elevation_loss_m,
        min_elevation_m,
        max_elevation_m,
        point_count,
    }
}

fn build_segments(parts: &[Vec<RoutePointDto>]) -> Vec<RouteSegmentDto> {
    const TARGET_SEGMENT_DISTANCE_M: f64 = 5_000.0;

    let mut segments = Vec::new();
    let mut total_distance_m = 0.0;
    let mut segment_start_m = 0.0;
    let mut segment_distance_m = 0.0;
    let mut segment_gain_m = 0.0;

    for points in parts {
        for pair in points.windows(2) {
            let previous = &pair[0];
            let current = &pair[1];

            let step_distance_m = distance_meters(previous, current);

            if step_distance_m <= 0.0 {
                continue;
            }

            let elevation_delta = current.elevation_m - previous.elevation_m;
            let mut remaining_step_m = step_distance_m;

            while remaining_step_m > 0.0 {
                let remaining_segment_m = TARGET_SEGMENT_DISTANCE_M - segment_distance_m;
                let taken_m = remaining_step_m.min(remaining_segment_m);
                let taken_fraction = taken_m / step_distance_m;

                segment_distance_m += taken_m;
                total_distance_m += taken_m;

                if elevation_delta > 0.3 {
                    segment_gain_m += elevation_delta * taken_fraction;
                }

                remaining_step_m -= taken_m;

                if segment_distance_m >= TARGET_SEGMENT_DISTANCE_M - 0.001 {
                    flush_segment(
                        &mut segments,
                        &mut segment_start_m,
                        &mut segment_distance_m,
                        &mut segment_gain_m,
                        total_distance_m,
                    );
                }
            }
        }
    }

    flush_segment(
        &mut segments,
        &mut segment_start_m,
        &mut segment_distance_m,
        &mut segment_gain_m,
        total_distance_m,
    );

    segments
}

fn flush_segment(
    segments: &mut Vec<RouteSegmentDto>,
    segment_start_m: &mut f64,
    segment_distance_m: &mut f64,
    segment_gain_m: &mut f64,
    total_distance_m: f64,
) {
    if *segment_distance_m <= 1.0 {
        return;
    }

    segments.push(RouteSegmentDto {
        title: format!(
            "{:.1}-{:.1} km",
            *segment_start_m / 1000.0,
            total_distance_m / 1000.0
        ),
        distance_km: *segment_distance_m / 1000.0,
        elevation_gain_m: *segment_gain_m,
        surface_label: "GPX only".to_owned(),
        warning_level: "info".to_owned(),
    });

    *segment_start_m = total_distance_m;
    *segment_distance_m = 0.0;
    *segment_gain_m = 0.0;
}

fn build_warnings(
    has_missing_elevation: bool,
    point_count: usize,
    route_part_count: usize,
) -> Vec<RouteWarningDto> {
    let mut warnings = vec![RouteWarningDto {
        title: "GPX route loaded".to_owned(),
        description: format!("{point_count} points parsed in Rust on device."),
        icon: "📍".to_owned(),
    }];

    if route_part_count > 1 {
        warnings.push(RouteWarningDto {
            title: "Multiple GPX track segments".to_owned(),
            description: format!(
                "{route_part_count} track parts detected. Gaps are not counted as route distance."
            ),
            icon: "🧩".to_owned(),
        });
    }

    if has_missing_elevation {
        warnings.push(RouteWarningDto {
            title: "Some elevation data is missing".to_owned(),
            description: "Missing elevation points were filled from the previous known value."
                .to_owned(),
            icon: "⛰️".to_owned(),
        });
    }

    warnings.push(RouteWarningDto {
        title: "OSM analysis is not connected yet".to_owned(),
        description: "Surface, road type and access checks will be added in the next stage."
            .to_owned(),
        icon: "🧭".to_owned(),
    });

    warnings
}

fn distance_meters(a: &RoutePointDto, b: &RoutePointDto) -> f64 {
    const EARTH_RADIUS_M: f64 = 6_371_000.0;

    let lat1 = a.lat.to_radians();
    let lat2 = b.lat.to_radians();
    let d_lat = (b.lat - a.lat).to_radians();
    let d_lon = (b.lon - a.lon).to_radians();

    let h = (d_lat / 2.0).sin().powi(2) + lat1.cos() * lat2.cos() * (d_lon / 2.0).sin().powi(2);

    2.0 * EARTH_RADIUS_M * h.sqrt().atan2((1.0 - h).sqrt())
}

fn calculate_bounds(points: &[RoutePointDto]) -> Option<RouteBoundsDto> {
    let first = points
        .iter()
        .find(|point| point.lat.is_finite() && point.lon.is_finite())?;

    let mut min_lat = first.lat;
    let mut min_lon = first.lon;
    let mut max_lat = first.lat;
    let mut max_lon = first.lon;

    for point in points {
        if !point.lat.is_finite() || !point.lon.is_finite() {
            continue;
        }

        min_lat = min_lat.min(point.lat);
        min_lon = min_lon.min(point.lon);
        max_lat = max_lat.max(point.lat);
        max_lon = max_lon.max(point.lon);
    }

    Some(RouteBoundsDto {
        min_lat,
        min_lon,
        max_lat,
        max_lon,
    })
}

fn build_route_parts(parts: &[Vec<RoutePointDto>]) -> Vec<RoutePartDto> {
    let mut cursor = 0usize;

    parts
        .iter()
        .enumerate()
        .map(|(index, part)| {
            let start_index = cursor;
            cursor += part.len();

            RoutePartDto {
                index: index as u32,
                start_index: start_index as u32,
                end_index: cursor as u32,
                point_count: part.len() as u32,
            }
        })
        .collect()
}

struct ParsedRoute {
    parts: Vec<Vec<RoutePointDto>>,
    points: Vec<RoutePointDto>,
    has_missing_elevation: bool,
}

struct RouteStats {
    distance_m: f64,
    elevation_gain_m: f64,
    elevation_loss_m: f64,
    min_elevation_m: f64,
    max_elevation_m: f64,
    point_count: usize,
}
