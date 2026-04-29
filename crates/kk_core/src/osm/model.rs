use serde::{Deserialize, Serialize};

use crate::geo::{BBox, PackedPoint};

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub enum HighwayClass {
    Motorway,
    Trunk,
    Primary,
    Secondary,
    Tertiary,
    Unclassified,
    Residential,
    LivingStreet,
    Service,
    Track,
    Path,
    Footway,
    Cycleway,
    Pedestrian,
    Steps,
    Unknown,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub enum SurfaceClass {
    Asphalt,
    Paved,
    Concrete,
    PavingStones,
    Compacted,
    FineGravel,
    Gravel,
    Dirt,
    Ground,
    Sand,
    Grass,
    Wood,
    Unknown,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub enum SurfaceSource {
    ExplicitSurfaceTag,
    InferredFromTracktype,
    InferredFromHighway,
    Missing,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub enum SmoothnessClass {
    Excellent,
    Good,
    Intermediate,
    Bad,
    VeryBad,
    Horrible,
    VeryHorrible,
    Impassable,
    Unknown,
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, PartialOrd, Ord, Hash, Serialize, Deserialize)]
pub enum AccessClass {
    Yes,
    Permissive,
    Destination,
    Private,
    No,
    Unknown,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct RoadSegment {
    pub way_id: i64,
    pub way_segment_index: u32,
    pub from: PackedPoint,
    pub to: PackedPoint,
    pub bbox: BBox,
    pub length_m: f32,
    pub highway: HighwayClass,
    pub surface: SurfaceClass,
    pub surface_source: SurfaceSource,
    pub smoothness: SmoothnessClass,
    pub access: AccessClass,
    pub bicycle: AccessClass,
    pub name: Option<String>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct OsmPackMeta {
    pub format_version: u32,
    pub source: String,
    pub road_segments: usize,
    pub total_length_m: f64,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct OsmPack {
    pub meta: OsmPackMeta,
    pub road_segments: Vec<RoadSegment>,
}

impl OsmPack {
    pub const FORMAT_VERSION: u32 = 1;
}
