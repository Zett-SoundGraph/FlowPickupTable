import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:pickup_table/domain/entities/index.dart';
import 'package:pickup_table/domain/entities/pickup_table_theme/pickup_table_theme_selection.dart';

part 'pickup_table_state.freezed.dart';

@freezed
abstract class PickupTableState with _$PickupTableState {
  const factory PickupTableState({
    @Default(false) bool isCalibrating,
    Offset? latestRawForCalib,
    @Default(<DetectedObject>[]) List<DetectedObject> objects,
    // 고객이 QR을 스캔해서 강조 표시된 주문번호(bare, 복합 라벨 아님) 목록.
    @Default(<String>{}) Set<String> highlightedOrders,
    // 픽업된(테이블에서 사라진) 컵이 ghostDuration(5초) 동안 자리에 남아 감사
    // 메시지를 보여주는 상태 — key: '${orderNo}_${stableKey}'(컵 단위 구분).
    @Default(<String, Map<String, dynamic>>{}) Map<String, Map<String, dynamic>> pickupGhostCircles,
    @Default(true) bool showRawData,
    @Default(<TofObject>[]) List<TofObject> lastFrameObjects,
    @Default(false) bool isHandDetected,
    @Default(<String, ui.Image>{}) Map<String, ui.Image> iconImages,
    int? currentLatestFrameId,
    @Default(false) bool isConsoleOpen,
    @Default(<LogItem>[]) List<LogItem> consoleLogs,
    @Default(<String, Offset>{}) Map<String, Offset> guidePositions,
    // null = original circle-based rendering (unthemed) — what FlowHub's
    // Pickup Table Theme screen's Reset button restores. Non-null switches
    // guide/placed/thank-you rendering to the themed square-card widgets
    // (see themed_slot_widgets.dart), set from a SET_PICKUP_TABLE_THEME
    // message on beta/flowhub/pickuptable. Defaults to Forest Green (not
    // null) — themed grid mode is now the confirmed boot-up look,
    // free/untargeted matching is only reached via FlowHub's Reset button
    // (see PickupTableThemeCubit's own doc comment on _lastApplied).
    @Default(PickupTableThemeSelection(
      background: PickupTableThemeBackground.forestGreen,
      style: PickupTableThemeStyle.fill,
    ))
    PickupTableThemeSelection? themeOverride,
    // Bumped on every emit that should force a rebuild regardless of
    // whether any individual field above happens to compare equal (e.g.
    // the same List/Map instance mutated in place) — mirrors
    // FlowBoardState.clockTick's own reasoning.
    @Default(0) int frameRevision,
  }) = _PickupTableState;
}
