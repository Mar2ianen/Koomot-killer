import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../data/demo_route.dart';
import '../models/route_models.dart';
import '../services/rust_gpx_importer.dart';
import '../widgets/elevation_profile_card.dart';
import '../widgets/route_map.dart';
import '../widgets/route_overview_card.dart';
import '../widgets/route_segments_card.dart';
import '../widgets/warnings_card.dart';

class RouteViewerScreen extends StatefulWidget {
  const RouteViewerScreen({super.key});

  @override
  State<RouteViewerScreen> createState() => _RouteViewerScreenState();
}

class _RouteViewerScreenState extends State<RouteViewerScreen> {
  final MapController _mapController = MapController();
  RouteAnalysis _route = demoRoute;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Komoot Killer'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton.icon(
                  onPressed: _isImporting ? null : _openGpx,
                  icon: _isImporting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.upload_file_rounded),
                  label: Text(_isImporting ? 'Loading...' : 'Open GPX'),
                ),
              ),
            ],
          ),
          body: isWide
              ? _DesktopRouteViewer(
                  mapController: _mapController,
                  route: _route,
                )
              : _MobileRouteViewer(
                  mapController: _mapController,
                  route: _route,
                ),
        );
      },
    );
  }

  Future<void> _openGpx() async {
    setState(() => _isImporting = true);

    try {
      final route = await GpxImporter.pickRoute();

      if (!mounted) {
        return;
      }

      if (route == null) {
        return;
      }

      setState(() => _route = route);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Loaded ${route.name}: ${route.distanceKm.toStringAsFixed(1)} km',
          ),
        ),
      );
    } on GpxImportException catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load GPX: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }
}

class _DesktopRouteViewer extends StatelessWidget {
  const _DesktopRouteViewer({
    required this.mapController,
    required this.route,
  });

  final MapController mapController;
  final RouteAnalysis route;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        NavigationRail(
          selectedIndex: 0,
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.route_outlined),
              selectedIcon: Icon(Icons.route_rounded),
              label: Text('Route'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.layers_outlined),
              selectedIcon: Icon(Icons.layers_rounded),
              label: Text('Layers'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: Text('Settings'),
            ),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              clipBehavior: Clip.hardEdge,
              child: ColoredBox(
                color: colorScheme.surfaceContainerLow,
                child: RouteMap(
                  controller: mapController,
                  route: route,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 420,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              border: Border(
                left: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: _RouteInspectorPanel(route: route),
          ),
        ),
      ],
    );
  }
}

class _MobileRouteViewer extends StatelessWidget {
  const _MobileRouteViewer({
    required this.mapController,
    required this.route,
  });

  final MapController mapController;
  final RouteAnalysis route;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: RouteMap(
            controller: mapController,
            route: route,
          ),
        ),
        DraggableScrollableSheet(
          expand: false,
          snap: true,
          snapSizes: const [0.34, 0.62, 0.86],
          initialChildSize: 0.34,
          minChildSize: 0.18,
          maxChildSize: 0.86,
          builder: (context, scrollController) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.22),
                    blurRadius: 28,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  const Center(child: _SheetHandle()),
                  const SizedBox(height: 12),
                  _RouteInspectorPanel(
                    route: route,
                    isScrollable: false,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RouteInspectorPanel extends StatelessWidget {
  const _RouteInspectorPanel({
    required this.route,
    this.isScrollable = true,
  });

  final RouteAnalysis route;
  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[
      RouteOverviewCard(route: route),
      const SizedBox(height: 16),
      ElevationProfileCard(route: route),
      const SizedBox(height: 16),
      RouteSegmentsCard(route: route),
      const SizedBox(height: 16),
      WarningsCard(route: route),
    ];

    if (!isScrollable) {
      return Column(children: content);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: content,
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
