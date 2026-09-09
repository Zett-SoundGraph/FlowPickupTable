import 'dart:ui';

class GhostOrder {
  final String orderNo;
  final String menuName;
  final String nickname;
  final Color color;
  final int drinkCount;
  final int foodCount;
  final int bottleCount;
  final Offset lastPos;
  final DateTime disappearedAt;
  // Customer's kiosk-session language ("en"/"ja"/"ko"/"zh") — carried through
  // so a re-matched ghost still knows which language to show pickup
  // messages in.
  final String lang;

  GhostOrder({
    required this.orderNo,
    required this.menuName,
    required this.nickname,
    required this.drinkCount,
    required this.foodCount,
    required this.bottleCount,
    required this.color,
    required this.lastPos,
    required this.disappearedAt,
    this.lang = '',
  });
}
