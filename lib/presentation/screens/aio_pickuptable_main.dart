import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pickup_table/core/constants/index.dart';
import 'package:pickup_table/core/theme/pickup_table_theme_registry.dart';
import 'package:pickup_table/domain/entities/pickup_table_theme/pickup_table_theme_colors.dart';
import 'package:pickup_table/domain/entities/pickup_table_theme/pickup_table_theme_selection.dart';
import 'package:pickup_table/domain/entities/index.dart';
import 'package:pickup_table/presentation/cubit/pickup_table_cubit.dart';
import 'package:pickup_table/presentation/cubit/pickup_table_state.dart';
import 'package:pickup_table/presentation/widgets/index.dart';
import 'calibration_screen.dart';

class AioPickupTableMain extends StatefulWidget {
  const AioPickupTableMain({super.key});

  @override
  State<AioPickupTableMain> createState() => _AioPickupTableMainState();
}

class _AioPickupTableMainState extends State<AioPickupTableMain> with WidgetsBindingObserver {
  final GlobalKey<CalibrationScreenState> _calibKey = GlobalKey<CalibrationScreenState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This kiosk display is fixed-resolution and never resizes/rotates at
    // runtime, so caching it once here (the only place with a
    // BuildContext) gives the Cubit the exact same numeric value the old
    // per-frame MediaQuery.of(context).size read would have produced,
    // without the Cubit itself needing a BuildContext.
    context.read<PickupTableCubit>().setScreenSize(MediaQuery.of(context).size);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<PickupTableCubit>().onAppResumed();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  /// One [OrderGroup]'s worth of widgets — the bracket+label-chip+thank-
  /// you-circle combo, unchanged from before this theming feature existed.
  /// Only used when state.themeOverride == null — once a theme is active,
  /// rendering switches entirely to the fixed-grid [_buildGridGroupWidgets]
  /// below instead (see PickupTableCubit.buildGridOrderGroups' doc comment
  /// for why grid mode doesn't reuse this continuous-position data at all).
  List<Widget> _buildOrderGroupWidgets({
    required OrderGroup group,
    required PickupTableCubit cubit,
    required PickupTableState state,
    required List<OrderGroup> orderGroups,
    required double screenWidth,
    required double screenHeight,
  }) {
    final labelPos =
        cubit.labelPositionFor(group, orderGroups, Size(screenWidth, screenHeight));
    final double thankYouDiameter = math.min(group.bounds.width, group.bounds.height);

    return [
      Positioned(
        key: ValueKey('bracket_${group.orderNo}'),
        left: group.bounds.left,
        top: group.bounds.top,
        width: group.bounds.width,
        height: group.bounds.height,
        child: BlinkingVisibility(
          enabled: group.isHighlighted,
          child: OrderBracketWidget(
            width: group.bounds.width,
            height: group.bounds.height,
            isHighlighted: group.isHighlighted,
          ),
        ),
      ),
      Positioned(
        key: ValueKey('label_${group.orderNo}'),
        // alignRight일 땐 `left`가 아니라 `right`로 앵커링 — 실제
        // 칩 폭과 무관하게 우측 끝이 정확히 bounds.right에 맞춰짐.
        left: labelPos.alignRight ? null : labelPos.x,
        right: labelPos.alignRight ? screenWidth - labelPos.x : null,
        top: labelPos.top,
        child: OrderLabelChip(
          label: group.label,
          lang: group.lang,
          isHighlighted: group.isHighlighted,
        ),
      ),
      // 이 주문의 모든 컵이 다 픽업되어 라이브 컵이 하나도 안
      // 남았을 때만 — 브라켓 안쪽에 꽉 차는 원 하나로 감사 메시지
      // 표시.
      if (group.ghostMessage != null)
        Positioned(
          key: ValueKey('pickup_ghost_${group.orderNo}'),
          left: group.bounds.center.dx - thankYouDiameter / 2,
          top: group.bounds.center.dy - thankYouDiameter / 2,
          width: thankYouDiameter,
          height: thankYouDiameter,
          child: BaseCircleWidget(
            label: '',
            diameter: thankYouDiameter,
            icons: state.iconImages,
            // 픽업되면 강조 여부와 무관하게 항상 원래(정지)
            // 색상으로 보여야 함.
            isHighlighted: false,
            pickupMessage: group.ghostMessage,
            lang: group.lang,
          ),
        ),
    ];
  }

