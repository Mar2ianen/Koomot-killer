import 'package:latlong2/latlong.dart';

import '../models/route_models.dart';

const demoRoute = RouteAnalysis(
  name: 'Demo Gravel Loop',
  distanceKm: 42.8,
  elevationGainM: 312,
  elevationLossM: 309,
  minElevationM: 12,
  maxElevationM: 86,
  points: [
    RoutePoint(position: LatLng(59.9386, 30.3141), elevationM: 12),
    RoutePoint(position: LatLng(59.9440, 30.3050), elevationM: 16),
    RoutePoint(position: LatLng(59.9520, 30.2960), elevationM: 24),
    RoutePoint(position: LatLng(59.9600, 30.3100), elevationM: 48),
    RoutePoint(position: LatLng(59.9680, 30.3240), elevationM: 67),
    RoutePoint(position: LatLng(59.9640, 30.3460), elevationM: 81),
    RoutePoint(position: LatLng(59.9540, 30.3620), elevationM: 70),
    RoutePoint(position: LatLng(59.9440, 30.3520), elevationM: 42),
    RoutePoint(position: LatLng(59.9360, 30.3360), elevationM: 21),
    RoutePoint(position: LatLng(59.9386, 30.3141), elevationM: 12),
  ],
  segments: [
    RouteSegment(
      title: 'Start city exit',
      distanceKm: 7.4,
      elevationGainM: 36,
      surfaceLabel: 'asphalt / unknown',
      warningLevel: SegmentWarningLevel.info,
    ),
    RouteSegment(
      title: 'Fast gravel sector',
      distanceKm: 15.2,
      elevationGainM: 124,
      surfaceLabel: 'gravel / compacted',
      warningLevel: SegmentWarningLevel.ok,
    ),
    RouteSegment(
      title: 'Forest connector',
      distanceKm: 8.6,
      elevationGainM: 88,
      surfaceLabel: 'dirt / track',
      warningLevel: SegmentWarningLevel.warning,
    ),
    RouteSegment(
      title: 'Return road',
      distanceKm: 11.6,
      elevationGainM: 64,
      surfaceLabel: 'secondary / asphalt',
      warningLevel: SegmentWarningLevel.info,
    ),
  ],
  warnings: [
    RouteWarning(
      title: 'Surface data is mocked',
      description: 'Real OSM matching is not connected yet.',
      icon: '🧪',
    ),
    RouteWarning(
      title: 'One suspicious sector',
      description: 'Forest connector may be too rough for narrow tires.',
      icon: '⚠️',
    ),
    RouteWarning(
      title: 'Elevation profile is demo-only',
      description: 'Values are bundled with the sample route.',
      icon: '⛰️',
    ),
  ],
);
