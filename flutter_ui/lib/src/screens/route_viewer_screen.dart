import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../data/demo_route.dart';
import '../widgets/elevation_profile_card.dart';
import '../widgets/route_map.dart';
import '../widgets/route_overview_card.dart';
import '../widgets/route_segments_card.dart';
import '../widgets/warnings_card.dart';

class RouteViewerScreen extends StatelessWidget {
  const RouteViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 1000;
        final mapController = MapController();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Komoot Killer'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: FilledButton.icon(
                  onPressed: () => _showNotImplemented(context),
                  icon: const Icon(Icons.upload_file_rounded),
                  label: const Text('Open GPX'),
                ),
              ),
            ],
          ),
          body: isWide
              ? _DesktopRouteViewer(mapController: mapController)
              : _MobileRouteViewer(mapController: mapController),
        );
      },
    );
  }

  void _showNotImplemented(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('GPX import is a UI stub. Rust parser comes next.'),
      ),
    );
  }
}

class _DesktopRouteViewer extends StatelessWidget {
  const _DesktopRouteViewer({required this.mapController});

  final MapController mapController;

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
              child: ColoredBox(
                color: colorScheme.surfaceContainerLow,
                child: RouteMap(
                  controller: mapController,
                  route: demoRoute,
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
            child: const _RouteInspectorPanel(),
          ),
        ),
      ],
    );
  }
}

class _MobileRouteViewer extends StatelessWidget {
  const _MobileRouteViewer({required this.mapController});

  final MapController mapController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: RouteMap(
            controller: mapController,
            route: demoRoute,
          ),
        ),
        DraggableScrollableSheet(
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
                children: const [
                  Center(child: _SheetHandle()),
                  SizedBox(height: 12),
                  _RouteInspectorPanel(isScrollable: false),
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
  const _RouteInspectorPanel({this.isScrollable = true});

  final bool isScrollable;

  @override
  Widget build(BuildContext context) {
    final content = <Widget>[
      RouteOverviewCard(route: demoRoute),
      const SizedBox(height: 16),
      ElevationProfileCard(route: demoRoute),
      const SizedBox(height: 16),
      RouteSegmentsCard(route: demoRoute),
      const SizedBox(height: 16),
      WarningsCard(route: demoRoute),
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
