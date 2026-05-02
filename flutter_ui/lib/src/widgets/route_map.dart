import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/route_models.dart';

class RouteMap extends StatefulWidget {
  const RouteMap({
    super.key,
    required this.route,
    required this.controller,
  });

  final RouteAnalysis route;
  final MapController controller;

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  var _mapReady = false;
  var _userMovedMap = false;

  @override
  void didUpdateWidget(covariant RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.route != widget.route) {
      _userMovedMap = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fitRouteToView());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: FlutterMap(
            mapController: widget.controller,
            options: MapOptions(
              initialCenter: widget.route.center,
              initialZoom: 12.4,
              minZoom: 3,
              maxZoom: 19,
              onMapReady: () {
                setState(() => _mapReady = true);
                _fitRouteToView();
              },
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() => _userMovedMap = true);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'io.github.mar2ianen.kk_flutter_ui_mvp',
                maxZoom: 19,
              ),
              PolylineLayer(
                polylines: _routePolylines(colorScheme),
              ),
              MarkerLayer(
                markers: [
                  _buildMarker(
                    point: widget.route.polyline.first,
                    color: Colors.green,
                    icon: Icons.play_arrow,
                  ),
                  _buildMarker(
                    point: widget.route.polyline.last,
                    color: Colors.red,
                    icon: Icons.flag,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_userMovedMap)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.small(
              onPressed: () {
                setState(() => _userMovedMap = false);
                _fitRouteToView();
              },
              child: const Icon(Icons.my_location),
            ),
          ),
      ],
    );
  }

  void _fitRouteToView() {
    if (!_mapReady || _userMovedMap) {
      return;
    }

    final bounds = _boundsOf(widget.route);
    widget.controller.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(48),
      ),
    );
  }

  List<Polyline> _routePolylines(ColorScheme colorScheme) {
    return widget.route.polylines
        .expand(
          (points) => [
            Polyline(
              points: points,
              strokeWidth: 10,
              color: colorScheme.primary.withValues(alpha: 0.22),
            ),
            Polyline(
              points: points,
              strokeWidth: 5,
              color: colorScheme.primary,
            ),
          ],
        )
        .toList(growable: false);
  }

  static LatLngBounds _boundsOf(RouteAnalysis route) {
    final bounds = route.bounds;

    if (bounds == null) {
      return LatLngBounds.fromPoints(route.polyline);
    }

    return LatLngBounds(
      LatLng(bounds.minLat, bounds.minLon),
      LatLng(bounds.maxLat, bounds.maxLon),
    );
  }

  static Marker _buildMarker({
    required LatLng point,
    required Color color,
    required IconData icon,
  }) {
    return Marker(
      point: point,
      width: 40,
      height: 40,
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }
}
