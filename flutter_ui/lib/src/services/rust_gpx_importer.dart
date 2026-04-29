import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

import '../models/route_models.dart';
import '../rust/api.dart' as rust_api;
import 'route_analysis_mapper.dart';

const _maxGpxBytes = 50 * 1024 * 1024;

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
      type: FileType.custom,
      withData: true,
      allowedExtensions: const ['gpx'],
    );

    if (result == null || result.files.isEmpty) {
      return null;
    }

    final file = result.files.single;

    if (!file.name.toLowerCase().endsWith('.gpx')) {
      throw const GpxImportException('Please select a valid .gpx file.');
    }

    if (file.size > _maxGpxBytes) {
      throw const GpxImportException(
        'Selected GPX file is too large. Maximum supported size is 50 MB.',
      );
    }

    final bytes = file.bytes;

    if (bytes == null || bytes.isEmpty) {
      throw const GpxImportException('Selected GPX file is empty or unavailable.');
    }

    return parseBytes(bytes, fallbackName: file.name);
  }

  static Future<RouteAnalysis> parseBytes(
    Uint8List bytes, {
    required String fallbackName,
  }) async {
    try {
      final dto = await rust_api.parseGpxBytes(
        bytes: bytes,
        fallbackName: fallbackName,
      );

      return dto.toUiModel();
    } catch (error) {
      throw GpxImportException('Failed to parse GPX in Rust: $error');
    }
  }
}
