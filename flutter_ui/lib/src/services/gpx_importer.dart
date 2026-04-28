import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:xml/xml.dart';

import '../models/route_models.dart';

class GpxImportException implements Exception {
  const GpxImportException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GpxImporter {
  const GpxImporter._();

  static Future<RouteAnalysis?> pickRoute() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;

    if (!file.name.toLowerCase().endsWith('.gpx')) {
      throw const GpxImportException('Please select a valid .gpx file.');
    }

    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      throw const GpxImportException('Selected GPX file is empty or unavailable.');
    }

    return parseBytes(bytes, fallbackName: file.name);
  }

  static RouteAnalysis parseBytes(
    Uint8List bytes, {
    required String fallbackName,
  }) {
    final rawXml = utf8.decode(bytes, allowMalformed: true);
    final document = XmlDocument.parse(rawXml);
    final name = _extractRouteName(document, fallbackName);

    var pointElements = _elementsByLocalName(document, 'trkpt').toList();

    if (pointElements.length < 2) {
      pointElements = _elementsByLocalName(document, 'rtept').toList();
    }

    if (pointElements.length < 2) {
      pointElements = _elementsByLocalName(document, 'wpt').toList();
    }

    if (pointElements.length < 2) {
      throw const GpxImportException(
        'GPX must contain at least two track, route or waypoint points.',
      );
    }

    final parsed = _parsePoints(pointElements);

    if (parsed.points.length < 2) {
      throw const GpxImportException('GPX does not contain enough valid coordinates.');
    }

    final stats = _calculateStats(parsed.points);
    final segments = _buildSegments(parsed.points);

    return RouteAnalysis(
      name: name,
      points: parsed.points,
      distanceKm: stats.distanceM / 1000.0,
      elevationGainM: stats.elevationGainM,
      elevationLossM: stats.elevationLossM,
      minElevationM: stats.minElevationM,
      maxElevationM: stats.maxElevationM,
      segments: segments,
      warnings: _buildWarnings(
        hasMissingElevation: parsed.hasMissingElevation,
        usedPointCount: parsed.points.length,
      ),
    );
  }

  static _ParsedPoints _parsePoints(List<XmlElement> elements) {
    final points = <RoutePoint>[];
    var hasMissingElevation = false;
    var lastElevation = 0.0;

    for (final element in elements) {
      final lat = double.tryParse(_attributeByLocalName(element, 'lat') ?? '');
      final lon = double.tryParse(_attributeByLocalName(element, 'lon') ?? '');

      if (lat == null || lon == null) {
        continue;
      }

      final elevationText = _directChildTextByLocalName(element, 'ele');
      final elevation = double.tryParse(elevationText ?? '');

      if (elevation == null) {
        hasMissingElevation = true;
      } else {
        lastElevation = elevation;
      }

      points.add(
        RoutePoint(
          position: LatLng(lat, lon),
          elevationM: elevation ?? lastElevation,
        ),
      );
    }

    return _ParsedPoints(
      points: points,
      hasMissingElevation: hasMissingElevation,
    );
  }

  static _RouteStats _calculateStats(List<RoutePoint> points) {
    var distanceM = 0.0;
    var gainM = 0.0;
    var lossM = 0.0;
    var minElevationM = points.first.elevationM;
    var maxElevationM = points.first.elevationM;

    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];

      distanceM += _distanceMeters(previous.position, current.position);

      final elevationDelta = current.elevationM - previous.elevationM;

      if (elevationDelta > 0.3) {
        gainM += elevationDelta;
      } else if (elevationDelta < -0.3) {
        lossM += elevationDelta.abs();
      }

      minElevationM = math.min(minElevationM, current.elevationM);
      maxElevationM = math.max(maxElevationM, current.elevationM);
    }

    return _RouteStats(
      distanceM: distanceM,
      elevationGainM: gainM,
      elevationLossM: lossM,
      minElevationM: minElevationM,
      maxElevationM: maxElevationM,
    );
  }

  static List<RouteSegment> _buildSegments(List<RoutePoint> points) {
    const targetSegmentDistanceM = 5000.0;

    final segments = <RouteSegment>[];
    var segmentDistanceM = 0.0;
    var segmentGainM = 0.0;
    var segmentIndex = 1;

    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];

      final stepDistanceM = _distanceMeters(previous.position, current.position);
      final elevationDelta = current.elevationM - previous.elevationM;

      segmentDistanceM += stepDistanceM;

      if (elevationDelta > 0.3) {
        segmentGainM += elevationDelta;
      }

      final isLastPoint = i == points.length - 1;

      if (segmentDistanceM >= targetSegmentDistanceM || isLastPoint) {
        segments.add(
          RouteSegment(
            title: 'Segment $segmentIndex',
            distanceKm: segmentDistanceM / 1000.0,
            elevationGainM: segmentGainM,
            surfaceLabel: 'GPX only',
            warningLevel: SegmentWarningLevel.info,
          ),
        );

        segmentDistanceM = 0.0;
        segmentGainM = 0.0;
        segmentIndex++;
      }
    }

    return segments;
  }

  static List<RouteWarning> _buildWarnings({
    required bool hasMissingElevation,
    required int usedPointCount,
  }) {
    return [
      RouteWarning(
        title: 'GPX route loaded',
        description: '$usedPointCount points parsed locally on device.',
        icon: '📍',
      ),
      if (hasMissingElevation)
        const RouteWarning(
          title: 'Some elevation data is missing',
          description: 'Missing elevation points were filled from the previous known value.',
          icon: '⛰️',
        ),
      const RouteWarning(
        title: 'OSM analysis is not connected yet',
        description: 'Surface, road type and access checks will be added in the next stage.',
        icon: '🧭',
      ),
    ];
  }

  static String _extractRouteName(XmlDocument document, String fallbackName) {
    for (final containerName in ['trk', 'rte', 'metadata']) {
      for (final element in _elementsByLocalName(document, containerName)) {
        final name = _directChildTextByLocalName(element, 'name')?.trim();

        if (name != null && name.isNotEmpty) {
          return name;
        }
      }
    }

    final withoutExtension = fallbackName.replaceFirst(RegExp(r'\.gpx$', caseSensitive: false), '');
    return withoutExtension.trim().isEmpty ? 'Imported GPX route' : withoutExtension;
  }

  static Iterable<XmlElement> _elementsByLocalName(XmlNode node, String localName) sync* {
    if (node is XmlElement && node.name.local == localName) {
      yield node;
    }

    for (final child in node.children) {
      yield* _elementsByLocalName(child, localName);
    }
  }

  static String? _attributeByLocalName(XmlElement element, String localName) {
    for (final attribute in element.attributes) {
      if (attribute.name.local == localName) {
        return attribute.value;
      }
    }

    return null;
  }

  static String? _directChildTextByLocalName(XmlElement element, String localName) {
    for (final child in element.children.whereType<XmlElement>()) {
      if (child.name.local == localName) {
        return child.innerText;
      }
    }

    return null;
  }

  static double _distanceMeters(LatLng a, LatLng b) {
    const earthRadiusM = 6371000.0;
    final lat1 = _radians(a.latitude);
    final lat2 = _radians(b.latitude);
    final dLat = _radians(b.latitude - a.latitude);
    final dLon = _radians(b.longitude - a.longitude);

    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLon / 2) * math.sin(dLon / 2);

    return 2 * earthRadiusM * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  }

  static double _radians(double degrees) => degrees * math.pi / 180.0;
}

class _ParsedPoints {
  const _ParsedPoints({
    required this.points,
    required this.hasMissingElevation,
  });

  final List<RoutePoint> points;
  final bool hasMissingElevation;
}

class _RouteStats {
  const _RouteStats({
    required this.distanceM,
    required this.elevationGainM,
    required this.elevationLossM,
    required this.minElevationM,
    required this.maxElevationM,
  });

  final double distanceM;
  final double elevationGainM;
  final double elevationLossM;
  final double minElevationM;
  final double maxElevationM;
}
