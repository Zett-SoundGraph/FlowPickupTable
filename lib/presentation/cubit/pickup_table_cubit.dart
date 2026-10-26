import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:ml_linalg/dtype.dart';
import 'package:ml_linalg/matrix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pickup_table/core/constants/index.dart';
import 'package:pickup_table/core/theme/pickup_table_grid_layout.dart';
import 'package:pickup_table/core/utils/diag_logger.dart';
import 'package:pickup_table/domain/entities/index.dart';
import 'package:pickup_table/domain/entities/pickup_table_theme/pickup_table_theme_selection.dart';
import 'package:pickup_table/domain/repositories/index.dart';
import 'package:pickup_table/presentation/screens/calibration_screen.dart' show CalibrationPair;
import 'package:pickup_table/presentation/cubit/pickup_table_state.dart';

/// All of the pickup table's real-time cup/hand-tracking, order-matching,
/// calibration, and console-log business logic — moved here unchanged from
/// what was previously AioPickupTableMain's State class (setState calls
/// became emit(state.copyWith(...)) calls, direct OrderManager/
/// CoordinateTransformer/MqttService/LanguageSheetService access became
/// calls through the injected repositories from the Clean Architecture
/// pass, and the per-frame MediaQuery.of(context).size read became a
/// screen size cached once via [setScreenSize] instead — this app's
/// display never resizes at runtime, so the numeric result is identical).
@injectable
class PickupTableCubit extends Cubit<PickupTableState> {
  PickupTableCubit(
    this._pickupRepository,
    this._languageRepository,
    this._orderRepository,
    this._coordinateRepository,
  ) : super(const PickupTableState()) {
    _loadSavedCalibration();
    _initializeServer();
    _loadIcons();
  }

  final PickupMqttRepository _pickupRepository;
  final LanguageRepository _languageRepository;
  final OrderRepository _orderRepository;
  final CoordinateRepository _coordinateRepository;

  StreamSubscription<String>? _mqttLogSubscription;
  StreamSubscription<String>? _customerScanSubscription;
  StreamSubscription<TofFrame>? _tofFrameSubscription;
  StreamSubscription<void>? _orderReadySubscription;
  StreamSubscription<CalibrationRequest>? _calibrationRequestedSubscription;
  StreamSubscription<Map<String, dynamic>?>? _themeChangedSubscription;
  StreamSubscription<void>? _createTestOrdersSubscription;
  StreamSubscription<void>? _clearTestOrdersSubscription;

  // 화면 정중앙(Center 위젯)에 떠 있는 PickupBackgroundVideo의 실제 크기
  // (1800x960)보다 조금 더 넉넉한 "안전 영역" — 이 밖에 중심점이 찍히는
  // 감지는 아예 물체로 취급하지 않는다. 자세한 이유는 이전 구현의 주석 참고
  // (ToF 카메라 화각 비율이 와이드 디스플레이보다 좁아 경계 근처 인식이 늦고,
  // 그 사이 손이 물체로 오인식되는 문제 방지).
  static const double _pickupZoneWidth = 1870.0;
  static const double _pickupZoneHeight = 1030.0;

  static const double _movementThreshold = 2.0;

  Timer? _handDetectionTimer;

  int _irValue = 51;
  int? _lastSentIrValue;
  bool _irSentRecently = false;
  Timer? _irSentTimer;

  final List<Color> _idPalette = List.generate(100, (index) {
    double hue = (index * 137.508) % 360;
    double saturation = (index % 2 == 0) ? 0.9 : 0.5;
    double value = 1.0 - ((index % 3) * 0.2);
    return HSVColor.fromAHSV(1.0, hue, saturation, value).toColor();
  });

  final ValueNotifier<List<Offset>> obstacleNotifier = ValueNotifier([]);

  // 신규 컵마다 하나씩 증가하는 카운터 — DetectedObject.stableKey 발급용.
  int _nextStableKey = 0;
  final List<DetectedObject> _exitingObjects = [];

  // stableKey별 마지막으로 로그에 남긴 크기 — 겹침(occlusion merge) 진단용.
  // 동일 stableKey가 프레임 간에 계속 매칭되는 도중 diameter/width/height가
  // 갑자기 크게 뛰면(옆 컵과 바운딩박스가 합쳐졌을 가능성) 이걸로 감지해서
  // SIZE_JUMP로 남긴다. CUP_ADD/CUP_REMOVE 때 이 맵도 같이 정리한다.
  final Map<int, TofObject> _lastLoggedSizeByStableKey = {};
  static const double _mergeSizeJumpThresholdMm = 15.0;

  // stableKey별 마지막으로 로그에 남긴 위치 — amplitude(아이스컵) 추적
  // 안정성 검증용. tof_camera의 amplitude NMS를 "가장 큰 조각 선택"에서
  // "면적 가중 평균(무게중심)"으로 바꾼 효과를 측정하기 위해, 같은 컵이
  // 계속 추적되는 동안 프레임마다 위치가 얼마나 움직이는지(픽셀 단위)를
  // 남긴다 — 수정 전/후 로그를 비교해서 흔들림이 줄었는지 확인하는 용도.
  // CUP_ADD/CUP_REMOVE 때 이 맵도 같이 정리한다.
  final Map<int, Offset> _lastLoggedIcePosByStableKey = {};

  // Keyed by ghostKey ('${orderNo}_${stableKey}'), NOT orderNo — a multi-cup
  // order's cups can release moments apart, and keying by orderNo would let
  // the later cup's release cancel the earlier cup's own completion-check
  // timer.
  final Map<String, Timer> _pickupTimers = {};

  final Map<String, Offset> _guidePositions = {};
  // orderNo -> when it first got a live cup on the table (dashed guide
  // square -> solid matched square). Drives ThemedPlacedEmphasis.timedOut
  // (10 minutes with no pickup) — see buildOrderGroups' isTimedOut
  // computation below. Cleared once the order fully clears the table (see
  // the ghost-pickup-complete branch in _processCupUpdate).
  final Map<String, DateTime> _matchedAt = {};
  static const Duration _matchTimeout = Duration(minutes: 10);
  final Map<String, int> _slotAssignments = {};
  final Random _random = Random();

  // ── Grid mode (themed rendering only — see OrderRepository.gridModeEnabled
  // and buildGridOrderGroups' doc comment) ─────────────────────────────
  // orderNo -> the fixed PickupTableGridLayout cell indices assigned to
  // it (one per cup), all at once, the moment it enters the waiting
  // queue. See _allocateGridCells for the "staircase" shape these form
  // when a row-width step is involved — the card is drawn as that exact
  // stepped outline (see _gridRowWidths), not a bounding-box rectangle,
  // so there's no leftover "unused corner" to separately track/reserve
  // any more (an earlier version of this did; that's no longer needed
  // now that the render matches the true shape instead of covering it).
  final Map<String, List<int>> _gridCellGroups = {};
  // orderNo -> cell-count per row, top to bottom, in the exact order
  // _allocateGridCells laid [_gridCellGroups] out in (rows widen going
  // down — e.g. [2,3] for a 5-cup order, matching test_base_light.png's
  // own L-shaped 5-cell card) — read by buildGridOrderGroups so the
  // renderer knows where to carve the staircase notch. A single-element
  // list (e.g. [3]) means one plain row, no step at all.
  final Map<String, List<int>> _gridRowWidths = {};
  // orderNo -> once every one of its cells first had a live cup detected
  // in it simultaneously (dashed guide group -> solid matched group).
  final Map<String, DateTime> _gridMatchedAt = {};
  // orderNo -> once a previously-fully-matched group's cells all went
  // empty again (drives the post-pickup thank-you overlay for
  // ghostDuration, purely visually — see buildGridOrderGroups).
  final Map<String, DateTime> _gridEmptiedAt = {};
  // orderNo -> the ghost/thank-you message picked ONCE, right when the
  // ghost window starts (see _updateGridOccupancy's EMPTIED transition).
  // buildGridOrderGroups is re-invoked on every rebuild while grid mode is
  // on (every incoming ToF frame emits, whether or not anything visible
  // actually changed — see _handleTofFrame), and LanguageSheetService.
  // pickupMessageFor() picks a random message on every call — calling it
  // fresh from buildGridOrderGroups on every one of those rebuilds made
  // the message re-roll to a new random pick on every frame, which reads
  // as the text rapidly cycling/rolling (most visible right when a cup
  // gets placed back down within the ghost window, since that's exactly
  // when ToF frames — and therefore rebuilds — arrive in a rapid burst).
  // Caching it here means the same message stays put for the rest of that
  // one pickup event.
  final Map<String, String> _gridGhostMessage = {};
  // Cell indices with a live cup in them as of the most recent ToF frame
  // — recomputed every frame in _updateGridOccupancy, read by
  // buildGridOrderGroups.
  Set<int> _occupiedGridCells = {};
  // What _updateGridOccupancy last logged, so it only prints on an actual
  // change instead of every single frame (the debug log this drives is
  // meant to make "did cell X actually register as occupied" directly
  // answerable from logcat, without needing to also watch the screen).
  Set<int> _lastLoggedOccupiedGridCells = {};
  // orderNos _updateGridOccupancy should never touch — only ever the one
  // synthetic "already timed out" test order createTestOrders() fabricates
  // (see below), since there's no real cup for it and a real occupancy
  // check would otherwise immediately un-match it the instant it runs.
  final Set<String> _gridPinnedOrderNos = {};
  // Every orderNo createTestOrders() has created, so clearTestOrders() can
  // find and remove exactly those (and nothing a real order might be
  // using) regardless of which grid/queue/active-match bucket each has
  // since ended up in.
  final List<String> _testOrderNos = [];
  // Debounce timestamps for _updateGridOccupancy — WHEN an order's cells
  // most recently became continuously fully-occupied
  // (_gridOccupiedSince) or fully-empty (_gridEmptySince), cleared the
  // instant a frame disagrees. A state transition (dashed->solid or
  // solid->ghost) only actually commits once that timestamp is at least
  // _gridDebounceDuration in the past — a single stray frame (a hand
  // passing over a cell, an amplitude-fallback blip, one dropped
  // detection on a hard-to-see transparent cup) no longer flips the
  // visible state on its own.
  //
  // Originally this counted CONSECUTIVE FRAMES instead (5 of them) —
  // deliberately changed to wall-clock time because the ToF pipeline's
  // frame delivery rate isn't a fixed/known constant (it may be event-
  // driven or otherwise variable), so "5 frames" is not a fixed amount of
  // real time and, live-tested, never actually accumulated enough frames
  // for a cup that was physically on its correct cell continuously for
  // the whole test to ever flip to matched. Wall-clock time doesn't have
  // that problem. UNCONFIRMED duration — tune once real false-positive/
  // flicker behavior is observed with this in place.
  final Map<String, DateTime> _gridOccupiedSince = {};
  final Map<String, DateTime> _gridEmptySince = {};
  static const Duration _gridDebounceDuration = Duration(milliseconds: 500);

  // Master off-switch for grid occupancy DETECTION only (nearestCellIndex
  // matching + the debounce above + the polling timer below) — everything
  // else about grid mode (square rendering, layout, test orders) stays
  // exactly as-is. Flip to true once grid mode is actually going live for
  // real orders; until then, the table is mostly run in "demo" mode where
  // no one needs guide→matched transitions to work, and this same
  // detection logic being reliable enough to work at all for real cups is
  // exactly what also makes it reliably surface pre-existing sensor noise
  // (see the amplitude-fallback "ICE_CUP" false-positive investigation —
  // tof_camera's own ICE_CUP_ASSUMED_DIAMETER_MM=80 constant) as
  // permanently-"matched" squares in demo mode, which nobody wants to see
  // right now. Turning this off makes guide squares stay dashed forever
  // (never flip to matched, real cup or not) instead of reverting to any
  // of the specific older buggy behaviors this session fixed one at a
  // time — a clean, single, easily-reversible switch rather than
  // resurrecting dead code paths.
  static const bool _gridOccupancyDetectionEnabled = true;

