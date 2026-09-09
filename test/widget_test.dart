import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pickup_table/domain/entities/index.dart';

void main() {
  test('DetectedObject carries the fields the matching pipeline relies on', () {
    final obj = DetectedObject(
      id: 1,
      orderNo: 'A9528',
      position: const Offset(0, 0),
      zValue: 1000,
      diameter: 200,
      uiWidth: 200,
      uiHeight: 200,
      stableKey: 0,
      color: const Color(0xFFFFFFFF),
    );
    expect(obj.rawOrderNo, isEmpty);
    expect(obj.lang, isEmpty);
    expect(obj.isAmplitude, isFalse);
  });
}
