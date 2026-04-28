import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/route_models.dart';

class ElevationProfileCard extends StatelessWidget {
  const ElevationProfileCard({required this.route, super.key});

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
                Icon(Icons.area_chart_rounded, color: colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Elevation profile',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 150,
              width: double.infinity,
              child: CustomPaint(
                painter: _ElevationPainter(
                  elevations: route.points.map((point) => point.elevationM).toList(),
                  lineColor: colorScheme.primary,
                  fillColor: colorScheme.primaryContainer.withOpacity(0.45),
                  gridColor: colorScheme.outlineVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ElevationPainter extends CustomPainter {
  const _ElevationPainter({
    required this.elevations,
    required this.lineColor,
    required this.fillColor,
    required this.gridColor,
  });

  final List<double> elevations;
  final Color lineColor;
  final Color fillColor;
  final Color gridColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (elevations.length < 2) {
      return;
    }

    final minElevation = elevations.reduce(math.min);
    final maxElevation = elevations.reduce(math.max);
    final range = math.max(1.0, maxElevation - minElevation);

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePath = Path();
    final fillPath = Path();

    for (var i = 0; i < elevations.length; i++) {
      final x = size.width * i / (elevations.length - 1);
      final normalized = (elevations[i] - minElevation) / range;
      final y = size.height - normalized * size.height;

      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _ElevationPainter oldDelegate) {
    return oldDelegate.elevations != elevations ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.gridColor != gridColor;
  }
}