  void _clearGridState() {
    _gridCellGroups.clear();
    _gridRowWidths.clear();
    _gridMatchedAt.clear();
    _gridEmptiedAt.clear();
    _gridGhostMessage.clear();
    _occupiedGridCells = {};
    _gridPinnedOrderNos.clear();
    _testOrderNos.clear();
    _gridOccupiedSince.clear();
    _gridEmptySince.clear();
  }

  Timer? _adTimer;
  // Re-runs _updateGridOccupancy on its own clock, independent of whether a
  // new ToF frame actually arrives — see that method's own doc comment for
  // why this exists: the native ToF pipeline (tof_camera project,
  // depth_tracking.cpp's object_update_transfor) only publishes a new MQTT
  // frame when something CHANGES (an object gets newly confirmed, the
  // object count differs from what was last sent, a tracked object times
  // out) — a cup sitting motionless on its cell forever afterward produces
  // ZERO further frames, so _handleTofFrame (the only other place that
  // calls _updateGridOccupancy) simply never runs again to notice that
  // enough real time has now passed. This timer is the only thing that
  // lets a purely time-based debounce (_gridDebounceDuration) actually
  // fire without requiring the scene to keep changing.
  Timer? _gridOccupancyTimer;
  static const Duration _gridOccupancyPollInterval = Duration(milliseconds: 150);

  DateTime? _lastHeartbeatLog;

  Size _screenSize = const Size(1920, 1080);

  // 상업용 모드: 인접 슬롯 판별용 열 수 (고정 200px 기준, 이웃 인덱스 계산에만 사용)
  static const int _gridCols = 1920 ~/ 200; // 9열 (slotSize=200 기준)

  /// This app's display is a fixed-resolution kiosk screen that never
  /// resizes/rotates at runtime — the widget calls this once (from
  /// didChangeDependencies) with MediaQuery.of(context).size so the
  /// per-frame processing below can use the exact same numeric value the
  /// old MediaQuery.of(context).size read inside _processCupUpdate would
  /// have produced, without this Cubit needing a BuildContext.
  void setScreenSize(Size size) {
    _screenSize = size;
  }

  void onAppResumed() {
    // connect()는 이미 연결된 상태면 조용히 no-op이라(중복 연결 방지 가드),
    // 앱이 백그라운드에서 돌아올 때마다 안전하게 호출 가능.
    unawaited(_pickupRepository.connect());
  }

  Color getColorForId(int id) {
    if (id < 0) return Colors.white54;
    return _idPalette[id % _idPalette.length];
  }

  String _getGuideLabel(String orderNo) {
    final orderData = _orderRepository.waitingQueue.firstWhere(
      (o) => o['orderNo'] == orderNo,
      orElse: () => {'nickname': '', 'orderNo': orderNo},
    );
    return _buildComplexLabel(orderData);
  }

  Future<void> _loadIcons() async {
    final icons = <String, ui.Image>{};
    icons['☕'] = await _loadImage('assets/images/drink.png');
    icons['🥪'] = await _loadImage('assets/images/food.png');
    icons['🍾'] = await _loadImage('assets/images/bottle.png');
    if (!isClosed) emit(state.copyWith(iconImages: icons));
  }

