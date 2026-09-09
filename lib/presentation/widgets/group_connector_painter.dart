import 'package:flutter/material.dart';

import 'package:pickup_table/domain/entities/index.dart';

// ==================== [Components: Layer 3 - Group Connector] ====================
//
// NOTE: not currently painted — no call site references this in
// aio_pickuptable_main.dart's build(). Kept (not deleted) in case it's
// needed again; moved here unchanged as part of the Clean Architecture
// folder reorg.
class GroupConnectorPainter extends CustomPainter {
  final List<DetectedObject> objects;

  GroupConnectorPainter({required this.objects});

  @override
  void paint(Canvas canvas, Size size) {
    if (objects.length < 2) return;

    final paint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.15) // 그룹 색상
      ..style = PaintingStyle.stroke
      ..strokeWidth = 60.0
      ..strokeCap = StrokeCap.round;
      // ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30); // 빛 번짐 효과

    final path = Path();
    for (int i = 0; i < objects.length; i++) {
      for (int j = i + 1; j < objects.length; j++) {
        path.moveTo(objects[i].position.dx, objects[i].position.dy);
        // 컵과 컵 사이를 잇는 부드러운 곡선
        path.quadraticBezierTo(
            (objects[i].position.dx + objects[j].position.dx) / 2,
            (objects[i].position.dy + objects[j].position.dy) / 2 + 40,
            objects[j].position.dx,
            objects[j].position.dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
