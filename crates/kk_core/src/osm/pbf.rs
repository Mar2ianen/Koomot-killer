use std::collections::HashMap;
use std::fs::File;
use std::path::{Path, PathBuf};

use osmpbfreader::{NodeId, OsmObj, OsmPbfReader, Tags};
use thiserror::Error;

use crate::geo::{haversine_meters, BBox, PackedPoint};
use crate::osm::model::{OsmPack, OsmPackMeta, RoadSegment};
use crate::osm::tags::{normalize_access, normalize_highway, normalize_smoothness, normalize_surface};

#[derive(Debug, Clone)]
pub struct PbfImportConfig {
    pub source_path: PathBuf,
}

#[derive(Debug, Clone)]
pub struct PbfImportReport {
    pub source: String,
    pub highway_ways: usize,
    pub road_segments: usize,
    pub skipped_degenerate_segments: usize,
    pub skipped_missing_nodes: usize,
    pub total_length_m: f64,
}

#[derive(Debug, Error)]
pub enum PbfImportError {
    #[error("I/O error: {0}")]
    Io(#[from] std::io::Error),

    #[error("OSM PBF reader error: {0}")]
    Pbf(#[from] osmpbfreader::Error),
}

pub fn import_osm_pbf(path: impl AsRef<Path>) -> Result<(OsmPack, PbfImportReport), PbfImportError> {
    let source_path = path.as_ref().to_path_buf();
    let file = File::open(&source_path)?;
    let mut reader = OsmPbfReader::new(file);

    let objects = reader.get_objs_and_deps(|obj| match obj {
        OsmObj::Way(way) => is_candidate_highway_way(&way.tags),
        _ => false,
    })?;

    let mut nodes: HashMap<NodeId, PackedPoint> = HashMap::new();
    let mut highway_ways = Vec::new();

    for object in objects.values() {
        match object {
            OsmObj::Node(node) => {
                nodes.insert(node.id, PackedPoint::from_degrees(node.lat(), node.lon()));
            }
            OsmObj::Way(way) if is_candidate_highway_way(&way.tags) => {
                highway_ways.push(way.clone());
            }
            _ => {}
        }
    }

    let mut road_segments = Vec::new();
    let mut skipped_degenerate_segments = 0usize;
    let mut skipped_missing_nodes = 0usize;
    let mut total_length_m = 0.0;

    for way in &highway_ways {
        let highway_text = tag_value(&way.tags, "highway");
        let highway = normalize_highway(highway_text.as_deref());
        let surface_text = tag_value(&way.tags, "surface");
        let tracktype_text = tag_value(&way.tags, "tracktype");
        let (surface, surface_source) =
            normalize_surface(surface_text.as_deref(), tracktype_text.as_deref(), highway);
        let smoothness = normalize_smoothness(tag_value(&way.tags, "smoothness").as_deref());
        let access = normalize_access(tag_value(&way.tags, "access").as_deref());
        let bicycle = normalize_access(tag_value(&way.tags, "bicycle").as_deref());
        let name = tag_value(&way.tags, "name");

        for (index, pair) in way.nodes.windows(2).enumerate() {
            let Some(from) = nodes.get(&pair[0]).copied() else {
                skipped_missing_nodes += 1;
                continue;
            };
            let Some(to) = nodes.get(&pair[1]).copied() else {
                skipped_missing_nodes += 1;
                continue;
            };

            let length_m = haversine_meters(from, to);

            if length_m < 0.5 {
                skipped_degenerate_segments += 1;
                continue;
            }

            total_length_m += length_m;

            road_segments.push(RoadSegment {
                way_id: way.id.0,
                way_segment_index: index as u32,
                from,
                to,
                bbox: BBox::from_points(from, to),
                length_m: length_m as f32,
                highway,
                surface,
                surface_source,
                smoothness,
                access,
                bicycle,
                name: name.clone(),
            });
        }
    }

    let source = source_path.display().to_string();
    let report = PbfImportReport {
        source: source.clone(),
        highway_ways: highway_ways.len(),
        road_segments: road_segments.len(),
        skipped_degenerate_segments,
        skipped_missing_nodes,
        total_length_m,
    };

    let pack = OsmPack {
        meta: OsmPackMeta {
            format_version: OsmPack::FORMAT_VERSION,
            source,
            road_segments: road_segments.len(),
            total_length_m,
        },
        road_segments,
    };

    Ok((pack, report))
}

fn is_candidate_highway_way(tags: &Tags) -> bool {
    let Some(highway) = tags.get("highway") else {
        return false;
    };

    !matches!(
        highway.as_str(),
        "construction" | "proposed" | "razed" | "bus_stop" | "platform" | "elevator"
    )
}

fn tag_value(tags: &Tags, key: &str) -> Option<String> {
    tags.get(key).map(ToString::to_string).filter(|value| !value.is_empty())
}