  Future<ui.Image> _loadImage(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  Future<void> _loadSavedCalibration() async {
    final prefs = await SharedPreferences.getInstance();
    final String? coeffsJson = prefs.getString('polynomial_coeffs');
    if (coeffsJson != null) {
      List<double> coeffs = List<double>.from(jsonDecode(coeffsJson));
      _coordinateRepository.setHomographyMatrix(coeffs);
    }

    final double? savedHeight = prefs.getDouble('sensor_height');
    if (savedHeight != null) {
      AppConstants.totalSensorHeight = savedHeight;
      debugPrint("📏 저장된 설치 높이 복구 완료: ${savedHeight}mm");
    }

    _irValue = prefs.getInt('ir_value') ?? 51;
    // _lastSentIrValue는 null로 유지: 앱 시작 후 Pi가 처음 접속할 때 반드시 한 번 전송하도록 함.
  }

  void sendIrValueToPi(int newValue) async {
    int clampedValue = newValue.clamp(0, 61);
    if (_lastSentIrValue == clampedValue) return;
    _irValue = clampedValue;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('ir_value', clampedValue);

    final Map<String, dynamic> irPayload = {
      "event_type": "set_ir",
      "ir_value": clampedValue,
    };
    _pickupRepository.publishControlCommand(irPayload);

    _lastSentIrValue = clampedValue;

    _irSentRecently = true;
    _irSentTimer?.cancel();
    _irSentTimer = Timer(const Duration(seconds: 5), () {
      _irSentRecently = false;
    });

    debugPrint("📤 [IR_CONTROL] IR Value Broadcast: $clampedValue");
  }

  String _buildComplexLabel(Map<String, dynamic> info) {
    List<String> icons = [];
    if ((info['drinkCount'] ?? 0) > 0) icons.add("☕${info['drinkCount']}");
    if ((info['foodCount'] ?? 0) > 0) icons.add("🥪${info['foodCount']}");
    if ((info['bottleCount'] ?? 0) > 0) icons.add("🍾${info['bottleCount']}");

    String prefix = icons.isNotEmpty ? "${icons.join(" ")} | " : "";
    String name = (info['nickname'] != null && info['nickname'] != "")
        ? info['nickname']
        : "${info['orderNo']}";

    return "$prefix$name";
  }

  bool _hasSignificantChange(List<TofObject> newObjs, List<TofObject> oldObjs) {
    if (newObjs.length != oldObjs.length) return true;

    for (var newObj in newObjs) {
      var oldObj = oldObjs.firstWhere(
        (o) => o.id == newObj.id,
        orElse: () => TofObject(
            id: -1, x: 0, y: 0, z: 0, diameter: 0, width: 0, height: 0, isStable: false),
      );
      if (oldObj.id == -1) return true;

      double dx = newObj.x - oldObj.x;
      double dy = newObj.y - oldObj.y;
      double distance = sqrt(dx * dx + dy * dy);
      if (distance > _movementThreshold) return true;
    }
    return false;
  }

  final List<LogItem> _consoleLogs = [];

  void _addLog(String type, String message, {int? frameId, int? objectId, bool force = false}) {
    if (isClosed) return;
    // MQTT 연결/끊김("SYS")을 포함해 이 경로를 타는 모든 로그를 diag_log.txt에도
    // 남긴다 - 화면 콘솔은 최근 50개만 메모리에 남지만, 진단 로그는 파일로
    // 영구 보존돼서 몇 시간 뒤 문제가 재발했을 때도 그때 상황을 볼 수 있다.
    DiagLogger.log(type, message);
    if (_consoleLogs.length > 50) _consoleLogs.removeAt(0);

    String time = DateTime.now().toIso8601String().substring(11, 19);
    _consoleLogs.add(LogItem(
      timestamp: time,
      type: type,
      message: message,
      frameId: frameId,
      objectId: objectId,
    ));
    if (state.isConsoleOpen || force) {
      emit(state.copyWith(consoleLogs: List.of(_consoleLogs), frameRevision: state.frameRevision + 1));
    }
  }

  void toggleConsole() {
    emit(state.copyWith(isConsoleOpen: !state.isConsoleOpen));
  }

  void setShowRawData(bool value) {
    emit(state.copyWith(showRawData: value));
  }

  void clearConsoleLogs() {
    _consoleLogs.clear();
    emit(state.copyWith(consoleLogs: const []));
  }

  Future<void> processCalibration(List<CalibrationPair> data) async {
    try {
      debugPrint("🚀 [ROI_DEBUG] --- ROI 계산 시작 ---");

      final srcPoints = data.map((e) => Point(e.src.dx, e.src.dy)).toList();
      final zValues = data.map((e) => e.z).toList();
      final dstPoints = data.map((e) => Point(e.dst.dx, e.dst.dy)).toList();

      final List<double> hMatrix = _coordinateRepository.solveHomography(srcPoints, zValues, dstPoints);

      _coordinateRepository.setHomographyMatrix(hMatrix);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('polynomial_coeffs', jsonEncode(hMatrix));
      debugPrint("✅ [Save] 호모그래피 행렬 저장 완료");

      await prefs.setDouble('sensor_height', AppConstants.totalSensorHeight);

      final Matrix H = Matrix.fromList([
        [hMatrix[0], hMatrix[1], hMatrix[2]],
        [hMatrix[3], hMatrix[4], hMatrix[5]],
        [hMatrix[6], hMatrix[7], hMatrix[8]],
      ], dtype: DType.float64);

      final Matrix hInv = H.inverse();

      final List<Map<String, dynamic>> roiConfigs = [
        {"id": 1, "name": "Top-Left", "pos": const Offset(0, 0)},
        {"id": 2, "name": "Top-Right", "pos": const Offset(1920, 0)},
        {"id": 3, "name": "Bottom-Left", "pos": const Offset(0, 1080)},
        {"id": 4, "name": "Bottom-Right", "pos": const Offset(1920, 1080)},
        {"id": 5, "name": "Center", "pos": const Offset(960, 540)},
      ];

      List<Map<String, dynamic>> roiPoints = [];

      for (var config in roiConfigs) {
        final Offset uiPos = config["pos"] as Offset;

        final Matrix uiMatrix = Matrix.fromList([[uiPos.dx], [uiPos.dy], [1.0]], dtype: DType.float64);
        final Matrix resultMatrix = hInv * uiMatrix;
        final List<double> sensorFloorVec = resultMatrix.getColumn(0).toList();
        double wPrime = sensorFloorVec[2];
        if (wPrime == 0) wPrime = 1.0;

        double finalX = sensorFloorVec[0] / wPrime;
        double finalY = sensorFloorVec[1] / wPrime;

        finalX = finalX.clamp(0.0, 640.0);
        finalY = finalY.clamp(0.0, 480.0);

        debugPrint(
            "📍 [ROI_FINAL] ${config['name']}: UI(${uiPos.dx.toInt()}, ${uiPos.dy.toInt()}) -> Raw(${finalX.toStringAsFixed(1)}, ${finalY.toStringAsFixed(1)})");

        roiPoints.add({"id": config["id"], "x": finalX, "y": finalY});
      }

      final Map<String, dynamic> roiPayload = {
        "event_type": "set_roi",
        "timestamp": DateTime.now().toIso8601String(),
        "roi_points": roiPoints,
      };
      String packet = jsonEncode(roiPayload);

      _pickupRepository.publishControlCommand(roiPayload);
      debugPrint("📤 [ROI_DEBUG] Packet Sent: $packet");
    } catch (e, stack) {
      debugPrint("❌ [ROI_DEBUG] Error: $e");
      debugPrint(stack.toString());
    }
  }

  void _initializeServer() {
    _mqttLogSubscription = _pickupRepository.logStream.listen((msg) => _addLog("SYS", msg, force: true));
    _customerScanSubscription = _pickupRepository.customerScanStream.listen(_handleCustomerScan);
    _tofFrameSubscription = _pickupRepository.tofFrameStream.listen(_handleTofFrame);
    _orderReadySubscription = _pickupRepository.orderReadyStream.listen((_) => _handleOrderReady());
    _calibrationRequestedSubscription =
        _pickupRepository.calibrationRequestedStream.listen(_handleCalibrationRequested);
    _themeChangedSubscription =
        _pickupRepository.themeChangedStream.listen(_handleThemeChanged);
    _createTestOrdersSubscription =
        _pickupRepository.createTestOrdersStream.listen((_) => _createTestOrders());
    _clearTestOrdersSubscription =
        _pickupRepository.clearTestOrdersStream.listen((_) => _clearTestOrders());
    // themeOverride now defaults to Forest Green (grid mode from boot, no
    // FlowHub message required) — start the occupancy timer up front to
    // match, instead of only when a real SET_PICKUP_TABLE_THEME message
    // first arrives (see _startGridOccupancyTimer's own doc comment).
    if (state.themeOverride != null) {
      _startGridOccupancyTimer();
    }
    unawaited(_pickupRepository.connect());
    unawaited(_languageRepository.load());
  }

  /// FlowHub's Pickup Table Theme screen — [themeJson] null means Reset
  /// (back to the original, unthemed circle-based rendering); otherwise
  /// parses {background,style,dotStyle,backgroundImage,colorOverrides} into
  /// the override the build() methods below switch on. A malformed payload
  /// is treated the same as Reset rather than crashing or silently keeping
  /// the previous theme.
  void _handleThemeChanged(Map<String, dynamic>? themeJson) {
    if (themeJson == null) {
      emit(state.copyWith(themeOverride: null));
      _syncGridModeEnabled();
      return;
    }
    try {
      final selection = PickupTableThemeSelection.fromJson(themeJson);
      _orderRepository.gridModeEnabled = true;
      _startGridOccupancyTimer();
      emit(state.copyWith(themeOverride: selection));
    } catch (e) {
      debugPrint('⚠️ SET_PICKUP_TABLE_THEME parse failed ($themeJson): $e — resetting instead');
      emit(state.copyWith(themeOverride: null));
      _syncGridModeEnabled();
    }
  }

  /// Grid mode (and its timer/state) should stay on as long as the theme
  /// feature is active, and tear down once it's back to unthemed.
  void _syncGridModeEnabled() {
    if (state.themeOverride == null) {
      _orderRepository.gridModeEnabled = false;
      _stopGridOccupancyTimer();
      _clearGridState();
    }
  }

  /// Starts (or restarts) the timer described on [_gridOccupancyTimer]'s own
  /// field doc comment — periodic, theme-independent re-checks of grid
  /// occupancy so the time-based debounce can fire even when the ToF
  /// pipeline itself has gone quiet because nothing in the scene changed.
  void _startGridOccupancyTimer() {
    _gridOccupancyTimer?.cancel();
    if (!_gridOccupancyDetectionEnabled) return;
    _gridOccupancyTimer = Timer.periodic(_gridOccupancyPollInterval, (_) {
      if (isClosed) return;
      if (_updateGridOccupancy()) {
        emit(state.copyWith(frameRevision: state.frameRevision + 1));
      }
    });
  }

  void _stopGridOccupancyTimer() {
    _gridOccupancyTimer?.cancel();
    _gridOccupancyTimer = null;
  }

  void _handleOrderReady() {
    _updateGuidePositions();
    _updateGridCellGroups();
    emit(state.copyWith(guidePositions: Map.of(_guidePositions), frameRevision: state.frameRevision + 1));
  }

  /// FlowHub's Pickup Table Theme screen's "Create Test Orders" button —
  /// runs a fixed batch of synthetic orders through the exact same
  /// addReadyOrder -> grid-allocation path a real KDS ORDER_READY would,
  /// so every themed color/shape can be checked without waiting for real
  /// orders to come in. Labels match the real leading-letter + digits
  /// format (see flowhub's splitOrderNoForDisplay — "M"/"K" for mobile/
  /// kiosk are the common case), in the unused 9000s range (M9001-K9003,
  /// K9102/M9103) and alternating M/K so both prefixes actually get
  /// exercised: 3 single-cup (M9001 stays plain — place an actual cup on it
  /// to watch guide -> matched happen for real; K9002 is faked straight
  /// into an 11-minutes-ago "matched" state, pinned so real cup detection
  /// never touches it, to preview the timed-out color without an actual
  /// 10-minute wait; M9003 is likewise faked straight into the receipt-
  /// scanned "highlighted" state) plus one each of 2/3-cup (K9102/M9103 —
  /// the middle digit is the cup count, purely for this doc comment's own
  /// bookkeeping, not meaningful to anyone reading the label on screen) to
  /// check multi-cell connected-group allocation. Idempotent — clears any
  /// previous test batch first, so pressing this again without clearing is
  /// always safe.
  void _createTestOrders() {
    _clearTestOrders();

    const singles = ['M9001', 'K9002', 'M9003'];
    const timedOutOrderNo = 'K9002';
    // Receipt-scan preview — separate from timedOutOrderNo since the two
    // have their own colors (see ThemedPlacedEmphasis.highlighted vs
    // .timedOut). Same trick as the timed-out one: fake the state directly
    // instead of waiting for a real QR scan, so the receiptScanGradient +
    // blink can be checked visually right away.
    const highlightedOrderNo = 'M9003';
    const multi = {'K9102': 2, 'M9103': 3};

    for (final no in singles) {
      _orderRepository.addReadyOrder(no, 'TEST', '', 1, 0, 0, 1, '');
      _testOrderNos.add(no);
    }
    for (final entry in multi.entries) {
      _orderRepository.addReadyOrder(entry.key, 'TEST', '', entry.value, 0, 0, entry.value, '');
      _testOrderNos.add(entry.key);
    }

    _updateGridCellGroups();

    if (_gridCellGroups.containsKey(timedOutOrderNo)) {
      _gridMatchedAt[timedOutOrderNo] = DateTime.now().subtract(const Duration(minutes: 11));
      _gridPinnedOrderNos.add(timedOutOrderNo);
    }

    Set<String> highlightedOrders = state.highlightedOrders;
    if (_gridCellGroups.containsKey(highlightedOrderNo)) {
      // Matched (not timed out) + highlighted, so buildGridOrderGroups picks
      // GridSlotState.highlighted over .matched — see its own isHighlighted/
      // isTimedOut precedence check.
      _gridMatchedAt[highlightedOrderNo] = DateTime.now();
      _gridPinnedOrderNos.add(highlightedOrderNo);
      highlightedOrders = Set<String>.of(highlightedOrders)..add(_qrOrderNo(highlightedOrderNo));
    }

    emit(state.copyWith(frameRevision: state.frameRevision + 1, highlightedOrders: highlightedOrders));
  }

  /// FlowHub's Pickup Table Theme screen's "Clear Test Orders" button —
  /// removes every order [_createTestOrders] made (tracked by orderNo in
  /// [_testOrderNos]), regardless of which bucket (waiting queue, active
  /// match, grid group) each ended up in, and nothing else — a real
  /// order's own bookkeeping is untouched.
  void _clearTestOrders() {
    if (_testOrderNos.isEmpty) return;
    for (final no in List<String>.of(_testOrderNos)) {
      _orderRepository.clearOrderFromQueue(no);
      // A test order a tester actually placed a real cup on may have been
      // FIFO-matched into activeMatches by the (always-running, theme-
      // independent) legacy pipeline — clearOrderFromQueue alone doesn't
      // reach that, so release it by stableKey too.
      final staleKeys = _orderRepository.activeMatches.entries
          .where((e) => e.value['orderNo'] == no)
          .map((e) => e.key)
          .toList();
      for (final key in staleKeys) {
        _orderRepository.releaseId(key);
      }
      _gridCellGroups.remove(no);
      _gridRowWidths.remove(no);
      _gridMatchedAt.remove(no);
      _gridEmptiedAt.remove(no);
      _gridGhostMessage.remove(no);
      _gridPinnedOrderNos.remove(no);
      // Test order labels are reused verbatim every run (M9001 etc.) — a
      // leftover timestamp here from a previous round would make
      // _updateGridOccupancy's debounce think a brand new occupancy has
      // already been sitting there since before this round even started,
      // firing an instant false "matched" the moment the cell is next
      // touched at all, real cup or not.
      _gridOccupiedSince.remove(no);
      _gridEmptySince.remove(no);
    }
    // _createTestOrders's synthetic "already receipt-scanned" test order
    // sets this directly (bypassing the real QR-scan path) — clear it back
    // out too, or a re-run would find it already highlighted from the
    // previous round.
    final clearedHighlighted = Set<String>.of(state.highlightedOrders)
      ..removeWhere((qrNo) => _testOrderNos.any((no) => _qrOrderNo(no) == qrNo));
    _testOrderNos.clear();
    _updateGridCellGroups();
    emit(state.copyWith(frameRevision: state.frameRevision + 1, highlightedOrders: clearedHighlighted));
  }

  void _handleCalibrationRequested(CalibrationRequest request) {
    AppConstants.totalSensorHeight = request.height;
    debugPrint("✅ [HEIGHT_CHECK] AppConstants.totalSensorHeight is now: ${AppConstants.totalSensorHeight}");
    _coordinateRepository.resetMatrix();
    // Tell the ToF sensor the table's physical geometry (display model +
    // real edge margin) before cal_restart, so flattenOutsideTableArea()
    // already has it for the very first background-reference frame.
    // display_width_mm/height_mm are only added for a display outside the
    // 430A/500A/550A presets (FlowHub's "직접입력" custom-size path) — their
    // absence here is itself the signal tof_camera uses to fall back to
    // the display_model preset lookup instead.
    final geometryPayload = {
      "event_type": "set_table_geometry",
      "display_model": request.displayModel,
      "edge_margin_mm": request.edgeMarginMm,
      if (request.displayWidthMm != null && request.displayHeightMm != null) ...{
        "display_width_mm": request.displayWidthMm,
        "display_height_mm": request.displayHeightMm,
      },
    };
    _pickupRepository.publishControlCommand(geometryPayload);
    const calRestartPayload = {"event_type": "cal_restart"};
    _pickupRepository.publishControlCommand(calRestartPayload);
    emit(state.copyWith(isCalibrating: true));
  }

  void notifyValidationEntered() => _pickupRepository.publishCalibrationStatus("VALIDATION_MODE");

  void notifyCalibrationExit() => _pickupRepository.publishCalibrationStatus("CALIB_EXIT");

  void cancelCalibration() {
    _pickupRepository.publishCalibrationStatus("CALIB_EXIT");
    emit(state.copyWith(isCalibrating: false));
  }

  void completeCalibration(List<CalibrationPair> data) {
    // exit 신호는 onCalibExit에서 이미 처리됨
    emit(state.copyWith(isCalibrating: false));
    unawaited(processCalibration(data));
  }

  void _handleTofFrame(TofFrame frame) {
    // [REVERTED] frame.baseZ(카메라 자체 실측값)를 여기서 AppConstants.
    // totalSensorHeight에 자동 반영하는 시도를 했었으나, 되돌렸다 — 지금
    // 테이블은 디스플레이 위에 강화유리가 덮여있어 유리 굴절/유리-디스플레이
    // 사이 공극 때문에 센서 실측값이 실제 거리(카메라~유리, 정확히 1000mm로
    // 알고 있음)보다 살짝 더 멀게(예: 1020) 나온다 — 즉 지금 구성에서는
    // base_z 쪽이 오히려 덜 정확하다. 나중에 유리 없이 디스플레이에 직접
    // 얹는 구성으로 바뀌면 이 자동 반영을 다시 검토할 것.
    if (frame.objects.isNotEmpty) {
      var obj = frame.objects.first;
      emit(state.copyWith(
        latestRawForCalib: _coordinateRepository.getFloorProjectedOffset(obj.x, obj.y, obj.z),
        lastFrameObjects: frame.objects,
      ));
    }

    // 컵/손 관리 로직(UI 위젯 생성)은 캘리브레이션 중에는 중단
    if (state.isCalibrating) return;
    if (frame.eventType == 'object_tracking') {
      _processHandTracking(frame);
    } else {
      _processCupUpdate(frame);
      // state.objects가 _processCupUpdate의 emit으로 이미 최신 상태이므로
      // 여기서 바로 읽어도 됨 — 그리드 모드가 아니면 내부에서 즉시 no-op.
      _updateGridOccupancy();
      if (_orderRepository.gridModeEnabled) {
        // _processCupUpdate가 이미 이번 프레임에 한 번 emit했으므로, 방금
        // 바뀐 그리드 점유/매칭 상태(_gridMatchedAt/_gridEmptiedAt)까지
        // 반영하려면 한 번 더 emit해야 위젯이 최신 상태로 다시 그려짐.
        emit(state.copyWith(frameRevision: state.frameRevision + 1));
      }
    }
  }

  /// 고객이 영수증(현재는 테스트로 라벨) QR을 스캔하면 호출됨 — 매칭되는
  /// baseCircle의 색상을 강조 상태로 전환.
  void _handleCustomerScan(String orderNo) {
    final updated = Set<String>.of(state.highlightedOrders)..add(_qrOrderNo(orderNo));
    emit(state.copyWith(highlightedOrders: updated));
  }

  // KDS prints the QR with its leading letter stripped — a label scan always
  // comes back digit-only, while rawOrderNo here is stored in its full form.
  String _qrOrderNo(String orderNo) => orderNo.replaceFirst(RegExp(r'^[A-Za-z]+'), '');

  void _resetHandDetectionTimer() {
    _handDetectionTimer?.cancel();
    _handDetectionTimer = Timer(const Duration(milliseconds: 800), () {
      if (!isClosed && state.isHandDetected) {
        DiagLogger.log("HAND", "EXIT");
        emit(state.copyWith(isHandDetected: false));
      }
    });
  }

  void _processHandTracking(TofFrame frame) {
    if (state.isConsoleOpen && state.showRawData && frame.frameId % 5 == 0) {
      _addLog("TRK", "=== [Tracking] Frame: ${frame.frameId} (Count: ${frame.objects.length}) ===",
          frameId: frame.frameId);
      for (var obj in frame.objects) {
        _addLog(
          "TRK",
          "  > [HandID:${obj.id}] "
              "x:${obj.x.toStringAsFixed(0)}, "
              "y:${obj.y.toStringAsFixed(0)}, "
              "z:${obj.z.toStringAsFixed(0)}, "
              "w:${obj.width.toStringAsFixed(0)}, "
              "h:${obj.height.toStringAsFixed(0)}",
          frameId: frame.frameId,
          objectId: obj.id,
        );
      }
    }

    _resetHandDetectionTimer();

    if (!state.isHandDetected) {
      DiagLogger.log("HAND", "ENTER");
      emit(state.copyWith(isHandDetected: true, currentLatestFrameId: frame.frameId));
    } else {
      emit(state.copyWith(currentLatestFrameId: frame.frameId));
    }
  }

  void _processCupUpdate(TofFrame frame) {
    // z(높이)가 0 이하로 들어오면 transform이 시차 보정 비율을 0으로
    // 만들어버려서, 원래 x/y가 뭐였든 상관없이 화면 정중앙으로 매핑돼버린다 —
    // 라즈베리파이가 주기적으로 보내는 무효(높이 미측정) 프레임이 이 경로로
    // 들어와 가끔 정중앙에 원이 찍히던 원인. 지름/너비/높이도 방어적으로
    // 같이 걸러낸다(0 이하면 애초에 물체가 아님).
    final validTofObjects = frame.objects
        .where((obj) =>
            obj.x > 5 &&
            obj.y > 5 &&
            obj.x < 560 &&
            obj.z > 0 &&
            obj.diameter > 0 &&
            obj.width > 0 &&
            obj.height > 0)
        .toList();

    if (validTofObjects.isNotEmpty) {
      for (var obj in validTofObjects) {
        _coordinateRepository.logTrace("TEST_#LIVE", obj.x, obj.y, obj.z);
      }
    }

    final Size screenSize = _screenSize;
    final Offset screenCenter = Offset(screenSize.width / 2, screenSize.height / 2);
    const double pickupZoneHalfWidth = _pickupZoneWidth / 2;
    const double pickupZoneHalfHeight = _pickupZoneHeight / 2;

    List<Map<String, dynamic>> rawEntries = [];
    for (final tof in validTofObjects) {
      Offset mathPos = _coordinateRepository.transform(tof.x, tof.y, tof.z);
      Offset visualPos = mathPos;

      // 영상 안전 영역 밖이면 물체로 취급하지 않음 — 손 오탐지 방지.
      if ((visualPos.dx - screenCenter.dx).abs() > pickupZoneHalfWidth ||
          (visualPos.dy - screenCenter.dy).abs() > pickupZoneHalfHeight) {
        continue;
      }

      // 상업용 모드: 활성화된 그리드 슬롯 외부 물체는 완전 무시
      if (AppConstants.isCommercialMode) {
        const double slotHalfSize = 100.0;
        final bool isInAnySlot = _guidePositions.values.any((slotCenter) =>
            visualPos.dx >= slotCenter.dx - slotHalfSize &&
            visualPos.dx <= slotCenter.dx + slotHalfSize &&
            visualPos.dy >= slotCenter.dy - slotHalfSize &&
            visualPos.dy <= slotCenter.dy + slotHalfSize);
        if (!isInAnySlot) continue;
      }

      rawEntries.add({'raw': tof, 'pos': visualPos, 'mathPos': mathPos});
    }

    final objects = state.objects;
    List<DetectedObject> tempList = [];
    // 50px 매칭에 실패한 기존 컵들 — 바로 제거 처리하지 않고 일단 보류.
    List<DetectedObject> unmatchedExisting = [];

    // 2. 기존 컵 유지 및 매칭 — 위치(50px 이내)만으로 "같은 물리적 컵"인지 판단.
    for (var existing in objects) {
      int closestIndex = -1;
      double minDistance = 50.0;

      for (int i = 0; i < rawEntries.length; i++) {
        double dist = (existing.position - (rawEntries[i]['pos'] as Offset)).distance;
        if (dist < minDistance) {
          minDistance = dist;
          closestIndex = i;
        }
      }

      if (closestIndex != -1) {
        var matched = rawEntries.removeAt(closestIndex);
        var tof = matched['raw'] as TofObject;
        var visualPos = matched['pos'] as Offset;

        // 겹침(occlusion merge) 진단: 같은 stableKey로 계속 추적되는 도중
        // 바운딩박스 크기가 갑자기 크게 뛰면(옆 컵과 합쳐졌을 가능성) 남김.
        final prevSize = _lastLoggedSizeByStableKey[existing.stableKey];
        if (prevSize != null) {
          final double dDiameter = tof.diameter - prevSize.diameter;
          final double dWidth = tof.width - prevSize.width;
          final double dHeight = tof.height - prevSize.height;
          if (dDiameter.abs() >= _mergeSizeJumpThresholdMm ||
              dWidth.abs() >= _mergeSizeJumpThresholdMm ||
              dHeight.abs() >= _mergeSizeJumpThresholdMm) {
            DiagLogger.log(
                "SIZE_JUMP",
                "stableKey=${existing.stableKey} objectId=${tof.id} "
                "diameter=${prevSize.diameter.toStringAsFixed(0)}->${tof.diameter.toStringAsFixed(0)}(Δ${dDiameter.toStringAsFixed(0)}) "
                "width=${prevSize.width.toStringAsFixed(0)}->${tof.width.toStringAsFixed(0)}(Δ${dWidth.toStringAsFixed(0)}) "
                "height=${prevSize.height.toStringAsFixed(0)}->${tof.height.toStringAsFixed(0)}(Δ${dHeight.toStringAsFixed(0)}) "
                "pos=(${visualPos.dx.toStringAsFixed(0)},${visualPos.dy.toStringAsFixed(0)}) "
                "cell=${PickupTableGridLayout.nearestCellIndex(visualPos)} isAmp=${tof.isAmplitude}");
          }
        }
        _lastLoggedSizeByStableKey[existing.stableKey] = tof;

        // amplitude(아이스컵) 위치 흔들림 측정용 — 매칭될 때마다 남김.
        // tof가 "변화 있을 때만" 프레임을 보내므로(변화 없으면 프레임 자체가
        // 안 옴), 여기 로그되는 매 항목이 실제 위치 변화를 나타낸다.
        if (tof.isAmplitude) {
          final prevIcePos = _lastLoggedIcePosByStableKey[existing.stableKey];
          if (prevIcePos != null) {
            final double moved = (visualPos - prevIcePos).distance;
            DiagLogger.log(
                "ICE_JITTER",
                "stableKey=${existing.stableKey} objectId=${tof.id} "
                "from=(${prevIcePos.dx.toStringAsFixed(1)},${prevIcePos.dy.toStringAsFixed(1)}) "
                "to=(${visualPos.dx.toStringAsFixed(1)},${visualPos.dy.toStringAsFixed(1)}) "
                "moved=${moved.toStringAsFixed(1)}px "
                "cell=${PickupTableGridLayout.nearestCellIndex(visualPos)}");
          }
          _lastLoggedIcePosByStableKey[existing.stableKey] = visualPos;
        }

        final orderInfo = _orderRepository.getMatchedOrder(existing.stableKey);
        if (orderInfo != null) orderInfo['pos'] = visualPos;
        final String displayLabel = orderInfo != null ? _buildComplexLabel(orderInfo) : "UNKNOWN";

        tempList.add(DetectedObject(
          id: tof.id,
          orderNo: displayLabel,
          position: visualPos,
          zValue: tof.z,
          diameter: _coordinateRepository.getUiDiameter(tof.diameter),
          uiWidth: _coordinateRepository.getUiSize(tof.width, tof.height).width,
          uiHeight: _coordinateRepository.getUiSize(tof.width, tof.height).height,
          color: orderInfo?['color'] ?? Colors.white54,
          stableKey: existing.stableKey,
          rawOrderNo: orderInfo?['orderNo']?.toString() ?? '',
          lang: orderInfo?['lang']?.toString() ?? '',
          isAmplitude: tof.isAmplitude,
        ));
      } else {
        unmatchedExisting.add(existing);
      }
    }

    // 2.5. 큰 이동 예외 — "매칭 실패한 기존 컵 1개 + 남은 raw 1개"로 정확히
    // 1:1일 때만, 그리고 지금 미해결 가이드가 하나도 없을 때만 거리 제한 없이
    // 그대로 이어붙인다.
    if (unmatchedExisting.length == 1 && rawEntries.length == 1 && _guidePositions.isEmpty) {
      final existing = unmatchedExisting.removeAt(0);
      final matched = rawEntries.removeAt(0);
      final tof = matched['raw'] as TofObject;
      final visualPos = matched['pos'] as Offset;

      final orderInfo = _orderRepository.getMatchedOrder(existing.stableKey);
      if (orderInfo != null) orderInfo['pos'] = visualPos;
      final String displayLabel = orderInfo != null ? _buildComplexLabel(orderInfo) : "UNKNOWN";

      // 겹침 진단: 50px 근접 매칭에 실패할 만큼 위치가 크게 튄 것 자체가,
      // 옆 셀 물체와 합쳐지거나(id가 다른 물체로 넘어감) 분리되는 순간일
      // 수 있어 남긴다 — SIZE_JUMP와 별개로 "위치 점프"를 직접 잡는 로그.
      DiagLogger.log(
          "BIG_JUMP",
          "stableKey=${existing.stableKey} objectId=${tof.id} "
          "from=(${existing.position.dx.toStringAsFixed(0)},${existing.position.dy.toStringAsFixed(0)}) "
          "to=(${visualPos.dx.toStringAsFixed(0)},${visualPos.dy.toStringAsFixed(0)}) "
          "fromCell=${PickupTableGridLayout.nearestCellIndex(existing.position)} "
          "toCell=${PickupTableGridLayout.nearestCellIndex(visualPos)} "
          "diameter=${tof.diameter.toStringAsFixed(0)} isAmp=${tof.isAmplitude}");
      _lastLoggedSizeByStableKey[existing.stableKey] = tof;
      if (tof.isAmplitude) _lastLoggedIcePosByStableKey[existing.stableKey] = visualPos;

      tempList.add(DetectedObject(
        id: tof.id,
        orderNo: displayLabel,
        position: visualPos,
        zValue: tof.z,
        diameter: _coordinateRepository.getUiDiameter(tof.diameter),
        uiWidth: _coordinateRepository.getUiSize(tof.width, tof.height).width,
        uiHeight: _coordinateRepository.getUiSize(tof.width, tof.height).height,
        color: orderInfo?['color'] ?? Colors.white54,
        stableKey: existing.stableKey,
        rawOrderNo: orderInfo?['orderNo']?.toString() ?? '',
        lang: orderInfo?['lang']?.toString() ?? '',
        isAmplitude: tof.isAmplitude,
      ));
    }

    // 2.6. 위 예외로 구제되지 못하고 여전히 남은 기존 컵들 — 진짜로 사라진
    // 것으로 확정.
    final ghostCircles = Map<String, Map<String, dynamic>>.of(state.pickupGhostCircles);
    for (var existing in unmatchedExisting) {
      DiagLogger.log("CUP_REMOVE", "stableKey=${existing.stableKey} orderNo=${existing.rawOrderNo} "
          "pos=(${existing.position.dx.toStringAsFixed(0)},${existing.position.dy.toStringAsFixed(0)}) "
          "cell=${PickupTableGridLayout.nearestCellIndex(existing.position)} "
          "isAmp=${existing.isAmplitude} remaining_before_add=${tempList.length}");
      _lastLoggedSizeByStableKey.remove(existing.stableKey);
      _lastLoggedIcePosByStableKey.remove(existing.stableKey);
      final removedOrder = _orderRepository.releaseId(existing.stableKey);
      _exitingObjects.add(existing);

      if (removedOrder != null && removedOrder['orderNo'] != "UNKNOWN") {
        String actualOrderNo = removedOrder['orderNo'].toString();

        final String lang = (removedOrder['lang'] as String?)?.isNotEmpty == true
            ? removedOrder['lang'] as String
            : AppConstants.fallbackLanguage;
        final String ghostKey = '${actualOrderNo}_${existing.stableKey}';
        ghostCircles[ghostKey] = {
          'orderNo': actualOrderNo,
          'label': existing.orderNo,
          'position': existing.position,
          'diameter': existing.diameter,
          'message': _languageRepository.pickupMessageFor(lang),
          'lang': lang,
        };

        // 5초(고스트 시간) 대기 타이머 시작 — ghostKey(컵 단위)로 관리해서
        // 같은 주문의 다른 컵이 거의 동시에 사라져도 서로의 타이머를
        // 취소하지 않는다.
        _pickupTimers[ghostKey] = Timer(_orderRepository.ghostDuration, () {
          if (isClosed) return;

          bool isStillOnTable =
              _orderRepository.activeMatches.values.any((match) => match['orderNo'].toString() == actualOrderNo);
          bool hasOtherGhosts = _orderRepository.ghostMemory.any((ghost) => ghost.orderNo == actualOrderNo);
          final bool isPickupComplete = !isStillOnTable && !hasOtherGhosts;
          // Grid mode fires the real completion from _completeGridOrder
          // instead, keyed off which CELL actually emptied — this legacy
          // per-cup path's actualOrderNo comes from OrderManager's blind
          // FIFO getOrAssignOrder, which has no idea which grid cell the
          // cup was physically on, so under grid mode it can name a
          // completely different order than the one that's really done.
          final bool fireRealCompletion = isPickupComplete && !_orderRepository.gridModeEnabled;

          if (fireRealCompletion) {
            _pickupRepository.sendPickupComplete(actualOrderNo);
            debugPrint("📢 [Auto-Pickup] $actualOrderNo번 모든 컵 제거 확인 -> KDS 신호 전송");
          }

          _pickupTimers.remove(ghostKey);
          final updatedGhosts = Map<String, Map<String, dynamic>>.of(state.pickupGhostCircles);
          var updatedHighlighted = state.highlightedOrders;
          if (fireRealCompletion) {
            // 픽업 완료 확정: waitingQueue 잔류 항목을 먼저 제거해야
            // _updateGuidePositions()가 그리드를 재생성하지 않는다.
            _orderRepository.clearOrderFromQueue(actualOrderNo);
            updatedHighlighted = Set<String>.of(state.highlightedOrders)..remove(_qrOrderNo(actualOrderNo));
            updatedGhosts.remove(ghostKey);
            _matchedAt.remove(actualOrderNo);
            _gridCellGroups.remove(actualOrderNo);
            _gridRowWidths.remove(actualOrderNo);
            _gridMatchedAt.remove(actualOrderNo);
            _gridEmptiedAt.remove(actualOrderNo);
            _gridGhostMessage.remove(actualOrderNo);

            if (AppConstants.isCommercialMode) {
              _guidePositions.remove(actualOrderNo);
              _slotAssignments.remove(actualOrderNo);
            }
          } else if (isPickupComplete) {
            // Grid mode: this ghost circle entry is unused visually while
            // themed, but still worth tidying up — the real order/cell
            // cleanup happens in _completeGridOrder on its own schedule.
            updatedGhosts.remove(ghostKey);
          }
          _updateGuidePositions();
          _updateGridCellGroups();
          emit(state.copyWith(
            pickupGhostCircles: updatedGhosts,
            highlightedOrders: updatedHighlighted,
            guidePositions: Map.of(_guidePositions),
            frameRevision: state.frameRevision + 1,
          ));
        });
      }
    }

    // 3. 신규 컵 추가 — 위치 매칭에 실패하고 남은 나머지는 진짜 새로 놓인 컵.
    for (var nuevo in rawEntries) {
      var tof = nuevo['raw'] as TofObject;
      var visualPos = nuevo['pos'] as Offset;
      final newStableKey = _nextStableKey++;
      DiagLogger.log("CUP_ADD", "stableKey=$newStableKey objectId=${tof.id} "
          "pos=(${visualPos.dx.toStringAsFixed(0)},${visualPos.dy.toStringAsFixed(0)}) "
          "cell=${PickupTableGridLayout.nearestCellIndex(visualPos)} "
          "isAmp=${tof.isAmplitude} diameter=${tof.diameter.toStringAsFixed(0)} "
          "width=${tof.width.toStringAsFixed(0)} height=${tof.height.toStringAsFixed(0)}");
      _lastLoggedSizeByStableKey[newStableKey] = tof;
      if (tof.isAmplitude) _lastLoggedIcePosByStableKey[newStableKey] = visualPos;
      final Color idBasedColor = getColorForId(tof.id);
      final orderInfo = _orderRepository.getOrAssignOrder(newStableKey, visualPos, idBasedColor, tof.diameter);
      final String displayLabel = orderInfo != null ? _buildComplexLabel(orderInfo) : "UNKNOWN";
      final String rawOrderNo = orderInfo?['orderNo']?.toString() ?? '';

      // 5초 고스트 유예 안에 같은 주문의 컵이 다시 올라옴 — 감사 메시지
      // 상태로 남아있던 baseCircle을 즉시 지우고 확정 타이머도 취소.
      if (rawOrderNo.isNotEmpty) {
        final staleGhostKeys = _pickupTimers.keys.where((k) => k.startsWith('${rawOrderNo}_')).toList();
        for (final key in staleGhostKeys) {
          _pickupTimers[key]?.cancel();
          _pickupTimers.remove(key);
        }
        ghostCircles.removeWhere((_, ghost) => ghost['orderNo'] == rawOrderNo);
      }

      tempList.add(DetectedObject(
        id: tof.id,
        orderNo: displayLabel,
        position: visualPos,
        zValue: tof.z,
        diameter: _coordinateRepository.getUiDiameter(tof.diameter),
        uiWidth: _coordinateRepository.getUiSize(tof.width, tof.height).width,
        uiHeight: _coordinateRepository.getUiSize(tof.width, tof.height).height,
        color: orderInfo?['color'] ?? idBasedColor,
        stableKey: newStableKey,
        rawOrderNo: rawOrderNo,
        lang: orderInfo?['lang']?.toString() ?? '',
        isAmplitude: tof.isAmplitude,
      ));
    }

    // 4. 모든 컵의 각도 미리 계산.
    final double sw = screenSize.width;
    final double sh = screenSize.height;
    List<DetectedObject> finalOptimizedList = [];

    for (var obj in tempList) {
      double angle = _getStaticSafeAngle(obj.position, obj.diameter, tempList, sw, sh);
      finalOptimizedList.add(DetectedObject(
        id: obj.id,
        orderNo: obj.orderNo,
        position: obj.position,
        zValue: obj.zValue,
        diameter: obj.diameter,
        uiWidth: obj.uiWidth,
        uiHeight: obj.uiHeight,
        labelAngle: angle,
        color: obj.color,
        stableKey: obj.stableKey,
        rawOrderNo: obj.rawOrderNo,
        lang: obj.lang,
        isAmplitude: obj.isAmplitude,
      ));
    }

    // 진단 하트비트 - 5초에 한 번, 현재 화면에 표시 중인 컵 개수를 남긴다.
    // tof_camera 쪽 diag_log.txt의 HEARTBEAT(unified_total)와 같은 타임스탬프대에서
    // 비교하면, "표시가 사라짐"이 tof 카메라 인식 소실 때문인지(양쪽 다 개수가
    // 줄어듦) MQTT 전달/픽업테이블 렌더링 쪽 문제인지(카메라는 정상인데 여기만
    // 줄어듦) 구분할 수 있다.
    final _now = DateTime.now();
    if (_lastHeartbeatLog == null || _now.difference(_lastHeartbeatLog!).inSeconds >= 5) {
      _lastHeartbeatLog = _now;
      final ampCount = finalOptimizedList.where((o) => o.isAmplitude).length;
      DiagLogger.log("HEARTBEAT", "displayed=${finalOptimizedList.length} "
          "amp=$ampCount depth=${finalOptimizedList.length - ampCount} "
          "ghosts=${ghostCircles.length}");
    }

    if (isClosed) return;
    _updateGuidePositions();
    _updateGridCellGroups();
    emit(state.copyWith(
      objects: finalOptimizedList,
      pickupGhostCircles: ghostCircles,
      guidePositions: Map.of(_guidePositions),
      frameRevision: state.frameRevision + 1,
    ));
  }

  double _getStaticSafeAngle(Offset pos, double diameter, List<DetectedObject> others, double sw, double sh) {
    double currentScanAngle = math.pi / 3.0; // 4시 방향 시작
    final double textRadius = (diameter > 0 ? diameter / 2 : 150.0) / 2 + 18.0;

    for (int i = 0; i < 15; i++) {
      double checkX = pos.dx + textRadius * math.cos(currentScanAngle);
      double checkY = pos.dy + textRadius * math.sin(currentScanAngle);

      bool isSafe = (checkX > 40 && checkX < sw - 40 && checkY > 40 && checkY < sh - 40);

      if (isSafe) {
        for (var other in others) {
          if (other.position != pos && (Offset(checkX, checkY) - other.position).distance < (other.diameter / 4 + 40)) {
            isSafe = false;
            break;
          }
        }
      }

      if (isSafe) return currentScanAngle;
      currentScanAngle += (math.pi / 24.0);
    }
    return math.pi / 3.0;
  }

  /// 슬롯 인덱스 앞에 놓인 슬롯들의 실제 너비를 누적해 중앙 좌표를 계산한다.
  Offset _getPositionForOrder(String orderNo, int slotIndex) {
    final Map<int, String> indexToOrder = {
      for (final e in _slotAssignments.entries) e.value: e.key,
    };

    const double maxWidth = 1920.0;
    const double rowHeight = 200.0; // SquareGuideWidget.slotHeight
    double currentX = 0;
    int currentRow = 0;

    for (int i = 0; i < slotIndex; i++) {
      final String? existing = indexToOrder[i];
      final double w = existing != null ? _slotWidthForDrinks(_getDrinkCount(existing)) : 200.0;

      if (currentX > 0 && currentX + w > maxWidth) {
        currentRow++;
        currentX = 0;
      }
      currentX += w;
    }

    final double newW = _slotWidthForDrinks(_getDrinkCount(orderNo));
    if (currentX > 0 && currentX + newW > maxWidth) {
      currentRow++;
      currentX = 0;
    }

    return Offset(
      currentX + newW / 2,
      1080.0 - (currentRow * rowHeight + rowHeight / 2),
    );
  }

  /// 상업용 모드: 주어진 슬롯의 인접 정보를 반환한다.
  Map<String, bool> getNeighborInfo(String orderNo) {
    final int? idx = _slotAssignments[orderNo];
    if (idx == null) {
      return {'hasRight': false, 'hasBottom': false, 'topActive': false, 'leftActive': false};
    }
    final int col = idx % _gridCols;
    final int row = idx ~/ _gridCols;

    String? orderAt(int slotIdx) {
      for (final e in _slotAssignments.entries) {
        if (e.value == slotIdx) return e.key;
      }
      return null;
    }

    bool isActive(String? no) {
      if (no == null) return false;
      return _orderRepository.activeMatches.values.any((m) => m['orderNo'] == no) ||
          _orderRepository.ghostMemory.any((g) => g.orderNo == no);
    }

    final rightNo = col + 1 < _gridCols ? orderAt(row * _gridCols + col + 1) : null;
    final bottomNo = row > 0 ? orderAt((row - 1) * _gridCols + col) : null;
    final topNo = orderAt((row + 1) * _gridCols + col);
    final leftNo = col > 0 ? orderAt(row * _gridCols + col - 1) : null;

    return {
      'hasRight': rightNo != null,
      'hasBottom': bottomNo != null,
      'topActive': isActive(topNo),
      'leftActive': isActive(leftNo),
    };
  }

  /// 슬롯 너비: 100(라벨 박스) + drinkCount×200(컵 공간)
  static double _slotWidthForDrinks(int drinkCount) => 100.0 + drinkCount.clamp(1, 10) * 200.0;

  /// 모든 상태(대기열·activeMatches·ghostMemory)에서 drinkCount 조회
  int getDrinkCount(String orderNo) => _getDrinkCount(orderNo);

  int _getDrinkCount(String orderNo) {
    for (final o in _orderRepository.waitingQueue) {
      if (o['orderNo'] == orderNo) return (o['drinkCount'] as int?) ?? 1;
    }
    for (final m in _orderRepository.activeMatches.values) {
      if (m['orderNo'] == orderNo) return (m['drinkCount'] as int?) ?? 1;
    }
    for (final g in _orderRepository.ghostMemory) {
      if (g.orderNo == orderNo) return g.drinkCount;
    }
    return 1;
  }

  static const Offset _tableCenter = Offset(960, 540);

  Offset _findSafePosition(List<DetectedObject> currentCups) {
    const double minDistance = 250.0;
    const int candidateCount = 200;

    Offset? best;
    double bestDistanceToCenter = double.infinity;

    for (int i = 0; i < candidateCount; i++) {
      double x = _random.nextDouble() * (1920 - 400) + 200;
      double y = _random.nextDouble() * (1080 - 400) + 200;
      Offset candidate = Offset(x, y);

      bool isFarFromCups = currentCups.every((cup) => (cup.position - candidate).distance > minDistance);
      bool isFarFromGuides = _guidePositions.values.every((pos) => (pos - candidate).distance > minDistance);

      if (!isFarFromCups || !isFarFromGuides) continue;

      final distanceToCenter = (candidate - _tableCenter).distance;
      if (distanceToCenter < bestDistanceToCenter) {
        bestDistanceToCenter = distanceToCenter;
        best = candidate;
      }
    }

    return best ?? _tableCenter;
  }

  static const double _labelChipEstimatedWidth = 200.0;
  static const double _labelChipEstimatedHeight = 44.0;
  static const double _labelChipGap = 8.0;

  /// `objects`(라이브 컵) + `pickupGhostCircles`(방금 픽업되어 5초 유예 중인
  /// 컵)를 실제 주문번호로 묶어서, 그 주문에 속한 모든 컵(라이브+고스트)의
  /// 원(중심±반지름)을 합친 바운딩 박스를 하나 계산한다.
  List<OrderGroup> buildOrderGroups() {
    final Map<String, List<Offset>> centers = {};
    final Map<String, List<double>> radii = {};
    final Map<String, String> labels = {};
    final Map<String, String> langs = {};
    final Map<String, bool> hasLive = {};
    final Map<String, String> ghostMessages = {};

    void addPoint(String orderNo, Offset center, double rawDiameter) {
      final double circleDiameter = rawDiameter > 0 ? rawDiameter / 2 : 100.0;
      centers.putIfAbsent(orderNo, () => []).add(center);
      radii.putIfAbsent(orderNo, () => []).add(circleDiameter / 2);
    }

    for (final obj in state.objects) {
      final String groupKey = obj.rawOrderNo.isNotEmpty ? obj.rawOrderNo : 'unknown_${obj.stableKey}';
      addPoint(groupKey, obj.position, obj.diameter);
      labels[groupKey] = obj.orderNo;
      langs[groupKey] = obj.lang;
      hasLive[groupKey] = true;
    }

    for (final ghost in state.pickupGhostCircles.values) {
      final String orderNo = ghost['orderNo'] as String;
      addPoint(orderNo, ghost['position'] as Offset, ghost['diameter'] as double);
      labels.putIfAbsent(orderNo, () => ghost['label'] as String);
      langs.putIfAbsent(orderNo, () => (ghost['lang'] as String?) ?? '');
      hasLive.putIfAbsent(orderNo, () => false);
      ghostMessages[orderNo] = ghost['message'] as String;
    }

    final List<OrderGroup> groups = [];
    for (final orderNo in centers.keys) {
      final pts = centers[orderNo]!;
      final rs = radii[orderNo]!;
      double left = double.infinity, top = double.infinity;
      double right = double.negativeInfinity, bottom = double.negativeInfinity;
      for (var i = 0; i < pts.length; i++) {
        left = math.min(left, pts[i].dx - rs[i]);
        top = math.min(top, pts[i].dy - rs[i]);
        right = math.max(right, pts[i].dx + rs[i]);
        bottom = math.max(bottom, pts[i].dy + rs[i]);
      }
      final bool orderHasLive = hasLive[orderNo] ?? false;
      final bool isRealOrder = !orderNo.startsWith('unknown_');

      // 매칭(대시 가이드 -> 실선 매칭사각형 전환) 시각 기록 — 처음 라이브
      // 컵이 잡힌 시점부터 카운트. _matchedAt.remove는 픽업 완료(고스트
      // 타이머 만료) 시점에만 일어나므로, 여기서는 "처음 본 순간"만 기록.
      if (isRealOrder && orderHasLive) {
        _matchedAt.putIfAbsent(orderNo, () => DateTime.now());
      }
      final DateTime? matchedAt = _matchedAt[orderNo];
      final bool isTimedOut = isRealOrder &&
          orderHasLive &&
          matchedAt != null &&
          DateTime.now().difference(matchedAt) >= _matchTimeout;

      groups.add(OrderGroup(
        orderNo: orderNo,
        bounds: Rect.fromLTRB(left, top, right, bottom),
        isHighlighted: isRealOrder && state.highlightedOrders.contains(_qrOrderNo(orderNo)),
        isTimedOut: isTimedOut,
        hasLiveCups: orderHasLive,
        label: labels[orderNo] ?? orderNo,
        lang: langs[orderNo] ?? '',
        ghostMessage: orderHasLive ? null : ghostMessages[orderNo],
      ));
    }
    return groups;
  }

  /// 라벨칩 위치: 기본은 브라켓 바로 아래, 우측 끝이 브라켓의 우측하단
  /// 지점에 정확히 맞춰지도록 우측 정렬. 그 자리가 화면 밖으로 나가거나
  /// 다른 주문의 브라켓과 겹치면, 브라켓 바로 위로 옮기되 좌측 정렬한다.
  ({bool alignRight, double x, double top}) labelPositionFor(
    OrderGroup group,
    List<OrderGroup> allGroups,
    Size screenSize,
  ) {
    final double belowTop = group.bounds.bottom + _labelChipGap;
    final Rect belowRightAlignedRect = Rect.fromLTWH(
      group.bounds.right - _labelChipEstimatedWidth,
      belowTop,
      _labelChipEstimatedWidth,
      _labelChipEstimatedHeight,
    );

    final bool offScreen =
        belowRightAlignedRect.left < 0 || belowRightAlignedRect.bottom > screenSize.height;
    final bool overlapsOther =
        allGroups.any((other) => other.orderNo != group.orderNo && other.bounds.overlaps(belowRightAlignedRect));

    if (!offScreen && !overlapsOther) {
      return (alignRight: true, x: group.bounds.right, top: belowTop);
    }

    return (
      alignRight: false,
      x: group.bounds.left,
      top: group.bounds.top - _labelChipGap - _labelChipEstimatedHeight,
    );
  }

  // 주문 대기열 상태와 가이드 좌표 싱크
  void _updateGuidePositions() {
    final pendingOrders = _orderRepository.waitingQueue;

    if (AppConstants.isCommercialMode) {
      final waitingIds = pendingOrders.map((o) => o['orderNo']! as String).toSet();
      final activeIds = _orderRepository.activeMatches.values.map((m) => m['orderNo']! as String).toSet();
      final ghostIds = _orderRepository.ghostMemory.map((g) => g.orderNo).toSet();
      final allPresentIds = waitingIds.union(activeIds).union(ghostIds);

      _guidePositions.removeWhere((orderNo, _) => !allPresentIds.contains(orderNo));
      _slotAssignments.removeWhere((orderNo, _) => !allPresentIds.contains(orderNo));

      for (var order in pendingOrders) {
        String no = order['orderNo']!;
        if (!_guidePositions.containsKey(no)) {
          final usedSlots = _slotAssignments.values.toSet();
          int nextSlot = 0;
          while (usedSlots.contains(nextSlot)) nextSlot++;
          _slotAssignments[no] = nextSlot;
          _guidePositions[no] = _getPositionForOrder(no, nextSlot);
        }
      }

      for (final orderNo in activeIds.union(ghostIds)) {
        if (!_guidePositions.containsKey(orderNo) && _slotAssignments.containsKey(orderNo)) {
          _guidePositions[orderNo] = _getPositionForOrder(orderNo, _slotAssignments[orderNo]!);
        }
      }

      _orderRepository.updateSlotPositions(_guidePositions);

      final Map<String, double> halfWidths = {};
      for (final orderNo in _guidePositions.keys) {
        final drinkCount = _getDrinkCount(orderNo);
        halfWidths[orderNo] = _slotWidthForDrinks(drinkCount) / 2;
      }
      _orderRepository.updateSlotHalfWidths(halfWidths);
    } else {
      final activeOrderIds = _orderRepository.activeMatches.values.map((m) => m['orderNo']!.toString()).toSet();
      final ghostOrderIds = state.pickupGhostCircles.values.map((g) => g['orderNo'] as String).toSet();
      final currentOrderIds = pendingOrders
          .map((o) => o['orderNo']! as String)
          .where((no) => !activeOrderIds.contains(no) && !ghostOrderIds.contains(no))
          .toSet();
      _guidePositions.removeWhere((orderNo, _) => !currentOrderIds.contains(orderNo));
      for (var order in pendingOrders) {
        String no = order['orderNo']!;
        if (!_guidePositions.containsKey(no) && currentOrderIds.contains(no)) {
          _guidePositions[no] = _findSafePosition(state.objects);
        }
      }
    }
  }

  /// Keeps [_gridCellGroups] in sync with [OrderRepository.waitingQueue] —
  /// but ONLY ever ADDS entries here, never removes them. An earlier
  /// version also removed any order no longer referenced by
  /// activeMatches/pickupGhostCircles (OrderManager's legacy per-cup
  /// bookkeeping), which is exactly what caused a completely unrelated,
  /// still-dashed guide square to vanish the moment ANY cup got FIFO-
  /// matched-then-released: getOrAssignOrder's blind FIFO matching (see
  /// _completeGridOrder's own doc comment) routinely attaches a physical
  /// cup to a DIFFERENT order than the one whose cell it's actually
  /// sitting on, so that legacy bookkeeping considering an order "gone"
  /// has nothing to do with whether ITS OWN grid cells are actually
  /// empty. Removal here is now handled exclusively by
  /// [_completeGridOrder] (fires once THIS order's own cells are
  /// confirmed occupied-then-empty by the grid's own position-based
  /// detection) and by explicit callers like [_clearTestOrders] — nothing
  /// else may delete an entry out from under a still-active grid order.
  /// No-op unless grid mode is on (see OrderRepository.gridModeEnabled).
  void _updateGridCellGroups() {
    if (!_orderRepository.gridModeEnabled) return;

    for (final order in _orderRepository.waitingQueue) {
      final String no = order['orderNo']!;
      if (_gridCellGroups.containsKey(no)) continue;
      final int count = ((order['totalRequired'] as int?) ?? 1).clamp(1, PickupTableGridLayout.totalCells);
      final allocation = _allocateGridCells(count);
      if (allocation != null) {
        _gridCellGroups[no] = allocation.cells;
        _gridRowWidths[no] = allocation.rowWidths;
        debugPrint('🟦 [Grid] $no번 주문 칸 배정 -> cells=${allocation.cells} rowWidths=${allocation.rowWidths}');
      } else {
        debugPrint('⚠️ [Grid] $no번 주문: 빈 칸 부족으로 그리드 배정 실패 (요청 $count칸)');
      }
    }
  }

  /// Finds [count] free grid cells arranged as a balanced, near-square
  /// block — width = ceil(sqrt(count)), filled row-major/left-aligned, so
  /// e.g. 3 -> 2 wide × 2 tall (row0: 2 cells, row1: 1 cell), 5 -> 3 wide ×
  /// 2 tall (row0: 3, row1: 2), 7 -> 3 wide × 3 tall (row0: 3, row1: 3,
  /// row2: 1) — NOT a single 1×N row anymore (that read as "too long and
  /// thin" for anything past 2-3 cups), and NOT the top-heavy order this
  /// class's very first version guessed either — test_base_light.png's own
  /// 5-cell card measures out to exactly rows [2,3] top-to-bottom (pixel-
  /// verified: the step sits precisely at PickupTableGridLayout's row 0/1
  /// boundary and column 7/8 boundary), i.e. the NARROWEST row is on top
  /// and rows widen going down — so that's the order used here too, for
  /// every count. Returns [cells] (row-major in that same top-to-bottom
  /// order — what [buildGridOrderGroups] matches real cups against) and
  /// [rowWidths] (cell-count per row, same order — [buildGridOrderGroups]
  /// hands this to the themed widgets so they can draw the exact stepped
  /// outline instead of a bounding-box rectangle; see
  /// crop_matched_tag_2x.png/test_base_light.png — there is no unused
  /// "phantom" cell to separately reserve any more, since the render no
  /// longer covers a cell it doesn't actually occupy). Every valid
  /// placement of the shape anywhere in the grid is collected and one is
  /// picked at random (not always the first/top-left one), so repeatedly
  /// creating test orders scatters them across the whole screen instead of
  /// clustering in one corner. Falls back to a BFS grab of connected free
  /// cells (any shape, just contiguous — rendered as a single bounding
  /// rect in that fallback case only, since there's no clean row
  /// structure to derive a staircase from) if the staircase shape doesn't
  /// fit anywhere — what to do when NEITHER fits (evict the oldest order,
  /// shuffle a 1-cell order aside, etc.) is intentionally still
  /// undecided/deferred. Returns null if even the BFS fallback can't find
  /// [count] connected free cells anywhere.
  ({List<int> cells, List<int> rowWidths})? _allocateGridCells(int count) {
    const int total = PickupTableGridLayout.totalCells;
    const int columns = PickupTableGridLayout.columns;
    const int rows = PickupTableGridLayout.rows;
    final Set<int> occupied = _gridCellGroups.values.expand((c) => c).toSet();
    bool isFree(int i) => i >= 0 && i < total && !occupied.contains(i);

    final int shapeWidth = sqrt(count).ceil();
    final int fullRows = count ~/ shapeWidth;
    final int remainder = count % shapeWidth;
    // Narrowest (remainder) row first/top, full-width rows below it — see
    // this method's own doc comment for why (matches the measured
    // reference card, not the original guess).
    final List<int> rowWidthsShape = [
      if (remainder > 0) remainder,
      for (int i = 0; i < fullRows; i++) shapeWidth,
    ];

    List<int>? cellsAt(int topRow, int leftCol) {
      final cells = <int>[];
      for (int r = 0; r < rowWidthsShape.length; r++) {
        for (int c = 0; c < rowWidthsShape[r]; c++) {
          final int idx = (topRow + r) * columns + (leftCol + c);
          if (!isFree(idx)) return null;
          cells.add(idx);
        }
      }
      return cells;
    }

    final List<List<int>> placements = [];
    for (int topRow = 0; topRow <= rows - rowWidthsShape.length; topRow++) {
      for (int leftCol = 0; leftCol <= columns - shapeWidth; leftCol++) {
        final cells = cellsAt(topRow, leftCol);
        if (cells != null) placements.add(cells);
      }
    }
    if (placements.isNotEmpty) {
      // Multi-cup orders bias toward the table's center — cups near the
      // grid edge are seen by the ToF camera at more of an oblique angle,
      // which is exactly where two adjacent cups' silhouettes are most
      // likely to visually overlap into what looks like one blob. A
      // single-cup order has no overlap risk at all, so it keeps the
      // original fully-random placement (every valid spot, uniformly) —
      // this only changes multi-cup orders.
      if (count > 1) {
        final double centerRow = (rows - 1) / 2.0;
        final double centerCol = (columns - 1) / 2.0;
        double distanceToCenterSquared(List<int> cells) {
          double rowSum = 0;
          double colSum = 0;
          for (final int idx in cells) {
            rowSum += idx ~/ columns;
            colSum += idx % columns;
          }
          final double avgRow = rowSum / cells.length;
          final double avgCol = colSum / cells.length;
          final double dRow = avgRow - centerRow;
          final double dCol = avgCol - centerCol;
          return dRow * dRow + dCol * dCol;
        }

        placements.sort(
          (a, b) => distanceToCenterSquared(a).compareTo(distanceToCenterSquared(b)),
        );
        // Still pick randomly among the closest quarter (min 1) rather than
        // always the single most-central spot, so simultaneous multi-cup
        // orders don't all land on exactly the same cells.
        final int centralCandidateCount = max(1, (placements.length / 4).ceil());
        final List<List<int>> centralPlacements = placements.sublist(
          0,
          min(centralCandidateCount, placements.length),
        );
        return (
          cells: centralPlacements[_random.nextInt(centralPlacements.length)],
          rowWidths: rowWidthsShape,
        );
      }
      return (cells: placements[_random.nextInt(placements.length)], rowWidths: rowWidthsShape);
    }

    // The staircase doesn't fit anywhere — fall back to a BFS grab of
    // connected free cells, starting from a random free seed cell (and
    // exploring its neighbors in random order too), same "scatter, don't
    // cluster" reasoning as above.
    final freeCells = [for (int i = 0; i < total; i++) if (isFree(i)) i]..shuffle(_random);
    for (final seed in freeCells) {
      final result = <int>[seed];
      final frontier = <int>[seed];
      final visited = <int>{seed};
      while (result.length < count && frontier.isNotEmpty) {
        final cur = frontier.removeLast();
        final int row = cur ~/ columns;
        final int col = cur % columns;
        final neighbors = [
          if (col > 0) cur - 1,
          if (col < columns - 1) cur + 1,
          if (row > 0) cur - columns,
          if (row < rows - 1) cur + columns,
        ]..shuffle(_random);
        for (final n in neighbors) {
          if (visited.contains(n) || !isFree(n)) continue;
          visited.add(n);
          result.add(n);
          frontier.add(n);
          if (result.length == count) break;
        }
      }
      if (result.length == count) return (cells: result, rowWidths: [count]);
    }
    return null;
  }

  /// Refreshes [_occupiedGridCells] from the latest live cup positions —
  /// called every ToF frame (see _handleTofFrame). A geometric overlay on
  /// [state.objects]' already-computed positions, matched to the NEAREST
  /// cell (see [PickupTableGridLayout.nearestCellIndex] — strict rect
  /// containment routinely missed real cups sitting slightly inside a
  /// gap/margin, which is why guide squares were never flipping to
  /// matched at all). This still does NOT touch OrderManager's own
  /// label/identity assignment (getOrAssignOrder stays blind FIFO,
  /// unaware of which cell a cup landed in) — but it now DOES own firing
  /// the real pickup-complete signal itself (see [_completeGridOrder]),
  /// instead of leaving that to the legacy per-cup ghost timer, because
  /// that timer's FIFO-guessed order identity can name a completely
  /// different order than the one whose cell actually emptied (see the
  /// grid-mode guard added around its own isPickupComplete branch).
  /// Returns whether anything visible actually changed (a matched/emptied/
  /// completed transition), so callers that run this on a timer — see
  /// [_gridOccupancyTimer] — can skip emitting a rebuild on the (vast
  /// majority of) polls where nothing did.
  bool _updateGridOccupancy() {
    if (!_gridOccupancyDetectionEnabled ||
        !_orderRepository.gridModeEnabled ||
        _gridCellGroups.isEmpty) {
      final bool hadCells = _occupiedGridCells.isNotEmpty;
      if (hadCells) _occupiedGridCells = {};
      return hadCells;
    }
    bool changed = false;
    final DateTime now = DateTime.now();
    final Set<int> occupied = {
      for (final obj in state.objects) PickupTableGridLayout.nearestCellIndex(obj.position),
    };
    _occupiedGridCells = occupied;

    final bool occupiedChanged = occupied.length != _lastLoggedOccupiedGridCells.length ||
        !occupied.every(_lastLoggedOccupiedGridCells.contains);
    if (occupiedChanged) {
      _lastLoggedOccupiedGridCells = Set<int>.of(occupied);
      final msg = 'occupied=$occupied '
          'groups=${_gridCellGroups.map((no, cells) => MapEntry(no, cells))}';
      debugPrint('🔲 [Grid] occupied cells changed -> $msg');
      DiagLogger.log("GRID_OCCUPIED", msg);
    }

    final List<String> readyToComplete = [];
    for (final entry in _gridCellGroups.entries) {
      final String orderNo = entry.key;
      if (_gridPinnedOrderNos.contains(orderNo)) continue;
      final List<int> cells = entry.value;
      final bool allOccupied = cells.every(occupied.contains);
      final bool allEmpty = cells.every((c) => !occupied.contains(c));
      final bool wasMatched = _gridMatchedAt.containsKey(orderNo);

      // Debounce (see _gridDebounceDuration's doc comment): a state
      // transition only commits once cells have been continuously
      // occupied/empty for at least _gridDebounceDuration of real time. A
      // partial read (some but not all cells occupied — a genuinely
      // ambiguous/transitional frame) clears both timestamps rather than
      // counting toward either.
      if (allOccupied) {
        _gridOccupiedSince.putIfAbsent(orderNo, () => now);
        _gridEmptySince.remove(orderNo);
      } else if (allEmpty) {
        _gridEmptySince.putIfAbsent(orderNo, () => now);
        _gridOccupiedSince.remove(orderNo);
      } else {
        _gridOccupiedSince.remove(orderNo);
        _gridEmptySince.remove(orderNo);
      }

      final DateTime? occupiedSince = _gridOccupiedSince[orderNo];
      final DateTime? emptySince = _gridEmptySince[orderNo];
      if (!wasMatched && occupiedSince != null && now.difference(occupiedSince) >= _gridDebounceDuration) {
        _gridMatchedAt[orderNo] = now;
        _gridEmptiedAt.remove(orderNo);
        // A cup came back within the ghost window — clear the cached
        // message so the NEXT real pickup rolls a fresh one instead of
        // reusing this one.
        _gridGhostMessage.remove(orderNo);
        debugPrint('🟩 [Grid] $orderNo cells=$cells -> MATCHED');
        DiagLogger.log("GRID_MATCHED", "$orderNo cells=$cells occupied=$occupied");
        changed = true;
      } else if (wasMatched && emptySince != null && now.difference(emptySince) >= _gridDebounceDuration) {
        // All cells confirmed empty (not just a single dropped frame)
        // after having been fully matched — start the visual thank-you
        // window (see buildGridOrderGroups). The message itself is picked
        // ONCE here (see _gridGhostMessage's own doc comment for why) —
        // buildGridOrderGroups only ever reads it back, never re-rolls it.
        _gridMatchedAt.remove(orderNo);
        _gridEmptiedAt.putIfAbsent(orderNo, () => now);
        _gridGhostMessage.putIfAbsent(orderNo, () {
          final orderData = orderDataFor(orderNo);
          final String lang = (orderData['lang'] as String?)?.isNotEmpty == true
              ? orderData['lang'] as String
              : AppConstants.fallbackLanguage;
          return _languageRepository.pickupMessageFor(lang);
        });
        debugPrint('🟨 [Grid] $orderNo cells=$cells -> EMPTIED (ghost window started)');
        DiagLogger.log("GRID_EMPTIED", "$orderNo cells=$cells occupied=$occupied");
        changed = true;
      }

      final DateTime? emptiedAt = _gridEmptiedAt[orderNo];
      if (emptiedAt != null && now.difference(emptiedAt) >= _orderRepository.ghostDuration) {
        readyToComplete.add(orderNo);
      }
    }

    // Applied after the loop above (not during) to avoid mutating
    // _gridCellGroups/_gridEmptiedAt while iterating them.
    for (final orderNo in readyToComplete) {
      _completeGridOrder(orderNo);
      changed = true;
    }

    return changed;
  }

  /// Fires the real KDS pickup-complete signal for a grid order group once
  /// its own cells have been confirmed empty for a full ghost window —
  /// this order's own identity, not whatever OrderManager's blind-FIFO
  /// getOrAssignOrder happened to guess for the physical cup that was
  /// there. buildGridOrderGroups independently stops RENDERING this group
  /// at the same ghostDuration threshold — removing it from every grid
  /// map here just keeps that in sync (and stops this from firing twice).
  void _completeGridOrder(String orderNo) {
    _pickupRepository.sendPickupComplete(orderNo);
    debugPrint('📢 [Grid Auto-Pickup] $orderNo번 모든 칸 비워짐 확인 -> KDS 신호 전송');
    _orderRepository.clearOrderFromQueue(orderNo);
    final staleKeys = _orderRepository.activeMatches.entries
        .where((e) => e.value['orderNo'] == orderNo)
        .map((e) => e.key)
        .toList();
    for (final key in staleKeys) {
      _orderRepository.releaseId(key);
    }
    _gridCellGroups.remove(orderNo);
    _gridRowWidths.remove(orderNo);
    _gridMatchedAt.remove(orderNo);
    _gridEmptiedAt.remove(orderNo);
    _gridGhostMessage.remove(orderNo);
    _gridOccupiedSince.remove(orderNo);
    _gridEmptySince.remove(orderNo);
    if (state.highlightedOrders.contains(_qrOrderNo(orderNo))) {
      final updated = Set<String>.of(state.highlightedOrders)..remove(_qrOrderNo(orderNo));
      emit(state.copyWith(highlightedOrders: updated));
    }
  }

  /// Themed-grid equivalent of [buildOrderGroups] — one [GridOrderGroup]
  /// per order currently holding a grid cell assignment, driven entirely
  /// by [_gridCellGroups]/[_occupiedGridCells] (fixed positions + a
  /// presence check), not by OrderManager's FIFO/continuous-position
  /// matching. Only meaningful when grid mode is on; returns empty
  /// otherwise. NOTE: the real pickup-complete MQTT signal to KDS still
  /// fires from the legacy per-cup ghost-timer pipeline exactly as before
  /// (unchanged) — this method's ghost/thank-you window is a purely
  /// visual echo of "this group's cells all went empty", not wired to
  /// that signal. If they ever drift out of sync in testing, that's the
  /// first place to look.
  List<GridOrderGroup> buildGridOrderGroups() {
    if (!_orderRepository.gridModeEnabled) return const [];

    final List<GridOrderGroup> groups = [];
    final now = DateTime.now();

    for (final entry in _gridCellGroups.entries) {
      final String orderNo = entry.key;
      final List<Rect> cellRects =
          entry.value.map(PickupTableGridLayout.cellRectByIndex).toList();
      // Union of every assigned cell — see GridOrderGroup.bounds' doc
      // comment. The widgets draw the exact staircase outline described
      // by rowWidths within this, not a filled bounding-box rectangle.
      Rect bounds = cellRects.first;
      for (final r in cellRects.skip(1)) {
        bounds = bounds.expandToInclude(r);
      }
      final List<int> rowWidths = _gridRowWidths[orderNo] ?? [entry.value.length];

      final DateTime? emptiedAt = _gridEmptiedAt[orderNo];
      if (emptiedAt != null) {
        if (now.difference(emptiedAt) >= _orderRepository.ghostDuration) {
          continue; // ghost window elapsed — this group just disappears
        }
        final orderData = orderDataFor(orderNo);
        final String lang = (orderData['lang'] as String?)?.isNotEmpty == true
            ? orderData['lang'] as String
            : AppConstants.fallbackLanguage;
        groups.add(GridOrderGroup(
          orderNo: orderNo,
          bounds: bounds,
          rowWidths: rowWidths,
          state: GridSlotState.thankYou,
          // Read the message cached once at the EMPTIED transition (see
          // _gridGhostMessage's doc comment) — never re-rolled here, since
          // this method runs on every rebuild while the ghost window is
          // up. The fallback only covers a same-frame race (message not
          // cached yet the instant emptiedAt is set).
          ghostMessage: _gridGhostMessage[orderNo] ?? _languageRepository.pickupMessageFor(lang),
          lang: lang,
        ));
        continue;
      }

      final bool isMatched = _gridMatchedAt.containsKey(orderNo);
      final bool isHighlighted = state.highlightedOrders.contains(_qrOrderNo(orderNo));
      final DateTime? matchedAt = _gridMatchedAt[orderNo];
      final bool isTimedOut =
          isMatched && matchedAt != null && now.difference(matchedAt) >= _matchTimeout;

      groups.add(GridOrderGroup(
        orderNo: orderNo,
        bounds: bounds,
        rowWidths: rowWidths,
        state: !isMatched
            ? GridSlotState.guide
            : isHighlighted
                ? GridSlotState.highlighted
                : isTimedOut
                    ? GridSlotState.timedOut
                    : GridSlotState.matched,
        lang: orderDataFor(orderNo)['lang'] as String? ?? '',
      ));
    }
    return groups;
  }

  String buildComplexLabel(Map<String, dynamic> info) => _buildComplexLabel(info);

  String guideLabel(String orderNo) => _getGuideLabel(orderNo);

  /// 가이드 서클의 라벨/잔수 조회용 데이터 — 대기열 → activeMatches → 기본값
  /// 순으로 fallback한다.
  Map<String, dynamic> orderDataFor(String orderNo) {
    return _orderRepository.waitingQueue.firstWhere(
      (o) => o['orderNo'] == orderNo,
      orElse: () => _orderRepository.activeMatches.values.firstWhere(
        (m) => m['orderNo'] == orderNo,
        orElse: () => {'orderNo': orderNo, 'nickname': '', 'totalRequired': 1},
      ),
    );
  }

  @override
  Future<void> close() {
    unawaited(_mqttLogSubscription?.cancel());
    unawaited(_customerScanSubscription?.cancel());
    unawaited(_tofFrameSubscription?.cancel());
    unawaited(_orderReadySubscription?.cancel());
    unawaited(_calibrationRequestedSubscription?.cancel());
    unawaited(_themeChangedSubscription?.cancel());
    unawaited(_createTestOrdersSubscription?.cancel());
    unawaited(_clearTestOrdersSubscription?.cancel());
    _handDetectionTimer?.cancel();
    _irSentTimer?.cancel();
    _adTimer?.cancel();
    _gridOccupancyTimer?.cancel();
    _pickupTimers.forEach((key, timer) => timer.cancel());
    _pickupTimers.clear();
    obstacleNotifier.dispose();
    _pickupRepository.dispose();
    _languageRepository.dispose();
    return super.close();
  }
}

/// One order's worth of on-table presence — computed each frame by
/// [PickupTableCubit.buildOrderGroups] from `objects` (live cups) +
/// `pickupGhostCircles` (just-picked-up cups still in their 5s ghost
/// window), grouped by real order number. [bounds] is the union of every
/// belonging cup's own circle (center ± radius), regardless of how many
/// cups the order has or how they're arranged on the table.
class OrderGroup {
  final String orderNo;
  final Rect bounds;
  final bool isHighlighted;
  // True once 10 minutes have passed since this order's first live cup —
  // see PickupTableCubit._matchedAt/buildOrderGroups. Only ever true
  // together with hasLiveCups (a fully-picked-up/ghost order can't be
  // "timed out").
  final bool isTimedOut;
  final bool hasLiveCups;
  final String label;
  final String lang;
  final String? ghostMessage;

