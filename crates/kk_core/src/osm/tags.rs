use crate::osm::model::{AccessClass, HighwayClass, SmoothnessClass, SurfaceClass, SurfaceSource};

pub fn normalize_highway(value: Option<&str>) -> HighwayClass {
    match value.unwrap_or_default() {
        "motorway" | "motorway_link" => HighwayClass::Motorway,
        "trunk" | "trunk_link" => HighwayClass::Trunk,
        "primary" | "primary_link" => HighwayClass::Primary,
        "secondary" | "secondary_link" => HighwayClass::Secondary,
        "tertiary" | "tertiary_link" => HighwayClass::Tertiary,
        "unclassified" => HighwayClass::Unclassified,
        "residential" => HighwayClass::Residential,
        "living_street" => HighwayClass::LivingStreet,
        "service" => HighwayClass::Service,
        "track" => HighwayClass::Track,
        "path" => HighwayClass::Path,
        "footway" => HighwayClass::Footway,
        "cycleway" => HighwayClass::Cycleway,
        "pedestrian" => HighwayClass::Pedestrian,
        "steps" => HighwayClass::Steps,
        _ => HighwayClass::Unknown,
    }
}

pub fn normalize_surface(
    surface: Option<&str>,
    tracktype: Option<&str>,
    highway: HighwayClass,
) -> (SurfaceClass, SurfaceSource) {
    if let Some(surface) = surface {
        let surface = match surface {
            "asphalt" => SurfaceClass::Asphalt,
            "paved" => SurfaceClass::Paved,
            "concrete" | "concrete:plates" | "concrete:lanes" => SurfaceClass::Concrete,
            "paving_stones" | "sett" | "cobblestone" | "unhewn_cobblestone" => {
                SurfaceClass::PavingStones
            }
            "compacted" => SurfaceClass::Compacted,
            "fine_gravel" => SurfaceClass::FineGravel,
            "gravel" | "pebblestone" => SurfaceClass::Gravel,
            "dirt" | "earth" | "mud" => SurfaceClass::Dirt,
            "ground" => SurfaceClass::Ground,
            "sand" => SurfaceClass::Sand,
            "grass" => SurfaceClass::Grass,
            "wood" => SurfaceClass::Wood,
            _ => SurfaceClass::Unknown,
        };

        return (surface, SurfaceSource::ExplicitSurfaceTag);
    }

    if let Some(tracktype) = tracktype {
        let surface = match tracktype {
            "grade1" => SurfaceClass::Compacted,
            "grade2" => SurfaceClass::Compacted,
            "grade3" => SurfaceClass::Gravel,
            "grade4" => SurfaceClass::Dirt,
            "grade5" => SurfaceClass::Ground,
            _ => SurfaceClass::Unknown,
        };

        if surface != SurfaceClass::Unknown {
            return (surface, SurfaceSource::InferredFromTracktype);
        }
    }

    let inferred = match highway {
        HighwayClass::Motorway
        | HighwayClass::Trunk
        | HighwayClass::Primary
        | HighwayClass::Secondary
        | HighwayClass::Tertiary
        | HighwayClass::Residential
        | HighwayClass::LivingStreet
        | HighwayClass::Service
        | HighwayClass::Cycleway => SurfaceClass::Asphalt,
        _ => SurfaceClass::Unknown,
    };

    if inferred == SurfaceClass::Unknown {
        (SurfaceClass::Unknown, SurfaceSource::Missing)
    } else {
        (inferred, SurfaceSource::InferredFromHighway)
    }
}

pub fn normalize_smoothness(value: Option<&str>) -> SmoothnessClass {
    match value.unwrap_or_default() {
        "excellent" => SmoothnessClass::Excellent,
        "good" => SmoothnessClass::Good,
        "intermediate" => SmoothnessClass::Intermediate,
        "bad" => SmoothnessClass::Bad,
        "very_bad" => SmoothnessClass::VeryBad,
        "horrible" => SmoothnessClass::Horrible,
        "very_horrible" => SmoothnessClass::VeryHorrible,
        "impassable" => SmoothnessClass::Impassable,
        _ => SmoothnessClass::Unknown,
    }
}

pub fn normalize_access(value: Option<&str>) -> AccessClass {
    match value.unwrap_or_default() {
        "yes" | "designated" | "official" => AccessClass::Yes,
        "permissive" => AccessClass::Permissive,
        "destination" | "customers" | "delivery" => AccessClass::Destination,
        "private" => AccessClass::Private,
        "no" => AccessClass::No,
        _ => AccessClass::Unknown,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn explicit_surface_wins() {
        let highway = normalize_highway(Some("track"));
        let (surface, source) = normalize_surface(Some("gravel"), Some("grade1"), highway);

        assert_eq!(surface, SurfaceClass::Gravel);
        assert_eq!(source, SurfaceSource::ExplicitSurfaceTag);
    }

    #[test]
    fn tracktype_is_used_when_surface_is_missing() {
        let highway = normalize_highway(Some("track"));
        let (surface, source) = normalize_surface(None, Some("grade3"), highway);

        assert_eq!(surface, SurfaceClass::Gravel);
        assert_eq!(source, SurfaceSource::InferredFromTracktype);
    }
}
