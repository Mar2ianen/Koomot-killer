import 'package:latlong2/latlong.dart';

import '../models/route_models.dart';
import '../rust/api.dart' as rust_api;

extension RouteAnalysisDtoMapper on rust_api.RouteAnalysisDto {
  RouteAnalysis toUiModel() {
    return RouteAnalysis(
      name: name,
      points: points
          .map(
            (point) => RoutePoint(
              position: LatLng(point.lat, point.lon),
              elevationM: point.elevationM,
            ),
          )
          .toList(growable: false),
      distanceKm: distanceKm,
      elevationGainM: elevationGainM,
      elevationLossM: elevationLossM,
      minElevationM: minElevationM,
      maxElevationM: maxElevationM,
      bounds: RouteBounds(
        minLat: bounds.minLat,
        minLon: bounds.minLon,
        maxLat: bounds.maxLat,
        maxLon: bounds.maxLon,
      ),
      parts: parts
          .map(
            (part) => RoutePart(
              index: part.index,
              startIndex: part.startIndex,
              endIndex: part.endIndex,
              pointCount: part.pointCount,
            ),
          )
          .toList(growable: false),
      segments: segments
          .map(
            (segment) => RouteSegment(
              title: segment.title,
              distanceKm: segment.distanceKm,
              elevationGainM: segment.elevationGainM,
              surfaceLabel: segment.surfaceLabel,
              warningLevel: _warningLevelFromRust(segment.warningLevel),
            ),
          )
          .toList(growable: false),
      warnings: warnings
          .map(
            (warning) => RouteWarning(
              title: warning.title,
              description: warning.description,
              icon: warning.icon,
            ),
          )
          .toList(growable: false),
    );
  }
}

SegmentWarningLevel _warningLevelFromRust(String value) {
  switch (value.toLowerCase()) {
    case 'ok':
      return SegmentWarningLevel.ok;
    case 'warning':
      return SegmentWarningLevel.warning;
    case 'info':
    default:
      return SegmentWarningLevel.info;
  }
}
