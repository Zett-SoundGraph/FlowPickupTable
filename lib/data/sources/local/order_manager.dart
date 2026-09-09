import 'dart:ui';
import 'dart:math' as math;
import 'package:pickup_table/core/constants/app_constants.dart';
import 'package:pickup_table/domain/entities/index.dart';

class OrderManager {
  // 1. KDS에서 들어온 제조 완료 주문들 (대기열)
  static final List<Map<String, dynamic>> _waitingQueue = [];

  static List<Map<String, dynamic>> get waitingQueue => List.unmodifiable(_waitingQueue);

  // 2. 현재 테이블 위에 올라가 있는 컵과 매칭된 주문 정보
  // Key: stableKey (화면 쪽이 위치 매칭으로 부여하는, 물리적 컵 하나에 대해
  // 프레임이 바뀌어도 계속 유지되는 값) — 센서 자체의 raw object_id는 컵
  // 블롭 크기가 바뀔 때(예: 2잔 붙어있다가 1개만 남을 때) 언제든 새로 부여될
  // 수 있어서 그걸 키로 쓰면 화면은 "같은 컵"이라 잘 이어붙이는데 여기는
  // 연결이 끊겨 주문 정보를 잃어버리는 문제가 있었음 — stableKey 기준으로
  // 바꿔서 raw id가 몇 번을 바뀌든 항상 같은 항목을 계속 갱신하도록 함.
  // Value: { orderNo, menuName } (비즈니스 데이터)
  static final Map<int, Map<String, dynamic>> _activeMatches = {};

  static final List<GhostOrder> _ghostMemory = [];

  static List<GhostOrder> get ghostMemory {
    _cleanupGhosts();
    // 원본 리스트를 그대로 주지 않고 복사해서 주어 UI 렌더링 중 데이터 오염을 방지함
    return List.unmodifiable(_ghostMemory);
  }

  static const double spatialThreshold = 250.0; // 25cm 이내면 동일 컵으로 간주
  static const Duration ghostDuration = Duration(seconds: 5); // 2초간 기억

  // 상업용 모드: UI에서 계산한 슬롯 중앙 좌표를 저장 (orderNo -> center Offset)
  static final Map<String, Offset> _slotPositions = {};
  // 상업용 모드: 슬롯별 반너비(halfWidth) — 음료 수에 따라 가변 (orderNo -> halfWidth)
  static final Map<String, double> _slotHalfWidths = {};
  static const double _defaultHalfWidth = 100.0; // 기본 200px 슬롯의 절반

  static void updateSlotPositions(Map<String, Offset> positions) {
    _slotPositions
      ..clear()
      ..addAll(positions);
  }

  static void updateSlotHalfWidths(Map<String, double> halfWidths) {
    _slotHalfWidths
      ..clear()
      ..addAll(halfWidths);
  }

  // [KDS 연동] 소켓 서버에서 호출
  static const int maxQueueSize = 50;

  static final Map<String, int> _receivedReadyCounts = {};
  static final Map<String, Map<String, dynamic>> _pendingOrders = {};

