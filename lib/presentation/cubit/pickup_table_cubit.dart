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
import 'package:pickup_table/domain/entities/index.dart';
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
  StreamSubscription<double>? _calibrationRequestedSubscription;

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

  // Keyed by ghostKey ('${orderNo}_${stableKey}'), NOT orderNo — a multi-cup
  // order's cups can release moments apart, and keying by orderNo would let
  // the later cup's release cancel the earlier cup's own completion-check
  // timer.
  final Map<String, Timer> _pickupTimers = {};

  final Map<String, Offset> _guidePositions = {};
  final Map<String, int> _slotAssignments = {};
  final Random _random = Random();

  Timer? _adTimer;

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
    unawaited(_pickupRepository.connect());
    unawaited(_languageRepository.load());
  }

  void _handleOrderReady() {
    _updateGuidePositions();
    emit(state.copyWith(guidePositions: Map.of(_guidePositions), frameRevision: state.frameRevision + 1));
  }

  void _handleCalibrationRequested(double incomingHeight) {
    AppConstants.totalSensorHeight = incomingHeight;
    debugPrint("✅ [HEIGHT_CHECK] AppConstants.totalSensorHeight is now: ${AppConstants.totalSensorHeight}");
    _coordinateRepository.resetMatrix();
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

          if (isPickupComplete) {
            _pickupRepository.sendPickupComplete(actualOrderNo);
            debugPrint("📢 [Auto-Pickup] $actualOrderNo번 모든 컵 제거 확인 -> KDS 신호 전송");
          }

          _pickupTimers.remove(ghostKey);
          final updatedGhosts = Map<String, Map<String, dynamic>>.of(state.pickupGhostCircles);
          var updatedHighlighted = state.highlightedOrders;
          if (isPickupComplete) {
            // 픽업 완료 확정: waitingQueue 잔류 항목을 먼저 제거해야
            // _updateGuidePositions()가 그리드를 재생성하지 않는다.
            _orderRepository.clearOrderFromQueue(actualOrderNo);
            updatedHighlighted = Set<String>.of(state.highlightedOrders)..remove(_qrOrderNo(actualOrderNo));
            updatedGhosts.remove(ghostKey);

            if (AppConstants.isCommercialMode) {
              _guidePositions.remove(actualOrderNo);
              _slotAssignments.remove(actualOrderNo);
            }
          }
          _updateGuidePositions();
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

    if (isClosed) return;
    _updateGuidePositions();
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
      groups.add(OrderGroup(
        orderNo: orderNo,
        bounds: Rect.fromLTRB(left, top, right, bottom),
        isHighlighted: isRealOrder && state.highlightedOrders.contains(_qrOrderNo(orderNo)),
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
    _handDetectionTimer?.cancel();
    _irSentTimer?.cancel();
    _adTimer?.cancel();
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
  final bool hasLiveCups;
  final String label;
  final String lang;
  final String? ghostMessage;

  const OrderGroup({
    required this.orderNo,
    required this.bounds,
    required this.isHighlighted,
    required this.hasLiveCups,
    required this.label,
    required this.lang,
    this.ghostMessage,
  });
}
