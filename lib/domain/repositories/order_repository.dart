import 'dart:ui';

import 'package:pickup_table/domain/entities/index.dart';

/// Thin interface over the pickup table's cup/order matching state — the
/// actual matching algorithm (spatial matching, ghost memory, commercial-
/// mode slot bounding boxes) lives unchanged in
/// data/sources/local/order_manager.dart's OrderManager; this just gives
/// the presentation layer a mockable seam instead of calling those static
/// methods directly.
abstract interface class OrderRepository {
  List<Map<String, dynamic>> get waitingQueue;
  Map<int, Map<String, dynamic>> get activeMatches;
  List<GhostOrder> get ghostMemory;
  Duration get ghostDuration;

  void addReadyOrder(
    String orderNo,
    String menuName,
    String nickname,
    int drinkCount,
    int foodCount,
    int bottleCount,
    int totalRequired, [
    String lang,
  ]);

  Map<String, dynamic>? getMatchedOrder(int stableKey);

  Map<String, dynamic>? getOrAssignOrder(
    int stableKey,
    Offset currentPos,
    Color initialColor,
    double physicalDiameter,
  );

  Map<String, dynamic>? releaseId(int stableKey);

  void clearOrderFromQueue(String orderNo);

  void updateSlotPositions(Map<String, Offset> positions);

  void updateSlotHalfWidths(Map<String, double> halfWidths);
}