  // static void addReadyOrder(String no, String menu, String nickname, int d, int f, int b) {
  //   if (_waitingQueue.length >= maxQueueSize) {
  //     _waitingQueue.removeAt(0); // 너무 오래된 주문은 밀어냄
  //   }
  //   _waitingQueue.add({"orderNo": no, "menuName": menu, "nickname": nickname, "drinkCount": d, "foodCount": f, "bottleCount": b});
  //   print("📦 [Manager] 대기열 추가: $no | 현재 대기: ${_waitingQueue.length}건");
  // }
  static void addReadyOrder(String no, String menu, String nickname, int d, int f, int b, int totalRequired, [String lang = '']) {
    // 총 필요한 수량 계산
    //int totalRequired = d + f + b;
    if (totalRequired <= 0) totalRequired = 1; // 최소 1잔 보장

    // 중복 방지: 이미 대기열이나 테이블에 올라있는 주문은 재적재하지 않음.
    // 같은 완료신호가 여러 번 오면 _waitingQueue에 동일 orderNo가 중복되어
    // 픽업 완료 후 그리드가 재생성되는 버그의 근본 원인이므로 반드시 차단.
    final bool isAlreadyInQueue = _waitingQueue.any((order) => order['orderNo'] == no);
    final bool isAlreadyActive  = _activeMatches.values.any((order) => order['orderNo'] == no);

    if (isAlreadyInQueue || isAlreadyActive) {
      print("🛡️ [Manager] $no번 주문은 이미 대기열/테이블에 존재합니다. 중복 신호 차단.");
      return;
    }

    // 1잔 완료 신호가 올 때마다 카운트 1씩 증가
    _receivedReadyCounts[no] = (_receivedReadyCounts[no] ?? 0) + 1;

    // 보류 큐에 최신 데이터 저장
    _pendingOrders[no] = {
      "orderNo": no,
      "menuName": menu,
      "nickname": nickname,
      "drinkCount": d,
      "foodCount": f,
      "bottleCount": b,
      "totalRequired": totalRequired,
      "placedCount": 0, // 테이블에 올라간 컵 수 추적용
      "lang": lang,
    };

    print("📦 [Manager] 제조 완료 수신: $no (${_receivedReadyCounts[no]}/$totalRequired)");

    // 🌟 전체 수량이 모두 완료 신호로 들어왔을 때만 진짜 대기열에 추가!
    if (_receivedReadyCounts[no]! >= totalRequired) {
      if (_waitingQueue.length >= maxQueueSize) {
        _waitingQueue.removeAt(0);
      }
      _waitingQueue.add(_pendingOrders[no]!);
      _receivedReadyCounts.remove(no);
      _pendingOrders.remove(no);
      print("✅ [Manager] $no번 주문 완성! 가이드 서클 생성");
    }
  }

  static Map<String, dynamic>? getMatchedOrder(int stableKey) {
    return _activeMatches[stableKey];
  }

