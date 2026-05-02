import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kk_flutter_ui_mvp/src/theme/app_theme.dart';

void main() {
  test('app theme smoke test', () {
    final theme = buildAppTheme(Brightness.dark);

    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.dark);
    expect(theme.cardTheme.elevation, 0);
  });
}
