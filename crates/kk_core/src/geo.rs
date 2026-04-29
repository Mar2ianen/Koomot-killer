use serde::{Deserialize, Serialize};

const EARTH_RADIUS_M: f64 = 6_371_000.0;

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct PackedPoint {
    pub lat_e7: i32,
    pub lon_e7: i32,
}

impl PackedPoint {
    pub fn from_degrees(lat: f64, lon: f64) -> Self {
        Self {
            lat_e7: (lat * 10_000_000.0).round() as i32,
            lon_e7: (lon * 10_000_000.0).round() as i32,
        }
    }

    pub fn lat(self) -> f64 {
        f64::from(self.lat_e7) / 10_000_000.0
    }

    pub fn lon(self) -> f64 {
        f64::from(self.lon_e7) / 10_000_000.0
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Serialize, Deserialize)]
pub struct BBox {
    pub min_lat_e7: i32,
    pub min_lon_e7: i32,
    pub max_lat_e7: i32,
    pub max_lon_e7: i32,
}

impl BBox {
    pub fn from_points(a: PackedPoint, b: PackedPoint) -> Self {
        Self {
            min_lat_e7: a.lat_e7.min(b.lat_e7),
            min_lon_e7: a.lon_e7.min(b.lon_e7),
            max_lat_e7: a.lat_e7.max(b.lat_e7),
            max_lon_e7: a.lon_e7.max(b.lon_e7),
        }
    }

    pub fn expand_e7(self, margin_e7: i32) -> Self {
        Self {
            min_lat_e7: self.min_lat_e7 - margin_e7,
            min_lon_e7: self.min_lon_e7 - margin_e7,
            max_lat_e7: self.max_lat_e7 + margin_e7,
            max_lon_e7: self.max_lon_e7 + margin_e7,
        }
    }
}

pub fn haversine_meters(a: PackedPoint, b: PackedPoint) -> f64 {
    let lat1 = a.lat().to_radians();
    let lat2 = b.lat().to_radians();
    let d_lat = (b.lat() - a.lat()).to_radians();
    let d_lon = (b.lon() - a.lon()).to_radians();

    let h = (d_lat / 2.0).sin().powi(2)
        + lat1.cos() * lat2.cos() * (d_lon / 2.0).sin().powi(2);

    2.0 * EARTH_RADIUS_M * h.sqrt().atan2((1.0 - h).sqrt())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn packed_point_roundtrips_degrees() {
        let point = PackedPoint::from_degrees(59.93863, 30.31413);

        assert!((point.lat() - 59.93863).abs() < 0.000001);
        assert!((point.lon() - 30.31413).abs() < 0.000001);
    }

    #[test]
    fn distance_is_reasonable_for_short_segment() {
        let a = PackedPoint::from_degrees(59.93863, 30.31413);
        let b = PackedPoint::from_degrees(59.93963, 30.31413);

        let distance = haversine_meters(a, b);

        assert!(distance > 100.0);
        assert!(distance < 120.0);
    }
}