  // [신규 컵 등장 시 호출] stableKey는 호출부(화면)가 이번에 처음 보는
  // 물리적 컵에 새로 부여한 값 — 이 함수 안에서는 그냥 하나의 식별자로만
  // 쓰이고, ToF 센서의 raw id와는 무관함(그 부분은 호출부가 위치 매칭으로
  // 이미 걸러냄).
  static Map<String, dynamic>? getOrAssignOrder(int stableKey, Offset currentPos, Color initialColor, double physicalDiameter) {
    _cleanupGhosts();
    if (_activeMatches.containsKey(stableKey)) {
      _activeMatches[stableKey]!['pos'] = currentPos;
      return _activeMatches[stableKey];
    }

    GhostOrder? matchedGhost;

    for (var ghost in _ghostMemory) {
      if (AppConstants.isCommercialMode) {
        // 상업용 모드: 인접 슬롯 간격(200px) < spatialThreshold(250px) 이므로
        // 거리 기반 매칭은 인접 슬롯까지 오인식한다.
        // 고스트가 속한 슬롯의 바운딩 박스 내에 컵이 있을 때만 재매칭.
        final Offset? slotCenter = _slotPositions[ghost.orderNo];
        if (slotCenter == null) continue;
        final double halfW = _slotHalfWidths[ghost.orderNo] ?? _defaultHalfWidth;
        const double halfH = 100.0; // 높이는 항상 200 고정
        final bool isInBox =
            currentPos.dx >= slotCenter.dx - halfW &&
            currentPos.dx <= slotCenter.dx + halfW &&
            currentPos.dy >= slotCenter.dy - halfH &&
            currentPos.dy <= slotCenter.dy + halfH;
        if (!isInBox) continue;
      } else {
        // 자유 트래킹 모드: 기존 거리 기반 재매칭 유지
        if ((ghost.lastPos - currentPos).distance >= spatialThreshold) continue;
      }
      matchedGhost = ghost;
      break;
    }

    if (matchedGhost != null) {
      _ghostMemory.remove(matchedGhost);
      final reclaimed = {
        "orderNo": matchedGhost.orderNo,
        "menuName": matchedGhost.menuName,
        "nickname": matchedGhost.nickname,
        "color": matchedGhost.color,
        "drinkCount": matchedGhost.drinkCount,
        "foodCount": matchedGhost.foodCount,
        "bottleCount": matchedGhost.bottleCount,
        "pos": currentPos,
        "lang": matchedGhost.lang,
      };
      _activeMatches[stableKey] = reclaimed;
      return reclaimed;
    }

    // if (_waitingQueue.isNotEmpty) {
    //   final assigned = _waitingQueue.removeAt(0);
    //   final newMatch = {
    //     "orderNo": assigned['orderNo']!,
    //     "menuName": assigned['menuName']!,
    //     "nickname": assigned['nickname']!,
    //     "drinkCount": assigned['drinkCount'],
    //     "foodCount": assigned['foodCount'],
    //     "bottleCount": assigned['bottleCount'],
    //     "color": initialColor,
    //     "pos": currentPos
    //   };
    //   _activeMatches[stableKey] = newMatch;
    //   return newMatch;
    // }
    if (!AppConstants.isCommercialMode) {
      // 자유 트래킹 모드: 기존 거리 기반 순차 매칭
      if (_waitingQueue.isNotEmpty) {
        final assigned = _waitingQueue.first;

        // 🌟 [핵심 방어 로직] 컵의 지름(크기)을 기반으로 몇 잔이 뭉쳐있는지 추정
        // 매장 컵 사이즈에 맞춰 기준값(Threshold)은 미세 조정이 필요할 수 있습니다.
        int estimatedCupsInBlob = 1;

        // 일반 컵 지름이 80~90mm라고 가정할 때,
        if (physicalDiameter > 130.0 && physicalDiameter <= 220.0) {
          estimatedCupsInBlob = 2; // 2잔이 붙어있음
        } else if (physicalDiameter > 220.0) {
          estimatedCupsInBlob = 3; // 3잔 이상이 붙어있음
        }

        // 붙어있는 잔 수만큼 한 번에 카운트를 올립니다!
        assigned['placedCount'] = (assigned['placedCount'] ?? 0) + estimatedCupsInBlob;

        final newMatch = {
          "orderNo": assigned['orderNo']!,
          "menuName": assigned['menuName']!,
          "nickname": assigned['nickname']!,
          "drinkCount": assigned['drinkCount'],
          "foodCount": assigned['foodCount'],
          "bottleCount": assigned['bottleCount'],
          "color": initialColor,
          "pos": currentPos,
          "lang": assigned['lang'] ?? '',
        };
        _activeMatches[stableKey] = newMatch;

        print("☕ [Manager] 컵 매칭: $stableKey -> NO.${assigned['orderNo']} (${assigned['placedCount']}/${assigned['totalRequired']})");

        // 주문된 모든 컵이 전부 테이블에 올라왔다면 그때서야 대기열에서
        // 완전히 삭제(가이드 원 자체는 이제 이것과 무관하게 첫 컵이 놓이는
        // 순간 이미 사라짐 — aio_pickuptable_main.dart의 _updateGuidePositions
        // 참고). 대기열엔 여전히 남겨둬야 남은 잔이 계속 같은 주문으로 매칭됨.
        if (assigned['placedCount'] >= (assigned['totalRequired'] ?? 1)) {
          _waitingQueue.removeAt(0);
        }
        return newMatch;
      }
    } else {
      // 상업용 모드: 컵 좌표가 슬롯 바운딩 박스(가로 가변, 세로 고정 200) 내에 있는지 여부로 매칭
      for (var order in _waitingQueue) {
        final String orderNo = order['orderNo']! as String;
        final Offset? slotCenter = _slotPositions[orderNo];
        if (slotCenter == null) continue;

        final double halfW = _slotHalfWidths[orderNo] ?? _defaultHalfWidth;
        const double halfH = 100.0;
        final bool isInBox =
            currentPos.dx >= slotCenter.dx - halfW &&
            currentPos.dx <= slotCenter.dx + halfW &&
            currentPos.dy >= slotCenter.dy - halfH &&
            currentPos.dy <= slotCenter.dy + halfH;

        if (isInBox) {
          int estimatedCupsInBlob = 1;
          if (physicalDiameter > 130.0 && physicalDiameter <= 220.0) {
            estimatedCupsInBlob = 2;
          } else if (physicalDiameter > 220.0) {
            estimatedCupsInBlob = 3;
          }
          order['placedCount'] = (order['placedCount'] ?? 0) + estimatedCupsInBlob;

          final newMatch = {
            "orderNo": order['orderNo']!,
            "menuName": order['menuName']!,
            "nickname": order['nickname']!,
            "drinkCount": order['drinkCount'],
            "foodCount": order['foodCount'],
            "bottleCount": order['bottleCount'],
            "color": initialColor,
            "pos": currentPos,
            "lang": order['lang'] ?? '',
          };
          _activeMatches[stableKey] = newMatch;

          print("☕ [Manager][상업용] 컵 매칭: $stableKey -> NO.$orderNo (박스 내 감지)");

          if (order['placedCount'] >= (order['totalRequired'] ?? 1)) {
            _waitingQueue.remove(order);
          }
          return newMatch;
        }
      }
    }
    return null;
  }

