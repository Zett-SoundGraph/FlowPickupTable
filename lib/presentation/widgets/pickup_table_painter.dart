import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:pickup_table/domain/entities/index.dart';

// NOTE: not currently painted — its one call site in
// aio_pickuptable_main.dart's build() is commented out in favor of the
// per-order bracket/label-chip widgets. Kept (not deleted) in case it's
// needed again; moved here unchanged as part of the Clean Architecture
// folder reorg.
class PickupTablePainter extends CustomPainter {
  final List<DetectedObject> objects;
  final List<Color> cupPalette;
  final Map<String, ui.Image> icons;

  PickupTablePainter({required this.objects, required this.cupPalette, required this.icons});

  @override
  void paint(Canvas canvas, Size size) {
    for (var obj in objects) {
      final color = obj.color;

      // 1. 컵 원 그리기용 Paint 설정
      final circlePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      final double radius = (obj.diameter > 0 ? obj.diameter / 2 : 100.0) / 2;

      // 2. 컵 원형 테두리 그리기
      canvas.drawCircle(obj.position, radius, circlePaint);

      // 3. 주문 번호(이름) 텍스트 그리기
      _drawTextLabel(canvas, obj, color, radius);
    }
  }

  void _drawTextLabel(Canvas canvas, DetectedObject obj, Color color, double radius) {
    final String text = obj.orderNo;
    final double textRadius = radius + 15.0;

    // 1. 그릴 요소들을 미리 준비 (이미지인지 텍스트인지 구분)
    final List<Map<String, dynamic>> elements = [];
    double totalWidth = 0;

    for (var char in text.characters) {
      ui.Image? icon = icons[char]; // ✨ 미리 로드된 PNG 아이콘 확인

      if (icon != null) {
        // [아이콘인 경우]
        const double iconSize = 24.0;
        elements.add({
          'type': 'icon',
          'data': icon,
          'width': iconSize,
        });
        totalWidth += iconSize;
      } else {
        // [일반 글자/구분선인 경우]
        Color charColor = (char == '|') ? Colors.white38 : color;
        final tp = TextPainter(
          text: TextSpan(
            text: char,
            style: TextStyle(
              color: charColor,
              fontSize: 20,
              fontFamily: 'CenturyGothic',
              fontWeight: FontWeight.w400,
              letterSpacing: 1.2,
              fontFamilyFallback: ['Noto Color Emoji'],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        elements.add({
          'type': 'text',
          'data': tp,
          'width': tp.width,
        });
        totalWidth += tp.width;
      }
    }

    // 2. 중앙 정렬을 위한 각도 계산
    double totalAngle = totalWidth / textRadius;
    double currentAngle = obj.labelAngle + (totalAngle / 2);

    // 3. 루프를 돌며 실제 그리기
    for (var element in elements) {
      final double elementWidth = element['width'] as double;
      final double charAngle = elementWidth / textRadius;
      final double drawAngle = currentAngle - (charAngle / 2);

      final double x = obj.position.dx + textRadius * math.cos(drawAngle);
      final double y = obj.position.dy + textRadius * math.sin(drawAngle);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(drawAngle - math.pi / 2);

      if (element['type'] == 'icon') {
        // ✨ PNG 아이콘 그리기
        final ui.Image icon = element['data'] as ui.Image;
        const double iconSize = 24.0;
        canvas.drawImageRect(
          icon,
          Rect.fromLTWH(0, 0, icon.width.toDouble(), icon.height.toDouble()),
          Rect.fromLTWH(-iconSize / 2, -iconSize / 2, iconSize, iconSize),
          Paint()..filterQuality = ui.FilterQuality.high,
        );
      } else {
        // ✨ 텍스트(닉네임/구분선) 그리기
        final TextPainter tp = element['data'] as TextPainter;
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      }

      canvas.restore();
      currentAngle -= charAngle;
    }
  }

  @override
  bool shouldRepaint(PickupTablePainter oldDelegate) {
    // 객체 리스트가 바뀌었을 때만 다시 그리도록 최적화
    return oldDelegate.objects != objects;
  }
}
