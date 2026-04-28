import 'package:latlong2/latlong.dart';

class RoutePoint {
  const RoutePoint({
    required this.position,
    required this.elevationM,
  });

  final LatLng position;
  final double elevationM;
}

class RouteSegment {
  const RouteSegment({
    required this.title,
    required this.distanceKm,
    required this.elevationGainM,
    required this.surfaceLabel,
    required this.warningLevel,
  });

  final String title;
  final double distanceKm;
  final double elevationGainM;
  final String surfaceLabel;
  final SegmentWarningLevel warningLevel;
}

enum SegmentWarningLevel { ok, info, warning }

class RouteWarning {
  const RouteWarning({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final String icon;
}

class RouteAnalysis {
  const RouteAnalysis({
    required this.name,
    required this.points,
    required this.distanceKm,
    required this.elevationGainM,
    required this.elevationLossM,
    required this.minElevationM,
    required this.maxElevationM,
    required this.segments,
    required this.warnings,
  });

  final String name;
  final List<RoutePoint> points;
  final double distanceKm;
  final double elevationGainM;
  final double elevationLossM;
  final double minElevationM;
  final double maxElevationM;
  final List<RouteSegment> segments;
  final List<RouteWarning> warnings;

  List<LatLng> get polyline => points.map((point) => point.position).toList();
}