  /// [stableKey에 해당하는 컵이 화면에서 사라졌을 때 호출] 마찬가지로
  /// stableKey는 호출부가 위치 매칭으로 이미 "같은 물리적 컵"이라고 판단한
  /// 값이라, 그 컵의 raw id가 그동안 몇 번을 바뀌었든 여기서는 항상 같은
  /// 항목을 정확히 찾아 지운다.
  static Map<String, dynamic>? releaseId(int stableKey) {
    if (_activeMatches.containsKey(stableKey)) {
      final removed = _activeMatches.remove(stableKey);

      // [수정] 주문번호가 UNKNOWN이 아닐 때만 유령으로 등록
      if (removed!['orderNo'] != "UNKNOWN") {
        _ghostMemory.add(GhostOrder(
          orderNo: removed['orderNo'],
          menuName: removed['menuName'],
          nickname: removed['nickname'] ?? "",
          drinkCount: removed['drinkCount'] ?? 0,
          foodCount: removed['foodCount'] ?? 0,
          bottleCount: removed['bottleCount'] ?? 0,
          color: removed['color'],
          lastPos: removed['pos'],
          disappearedAt: DateTime.now(),
          lang: removed['lang'] ?? '',
        ));
        print("⏳ [Manager] stableKey=$stableKey -> No.${removed['orderNo']} 유령 전환");
      } else {
        print("🗑️ [Manager] UNKNOWN 객체 삭제 (유령 등록 안 함)");
      }
      return removed;
    }
    return null;
  }

  /// 픽업 완료 확정 시 해당 주문의 대기열 잔류 항목을 완전히 제거한다.
  /// 중복 가드를 통과한 잔류 항목이 있더라도 안전하게 정리하는 안전망 역할.
  static void clearOrderFromQueue(String orderNo) {
    final removed = _waitingQueue.removeWhere((o) => o['orderNo'] == orderNo);
    _receivedReadyCounts.remove(orderNo);
    _pendingOrders.remove(orderNo);
    print("🧹 [Manager] $orderNo번 대기열 잔류 항목 정리 완료");
  }

  static void _cleanupGhosts() {
    final now = DateTime.now();
    _ghostMemory.removeWhere((g) => now.difference(g.disappearedAt) > ghostDuration);
  }

  static bool isGhostStillExists(String orderNo, Offset pos) {
    _cleanupGhosts();
    return _ghostMemory.any((g) =>
    g.orderNo == orderNo && (g.lastPos - pos).distance < 30.0
    );
  }

  static Map<int, Map<String, dynamic>> get activeMatches => _activeMatches;
}