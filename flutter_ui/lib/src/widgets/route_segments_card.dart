import 'package:flutter/material.dart';

import '../models/route_models.dart';

class RouteSegmentsCard extends StatelessWidget {
  const RouteSegmentsCard({required this.route, super.key});

  final RouteAnalysis route;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.view_timeline_rounded, color: colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Segments',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final segment in route.segments) ...[
              _SegmentTile(segment: segment),
              if (segment != route.segments.last) const Divider(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _SegmentTile extends StatelessWidget {
  const _SegmentTile({required this.segment});

  final RouteSegment segment;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = switch (segment.warningLevel) {
      SegmentWarningLevel.ok => colorScheme.primary,
      SegmentWarningLevel.info => colorScheme.tertiary,
      SegmentWarningLevel.warning => colorScheme.error,
    };
    final icon = switch (segment.warningLevel) {
      SegmentWarningLevel.ok => Icons.check_circle_rounded,
      SegmentWarningLevel.info => Icons.info_rounded,
      SegmentWarningLevel.warning => Icons.warning_rounded,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: accent, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                segment.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                segment.surfaceLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${segment.distanceKm.toStringAsFixed(1)} km',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            Text(
              '+${segment.elevationGainM.toStringAsFixed(0)} m',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
