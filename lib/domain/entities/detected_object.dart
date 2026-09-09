import 'dart:ui';

// UI 표시용 모델
class DetectedObject {
  final int id;
  final String orderNo; // 그룹핑 기준
  final Offset position; // 좌표 (x, y)
  final double zValue; // 높이
  final double diameter; // 지름
  final double uiWidth;
  final double uiHeight;
  final double labelAngle;
  final Color color;
  // id는 매 프레임 센서가 새로 준 tof.id를 그대로 쓰고 있어서(아래 매칭
  // 로직 참고) 센서가 같은 물리적 컵에 다른 id를 재부여하면 값이 바뀔 수
  // 있음 — 주문 매칭 로직은 이 id에 의존하고 있어 그대로 두되, baseCircle
  // 위젯의 Key(=State/애니메이션 유지)는 이 값 대신 stableKey를 써서,
  // id가 프레임마다 바뀌어도 같은 물리적 컵이면 애니메이션이 리셋되지
  // 않도록 함.
  final int stableKey;
  // orderNo(위)는 사실 복합 라벨 문자열(아이콘+수량 | 이름)이라 고객 QR
  // 스캔 이벤트로 온 순수 주문번호와 직접 비교할 수 없음 — 그 원본 값을
  // 따로 보관.
  final String rawOrderNo;
  // 고객의 kiosk 세션 언어("en"/"ko"/"ja"/"zh") — 주문번호/닉네임 아치 텍스트에
  // 어떤 폰트(AppConstants.fontFamilyForLanguage)를 쓸지 결정하는 데 씀.
  final String lang;
  // 라즈베리파이 통합 추적 레이어의 현재 소스 - true면 Amplitude(투명/반사
  // 컵 폴백)로 추적 중이라 빨간색, false면 Depth로 추적 중이라 흰색.
  // (예전 object_id>=9000 방식은 id가 통일되면서 더 이상 안 씀)
  final bool isAmplitude;

  DetectedObject({
    required this.id,
    required this.orderNo,
    required this.position,
    required this.zValue,
    required this.diameter,
    required this.uiWidth,
    required this.uiHeight,
    required this.stableKey,
    this.labelAngle = 1.0,
    required this.color,
    this.rawOrderNo = '',
    this.lang = '',
    this.isAmplitude = false,
  });
}