  /// One [GridOrderGroup]'s worth of widgets — ONE themed card spanning
  /// [GridOrderGroup.bounds] (the union of every assigned cell), not one
  /// per cell — see that field's doc comment for why (matches
  /// test_base_light.png's own multi-cell cards, which render as a single
  /// seamless wide card with one corner tag, not several bordered squares).
  /// Same [GridOrderGroup] data regardless of theme (grid mode's layout is
  /// fully theme-agnostic), rendered with themed_slot_widgets.dart.
  List<Widget> _buildGridGroupWidgets(GridOrderGroup group, PickupTableThemeColors colors,
      PickupTableThemeStyle style, PickupTableThemeDotStyle dotStyle) {
    final Rect bounds = group.bounds;
    return [
      Positioned(
        key: ValueKey('grid_${group.orderNo}'),
        left: bounds.left,
        top: bounds.top,
        width: bounds.width,
        height: bounds.height,
        child: switch (group.state) {
          GridSlotState.guide => ThemedGuideSlot(
              orderNo: group.orderNo,
              width: bounds.width,
              height: bounds.height,
              colors: colors,
              rowWidths: group.rowWidths,
              lang: group.lang,
              dotStyle: dotStyle,
            ),
          GridSlotState.thankYou => ThemedThankYouSlot(
              message: group.ghostMessage ?? '',
              width: bounds.width,
              height: bounds.height,
              colors: colors,
              lang: group.lang,
            ),
          GridSlotState.matched ||
          GridSlotState.timedOut ||
          GridSlotState.highlighted =>
            BlinkingVisibility(
              enabled: group.state == GridSlotState.highlighted,
              child: ThemedPlacedSlot(
                orderNo: group.orderNo,
                width: bounds.width,
                height: bounds.height,
                colors: colors,
                rowWidths: group.rowWidths,
                style: style,
                lang: group.lang,
                emphasis: switch (group.state) {
                  GridSlotState.highlighted => ThemedPlacedEmphasis.highlighted,
                  GridSlotState.timedOut => ThemedPlacedEmphasis.timedOut,
                  _ => ThemedPlacedEmphasis.matched,
                },
              ),
            ),
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<PickupTableCubit>();
    final state = cubit.state;

    // 주문 번호별로 그룹핑 (Elastic 효과용)
    Map<String, List<DetectedObject>> groupedObjects = {};
    for (var obj in state.objects) {
      groupedObjects.putIfAbsent(obj.orderNo, () => []).add(obj);
    }

    final bool hasObjectOnTable = state.objects.isNotEmpty;
    // 손 감지가 최우선(물체 유무와 무관하게 손이 있으면 bg-hand).
    final String backgroundAsset = state.isHandDetected
        ? 'assets/images/bg-hand.png'
        : hasObjectOnTable
            ? 'assets/images/bg-object.png'
            : 'assets/images/bg.png';

    return Scaffold(
      body: LayoutBuilder(builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        // 주문 단위 브라켓/라벨칩/감사인사 원 계산 — 한 프레임에 한 번만
        // 계산해서 렌더링과 라벨 위치 충돌 판정 양쪽에서 같은 목록을 그대로
        // 재사용한다.
        final List<OrderGroup> orderGroups =
            AppConstants.isCommercialMode ? const [] : cubit.buildOrderGroups();
        // Resolved once and reused below — background fill AND every
        // themed grid-group card need the same color set.
        final PickupTableThemeColors? themeColors = state.themeOverride != null
            ? PickupTableThemeRegistry.resolveSelection(state.themeOverride!)
            : null;
        final bool anyThemeActive = themeColors != null;
        // Computed once and reused below — both the themed background's dim
        // overlay and the actual grid-group rendering (further down) need
        // the same "what's currently showing" list, same reasoning as
        // orderGroups above.
        final List<GridOrderGroup> gridOrderGroups =
            anyThemeActive ? cubit.buildGridOrderGroups() : const [];
        final List<String> backgroundImagePaths =
            (state.themeOverride?.backgroundImage ?? PickupTableThemeBackgroundImage.menuImage)
                .assetPaths;

        return Stack(
          fit: StackFit.expand,
          children: [
            // 테마가 켜지면 기존 배경 영상/이미지 대신 고정 배경 이미지로 완전히
            // 대체 — 물체/손 유무에 따른 배경 전환 연출은 테마 안 켜졌을 때만
            // 의미가 있음. 그리드에 뭔가(guide 포함) 하나라도 떠 있으면 그
            // 위에 #0003108C로 딤 처리 — 테마별 background 색상(PickupTableThemeColors.
            // background)은 더 이상 배경 채우기에 쓰이지 않음(그리드
            // 셀/카드 색상 등 다른 용도로는 계속 쓰임). loopMenuImages처럼
            // backgroundImagePaths가 여러 개면 PickupBackgroundImageLoop로
            // 자동 롤링+크로스페이드, 1개면 그냥 고정 이미지.
            if (anyThemeActive) ...[
              Positioned.fill(
                child: backgroundImagePaths.length > 1
                    ? PickupBackgroundImageLoop(assetPaths: backgroundImagePaths)
                    : Image.asset(backgroundImagePaths.first, fit: BoxFit.cover),
              ),
              if (gridOrderGroups.isNotEmpty)
                const Positioned.fill(
                  child: ColoredBox(color: Color(0x8C000310)),
                ),
            ] else ...[
              // 배경 전체 — 물체/손 유무에 따른 딤/글로우 느낌이 이미 이미지
              // 자체에 구워져 있어서, 실시간 효과 없이 이미지만 바꿔치기하면 됨.
              Positioned.fill(
                child: Image.asset(backgroundAsset, fit: BoxFit.cover),
              ),

              // 물체가 있을 때는 재생 정지(마지막 프레임에 멈춤) + 영상 박스에만
              // 딤 처리.
              PickupBackgroundVideo(
                isPlaying: !hasObjectOnTable,
                isDimmed: hasObjectOnTable,
              ),
            ],

            // state.themeOverride가 설정되면(FlowHub의 Pickup Table Theme
            // 화면) 아래 두 블록(브라켓+라벨칩+원 / 원형 가이드써클) 대신
            // 그리드 기반 렌더링(_buildGridGroupWidgets, 바로 위/아래)으로
            // 완전히 대체됨 — 연속 좌표(group.bounds/guidePositions)는 더
            // 이상 쓰이지 않고, 고정 그리드 셀(cubit.buildGridOrderGroups)
            // 좌표를 직접 그림.
            if (themeColors != null)
              ...cubit.buildGridOrderGroups().expand((group) => _buildGridGroupWidgets(
                    group,
                    themeColors,
                    state.themeOverride!.style,
                    state.themeOverride!.dotStyle,
                  )),

            // 실제 컵이 놓였을 때는 더 이상 컵마다 각각 원을 그리지 않음 —
            // 라이브 컵의 개별 표시는 없애고 주문 단위 브라켓 + 라벨칩만으로
            // 표시함. 픽업 완료 후 감사인사 원(BaseCircleWidget)은 그대로 유지.
            if (!AppConstants.isCommercialMode && !anyThemeActive)
              ...orderGroups.expand((group) => _buildOrderGroupWidgets(
                    group: group,
                    cubit: cubit,
                    state: state,
                    orderGroups: orderGroups,
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  )),

            if (!anyThemeActive)
              RepaintBoundary(
                child: Stack(
                  children: [
                    ...state.guidePositions.entries.map((entry) {
                      Offset pos = entry.value;
                      // 라벨: 대기열 → activeMatches → 기본값 순으로 fallback
                      final orderData = cubit.orderDataFor(entry.key);
                      String label = cubit.buildComplexLabel(orderData);
                      int totalCups = orderData['totalRequired'] ?? 1;

                      // 상업용 모드: 음료 수에 따라 슬롯 너비 계산 (높이는 항상 200 고정)
                      final int drinkCount =
                          AppConstants.isCommercialMode ? cubit.getDrinkCount(entry.key) : 1;
                      final double slotWidth = AppConstants.isCommercialMode
                          ? (100.0 + drinkCount.clamp(1, 10) * 200.0)
                          : 180.0 + ((totalCups - 1) * 60.0);

                      final double leftOffset = slotWidth / 2;
                      const double topOffset = 100.0;

                      final neighborInfo =
                          AppConstants.isCommercialMode ? cubit.getNeighborInfo(entry.key) : null;

                      return AnimatedPositioned(
                        key: ValueKey("guide_${entry.key}"),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        left: pos.dx - leftOffset,
                        top: pos.dy - topOffset,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: const Duration(seconds: 1),
                          builder: (context, val, child) {
                            return AppConstants.isCommercialMode
                                ? SquareGuideWidget(
                                    orderNo: entry.key,
                                    drinkCount: drinkCount,
                                    state: GuideState.waiting,
                                    slotWidth: slotWidth,
                                    hasRightNeighbor: neighborInfo!['hasRight']!,
                                    hasBottomNeighbor: neighborInfo['hasBottom']!,
                                    topNeighborIsActive: neighborInfo['topActive']!,
                                    leftNeighborIsActive: neighborInfo['leftActive']!,
                                  )
                                : Opacity(
                                    opacity: val,
                                    child: BlinkingVisibility(
                                      enabled: true,
                                      child: OrderGuideWidget(
                                        label: label,
                                        color: Colors.white,
                                        icons: state.iconImages,
                                        totalCups: totalCups,
                                        lang: (orderData['lang'] as String?) ?? '',
                                      ),
                                    ),
                                  );
                          },
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

            if (state.isConsoleOpen)
              Positioned(
                bottom: 80,
                right: 20,
                width: 600,
                height: 800,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.9),
                    border: Border.all(color: Colors.greenAccent, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("NETWORK MONITOR",
                              style: TextStyle(
                                  color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const RealTimeClock(),
                              ),
                              const SizedBox(width: 12),
                              Text(state.showRawData ? "RAW" : "EVENT",
                                  style: TextStyle(
                                      color: state.showRawData ? Colors.greenAccent : Colors.white54,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                              Transform.scale(
                                scale: 0.7,
                                child: Switch(
                                  value: state.showRawData,
                                  activeColor: Colors.greenAccent,
                                  activeTrackColor: Colors.greenAccent.withOpacity(0.3),
                                  inactiveThumbColor: Colors.grey,
                                  inactiveTrackColor: Colors.white10,
                                  onChanged: (val) => cubit.setShowRawData(val),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: cubit.clearConsoleLogs,
                                icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 18),
                                label: const Text("CLEAR", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 16),
                      Expanded(
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: state.consoleLogs.length,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            final log = state.consoleLogs[index];
                            bool isLatestLine = index == state.consoleLogs.length - 1;
                            bool isFromCurrentFrame =
                                log.frameId != null && log.frameId == state.currentLatestFrameId;

                            Color logColor;
                            if (log.objectId != null && isFromCurrentFrame) {
                              logColor = cubit.getColorForId(log.objectId!);
                            } else if (isLatestLine) {
                              logColor = Colors.white;
                            } else if (log.type == "SYS") {
                              logColor = Colors.white54;
                            } else {
                              logColor = Colors.white54;
                            }

                            return Text(
                              "[${log.timestamp}][${log.type}] ${log.message}",
                              style: TextStyle(
                                color: logColor,
                                fontWeight: isFromCurrentFrame ? FontWeight.bold : FontWeight.normal,
                                fontSize: 10,
                                fontFamily: 'Courier',
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (state.isCalibrating)
              CalibrationScreen(
                key: _calibKey,
                currentRawPos: state.latestRawForCalib,
                currentRawZ: state.lastFrameObjects.isNotEmpty ? state.lastFrameObjects.first.z : 1000.0,
                onValidationEntered: cubit.notifyValidationEntered,
                onCalibExit: cubit.notifyCalibrationExit,
                onCancel: cubit.cancelCalibration,
                onComplete: cubit.completeCalibration,
              ),
          ],
        );
      }),
    );
  }
}