  const OrderGroup({
    required this.orderNo,
    required this.bounds,
    required this.isHighlighted,
    this.isTimedOut = false,
    required this.hasLiveCups,
    required this.label,
    required this.lang,
    this.ghostMessage,
  });
}

/// Which themed square widget [GridOrderGroup] should render as — see
/// ThemedGuideSlot/ThemedPlacedSlot/ThemedThankYouSlot.
enum GridSlotState { guide, matched, timedOut, highlighted, thankYou }

/// [OrderGroup]'s grid-mode counterpart — see
/// [PickupTableCubit.buildGridOrderGroups]'s doc comment for how this
/// differs (fixed cell positions + presence check, not continuous
/// position tracking).
class GridOrderGroup {
  final String orderNo;
  // Union of every assigned cell's Rect — the widget's own [bounds]
  // SizedBox/Positioned footprint. Exactly matches the individual cells'
  // combined bounding footprint; for a multi-row group with a width step
  // (the common multi-cup case) the rendered card is NOT a filled
  // rectangle spanning this whole box — see [rowWidths].
  final Rect bounds;
  // Cell-count per row, top to bottom, in the SAME order
  // PickupTableCubit._allocateGridCells laid the cells out in — e.g. [2,3]
  // for a 5-cup order (narrowest row on top, widening going down; see
  // that method's own doc comment for the pixel-measurement this is
  // based on). The themed widgets draw the exact stepped outline this
  // describes (test_base_light.png's own L-shaped multi-cell cards, e.g.
  // crop_matched_tag_2x.png), not a bounding-box rectangle. A single-
  // element list (e.g. [1] or [3]) means one plain row — no step, just an
  // ordinary rounded rect.
  final List<int> rowWidths;
  final GridSlotState state;
  final String lang;
  final String? ghostMessage;

  const GridOrderGroup({
    required this.orderNo,
    required this.bounds,
    required this.rowWidths,
    required this.state,
    required this.lang,
    this.ghostMessage,
  });
}
