import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/route_models.dart';

class RouteMap extends StatefulWidget {
  const RouteMap({
    required this.controller,
    required this.route,
    super.key,
  });

  final MapController controller;
  final RouteAnalysis route;

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  var _mapReady = false;
  var _userMovedMap = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final start = widget.route.polyline.first;
    final finish = widget.route.polyline.last;

    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: widget.controller,
              options: MapOptions(
                initialCenter: _centerOf(widget.route.polyline),
                initialZoom: 12.4,
                minZoom: 3,
                maxZoom: 19,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onMapReady: () {
                  _mapReady = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _fitRouteToView();
                    }
                  });
                },
                onPositionChanged: (_, hasGesture) {
                  if (hasGesture && !_userMovedMap && mounted) {
                    setState(() => _userMovedMap = true);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'dev.mar2ianen.koomot_killer.ui_mvp',
                  maxZoom: 19,
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: widget.route.polyline,
                      strokeWidth: 10,
                      color: colorScheme.primary.withOpacity(0.22),
                    ),
                    Polyline(
                      points: widget.route.polyline,
                      strokeWidth: 5,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    _buildMarker(
                      point: start,
                      color: colorScheme.primary,
                      icon: Icons.play_arrow_rounded,
                      label: 'Start',
                    ),
                    _buildMarker(
                      point: finish,
                      color: colorScheme.tertiary,
                      icon: Icons.flag_rounded,
                      label: 'Finish',
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            child: SafeArea(
              bottom: false,
              child: _MapBadge(route: widget.route),
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: SafeArea(
              bottom: false,
              child: _MapControls(
                controller: widget.controller,
                route: widget.route,
                onCenterRoute: _fitRouteToView,
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: _AttributionPill(colorScheme: colorScheme),
          ),
          if (_userMovedMap)
            Positioned(
              right: 16,
              bottom: 16,
              child: _RecenterButton(onPressed: _fitRouteToView),
            ),
        ],
      ),
    );
  }

  void _fitRouteToView() {
    if (!_mapReady || widget.route.polyline.isEmpty) {
      return;
    }

    final bounds = LatLngBounds.fromPoints(widget.route.polyline);
    widget.controller.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(48, 160, 48, 260),
      ),
    );

    if (_userMovedMap && mounted) {
      setState(() => _userMovedMap = false);
    }
  }

  static Marker _buildMarker({
    required LatLng point,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Marker(
      point: point,
      width: 104,
      height: 56,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              shadows: [Shadow(blurRadius: 3, color: Colors.black)],
            ),
          ),
        ],
      ),
    );
  }

  static LatLng _centerOf(List<LatLng> points) {
    final lat = points.map((point) => point.latitude).reduce((a, b) => a + b) / points.length;
    final lon = points.map((point) => point.longitude).reduce((a, b) => a + b) / points.length;
    return LatLng(lat, lon);
  }
}

class _MapBadge extends StatelessWidget {
  const _MapBadge({required this.route});

  final RouteAnalysis route;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface.withOpacity(0.92),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.route_rounded, color: colorScheme.primary),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  route.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                Text(
                  '${route.distanceKm.toStringAsFixed(1)} km · +${route.elevationGainM.toStringAsFixed(0)} m',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MapControls extends StatelessWidget {
  const _MapControls({
    required this.controller,
    required this.route,
    required this.onCenterRoute,
  });

  final MapController controller;
  final RouteAnalysis route;
  final VoidCallback onCenterRoute;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surface.withOpacity(0.92),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Zoom in',
            onPressed: () => _zoomBy(1),
            icon: const Icon(Icons.add_rounded),
          ),
          IconButton(
            tooltip: 'Zoom out',
            onPressed: () => _zoomBy(-1),
            icon: const Icon(Icons.remove_rounded),
          ),
          IconButton(
            tooltip: 'Center route',
            onPressed: onCenterRoute,
            icon: const Icon(Icons.my_location_rounded),
          ),
        ],
      ),
    );
  }

  void _zoomBy(double delta) {
    final camera = controller.camera;
    final zoom = math.max(3, math.min(19, camera.zoom + delta)).toDouble();
    controller.move(camera.center, zoom);
  }
}

class _RecenterButton extends StatelessWidget {
  const _RecenterButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'recenter-map',
      onPressed: onPressed,
      icon: const Icon(Icons.center_focus_strong_rounded),
      label: const Text('Route'),
    );
  }
}

class _AttributionPill extends StatelessWidget {
  const _AttributionPill({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.88),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          '© OpenStreetMap contributors',
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}
