import 'dart:ui';

import 'package:injectable/injectable.dart';

import 'package:pickup_table/data/sources/local/order_manager.dart';
import 'package:pickup_table/domain/entities/index.dart';
import 'package:pickup_table/domain/repositories/order_repository.dart';

@Singleton(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  @override
  List<Map<String, dynamic>> get waitingQueue => OrderManager.waitingQueue;

  @override
  Map<int, Map<String, dynamic>> get activeMatches => OrderManager.activeMatches;

  @override
  List<GhostOrder> get ghostMemory => OrderManager.ghostMemory;

  @override
  Duration get ghostDuration => OrderManager.ghostDuration;

  @override
  bool get gridModeEnabled => OrderManager.gridModeEnabled;

  @override
  set gridModeEnabled(bool value) => OrderManager.gridModeEnabled = value;

  @override
  void addReadyOrder(
    String orderNo,
    String menuName,
    String nickname,
    int drinkCount,
    int foodCount,
    int bottleCount,
    int totalRequired, [
    String lang = '',
  ]) =>
      OrderManager.addReadyOrder(
        orderNo,
        menuName,
        nickname,
        drinkCount,
        foodCount,
        bottleCount,
        totalRequired,
        lang,
      );

  @override
  Map<String, dynamic>? getMatchedOrder(int stableKey) =>
      OrderManager.getMatchedOrder(stableKey);

  @override
  Map<String, dynamic>? getOrAssignOrder(
    int stableKey,
    Offset currentPos,
    Color initialColor,
    double physicalDiameter,
  ) =>
      OrderManager.getOrAssignOrder(stableKey, currentPos, initialColor, physicalDiameter);

  @override
  Map<String, dynamic>? releaseId(int stableKey) => OrderManager.releaseId(stableKey);

  @override
  void clearOrderFromQueue(String orderNo) => OrderManager.clearOrderFromQueue(orderNo);

  @override
  void updateSlotPositions(Map<String, Offset> positions) =>
      OrderManager.updateSlotPositions(positions);

  @override
  void updateSlotHalfWidths(Map<String, double> halfWidths) =>
      OrderManager.updateSlotHalfWidths(halfWidths);
}
