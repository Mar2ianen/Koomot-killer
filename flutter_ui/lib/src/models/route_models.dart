import 'package:latlong2/latlong.dart';

class RoutePoint {
  const RoutePoint({
    required this.position,
    required this.elevationM,
  });

  final LatLng position;
  final double elevationM;
}

class RouteBounds {
  const RouteBounds({
    required this.minLat,
    required this.minLon,
    required this.maxLat,
    required this.maxLon,
  });

  final double minLat;
  final double minLon;
  final double maxLat;
  final double maxLon;

  LatLng get center => LatLng(
        (minLat + maxLat) / 2.0,
        (minLon + maxLon) / 2.0,
      );
}

class RoutePart {
  const RoutePart({
    required this.index,
    required this.startIndex,
    required this.endIndex,
    required this.pointCount,
  });

  /// 0-based route part index returned by the Rust parser.
  final int index;

  /// Inclusive index in [RouteAnalysis.points].
  final int startIndex;

  /// Exclusive index in [RouteAnalysis.points].
  final int endIndex;

  final int pointCount;
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
    this.bounds,
    this.parts = const [],
    required this.warnings,
  });

  final String name;
  final List<RoutePoint> points;
  final double distanceKm;
  final double elevationGainM;
  final double elevationLossM;
  final double minElevationM;
  final double maxElevationM;
  final RouteBounds? bounds;
  final List<RoutePart> parts;
  final List<RouteSegment> segments;
  final List<RouteWarning> warnings;

  List<LatLng> get polyline => points.map((point) => point.position).toList();

  List<List<LatLng>> get polylines {
    if (parts.isEmpty) {
      return [polyline];
    }

    return parts
        .map((part) {
          final start = part.startIndex.clamp(0, points.length);
          final end = part.endIndex.clamp(start, points.length);

          return points
              .sublist(start, end)
              .map((point) => point.position)
              .toList(growable: false);
        })
        .where((partPoints) => partPoints.length >= 2)
        .toList(growable: false);
  }

  LatLng get center => bounds?.center ?? _centerOf(points);

  static LatLng _centerOf(List<RoutePoint> points) {
    if (points.isEmpty) return const LatLng(0, 0);
    final lat = points.map((point) => point.position.latitude).reduce((a, b) => a + b) / points.length;
    final lon = points.map((point) => point.position.longitude).reduce((a, b) => a + b) / points.length;
    return LatLng(lat, lon);
  }
}
