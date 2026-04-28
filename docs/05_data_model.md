# Data Model

## Основная модель

```rust
pub struct RouteAnalysis {
    pub name: Option<String>,
    pub distance_m: f64,
    pub elevation_gain_m: f64,
    pub elevation_loss_m: f64,
    pub min_ele_m: Option<f64>,
    pub max_ele_m: Option<f64>,
    pub points_count: usize,
    pub bbox: Option<BBox>,
    pub polyline: Vec<LatLonEle>,
    pub segments: Vec<RouteSegment>,
    pub warnings: Vec<RouteWarning>,
}
```

## Точка маршрута

```rust
pub struct LatLonEle {
    pub lat: f64,
    pub lon: f64,
    pub ele_m: Option<f64>,
    pub distance_from_start_m: f64,
}
```

## BBox

```rust
pub struct BBox {
    pub min_lat: f64,
    pub min_lon: f64,
    pub max_lat: f64,
    pub max_lon: f64,
}
```

## Сегмент

```rust
pub struct RouteSegment {
    pub index: usize,
    pub start_distance_m: f64,
    pub end_distance_m: f64,
    pub distance_m: f64,
    pub elevation_gain_m: f64,
    pub elevation_loss_m: f64,
    pub avg_grade_pct: Option<f64>,
    pub max_grade_pct: Option<f64>,
    pub difficulty: SegmentDifficulty,
}
```

## Сложность сегмента

```rust
pub enum SegmentDifficulty {
    Easy,
    Moderate,
    Hard,
    VeryHard,
    Unknown,
}
```

## Предупреждение

```rust
pub struct RouteWarning {
    pub kind: RouteWarningKind,
    pub message: String,
    pub distance_m: Option<f64>,
    pub severity: WarningSeverity,
}
```

## Типы предупреждений

```rust
pub enum RouteWarningKind {
    MissingElevation,
    LargeGpsGap,
    SteepClimb,
    SteepDescent,
    SuspiciousPoint,
    Unknown,
}
```

## Severity

```rust
pub enum WarningSeverity {
    Info,
    Warning,
    Critical,
}
```

## Будущая OSM-модель

```rust
pub struct OsmMatchedSegment {
    pub route_segment_index: usize,
    pub osm_way_id: i64,
    pub highway: Option<String>,
    pub surface: Option<String>,
    pub tracktype: Option<String>,
    pub smoothness: Option<String>,
    pub access: Option<String>,
    pub bicycle: Option<String>,
    pub confidence: f32,
}
```

## Будущая модель скоринга

```rust
pub struct RouteScore {
    pub gravel_score: f32,
    pub road_safety_score: f32,
    pub unknown_surface_ratio: f32,
    pub climbing_difficulty: f32,
    pub tire_fit: TireFit,
}
```

```rust
pub enum TireFit {
    Road28_32,
    AllRoad35_38,
    Gravel40_45,
    Gravel47Plus,
    Unknown,
}
```

