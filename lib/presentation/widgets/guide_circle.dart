import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

import 'package:pickup_table/core/constants/app_constants.dart';
import 'arc_text_painter.dart';

/// Viewfinder-style corner-bracket pair (top-left + bottom-right) — replaces
/// the old solid-filled per-cup circle as the "cups placed" order-level
/// indicator. Drawn ONCE per order, sized/positioned by the caller to the
/// bounding box of every cup (live + pickup-ghost) currently belonging to
/// that order (see aio_pickuptable_main.dart's order-bounds computation),
/// not per individual cup — a multi-cup order gets one bracket spanning all
/// of its cups regardless of how they're arranged on the table.
class OrderBracketPainter extends CustomPainter {
  // Fixed white in the normal state — this used to vary per cup
  // (debugFillColor: Depth=white/Amplitude=red on BaseCircleWidget) but that
  // distinction is retired now that this is a group-level indicator, not a
  // per-cup one.
  static const Color _color = Colors.white;
  // Same pink/red highlight tone BaseCircleWidget's own ring already uses
  // for isHighlighted, so the whole order (bracket + label chip + each
  // individual cup's ring) reads as one consistent highlight color.
  static const Color _highlightColor = Color(0xFFFFABAB);

  final bool isHighlighted;
  final double armLength;
  final double strokeWidth;

  const OrderBracketPainter({
    this.isHighlighted = false,
    this.armLength = 28.0,
    this.strokeWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isHighlighted ? _highlightColor : _color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Clamp so the two arms of one corner never overlap/cross on a very
    // small bounding box (a single small cup close to the min diameter).
    final double arm = math.min(armLength, math.min(size.width, size.height) / 2);

    // Top-left corner.
    canvas.drawLine(Offset.zero, Offset(arm, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, arm), paint);

    // Bottom-right corner.
    final bottomRight = Offset(size.width, size.height);
    canvas.drawLine(bottomRight, Offset(size.width - arm, size.height), paint);
    canvas.drawLine(bottomRight, Offset(size.width, size.height - arm), paint);
  }

  @override
  bool shouldRepaint(covariant OrderBracketPainter oldDelegate) =>
      oldDelegate.isHighlighted != isHighlighted ||
      oldDelegate.armLength != armLength ||
      oldDelegate.strokeWidth != strokeWidth;
}

class OrderBracketWidget extends StatelessWidget {
  final double width;
  final double height;
  final bool isHighlighted;

  const OrderBracketWidget({
    super.key,
    required this.width,
    required this.height,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size(width, height),
        painter: OrderBracketPainter(isHighlighted: isHighlighted),
      ),
    );
  }
}

/// Order-number + drink-count label, shown near an [OrderBracketWidget] —
/// same text content the old per-cup arc text showed ("icon+count | name",
/// built by _buildComplexLabel), just laid out as a plain chip instead of
/// wrapped in an arc around a circle. The caller (aio_pickuptable_main.dart)
/// positions this — by default just outside the bracket's bottom-right
/// corner, moved to the top-left corner instead if the default spot would
/// overlap another order's bracket or run off-screen.
class OrderLabelChip extends StatelessWidget {
  final String label;
  final String lang;
  final bool isHighlighted;

  const OrderLabelChip({
    super.key,
    required this.label,
    this.lang = '',
    this.isHighlighted = false,
  });

  // Normal: white background, black text. Highlighted (QR-scanned) keeps
  // the existing red tone — same one OrderBracketPainter blinks in — so
  // that signal stays visually distinct from the normal state.
  static const Color _normalBg = Colors.white;
  static const Color _normalFg = Colors.black;
  static const Color _highlightBg = Color(0xFFE93C3C);
  static const Color _highlightFg = Colors.white;

  // label arrives as "아이콘+수량 | 주문번호" (_buildComplexLabel's own order —
  // shared with OrderGuideWidget, which relies on THAT exact order for its
  // own arc-text reversal, so it can't be changed at the source). This chip
  // shows the order number first instead: "주문번호 | 아이콘+수량".
  String get _reversedLabel {
    final parts = label.split('|');
    if (parts.length != 2) return label;
    final icon = parts[0].trim();
    final name = parts[1].trim();
    return '$name | $icon';
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isHighlighted ? _highlightBg : _normalBg,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          _reversedLabel,
          style: TextStyle(
            color: isHighlighted ? _highlightFg : _normalFg,
            fontSize: 16.0,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.16,
            fontFamily: AppConstants.fontFamilyForLanguage(lang),
            fontFamilyFallback: const ['Noto Color Emoji'],
          ),
        ),
      ),
    );
  }
}

/// Hard on/off visibility toggle at a fixed interval — no fade, just an
/// instant show/hide, for guideCircle and the highlighted baseCircle's
/// blink. Scoped to only this widget's subtree so toggling repaints just
/// what's wrapped here, not the whole screen (same "isolate the repaint"
/// reasoning as PickupBackgroundVideo's own Opacity-toggle elsewhere in this
/// app — avoids the GPU load a screen-wide rebuild would add).
class BlinkingVisibility extends StatefulWidget {
  final bool enabled;
  final Duration interval;
  final Widget child;

  const BlinkingVisibility({
    super.key,
    required this.enabled,
    this.interval = const Duration(milliseconds: 500),
    required this.child,
  });

  @override
  State<BlinkingVisibility> createState() => _BlinkingVisibilityState();
}

class _BlinkingVisibilityState extends State<BlinkingVisibility> {
  Timer? _timer;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _startBlinking();
  }

  @override
  void didUpdateWidget(covariant BlinkingVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _startBlinking();
      } else {
        _stopBlinking();
      }
    }
  }

  void _startBlinking() {
    _timer?.cancel();
    _visible = true;
    _timer = Timer.periodic(widget.interval, (_) {
      setState(() => _visible = !_visible);
    });
  }

  void _stopBlinking() {
    _timer?.cancel();
    _timer = null;
    setState(() => _visible = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _visible ? 1.0 : 0.5,
      child: widget.child,
    );
  }
}

// lib/components/guide_circle.dart

// class OrderGuideWidget extends StatelessWidget {
//   final String label;
//   final Color color;
//   final Map<String, ui.Image> icons;
//
//   const OrderGuideWidget({
//     super.key,
//     required this.label,
//     this.color = Colors.cyanAccent,
//     required this.icons,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     const double size = 180.0;
//     const double guideRadius = size / 2;
//     const double textRadius = guideRadius + 25.0; // 텍스트가 그려질 궤도
//     final double dynamicFontSize = label.length > 10 ? 12.0 : 15.0;
//     // 텍스트 스타일 설정 (컵과 동일한 스타일)
//     final TextStyle labelStyle = TextStyle(
//       color: Colors.white,
//       fontSize: dynamicFontSize,
//       fontWeight: FontWeight.bold,
//       letterSpacing: 1.5,
//       fontFamilyFallback: ['Noto Color Emoji'],
//     );
//
//     // 12시 방향 중앙 정렬을 위한 각도 계산
//     final textPainter = TextPainter(
//       text: TextSpan(text: label, style: labelStyle),
//       textDirection: TextDirection.ltr,
//     )..layout();
//
//     final double totalAngle = textPainter.width / textRadius;
//     // 12시 방향(-pi/2)을 기준으로 텍스트 너비의 절반만큼 뒤로 이동
//     final double startAngle12 = -math.pi / 2 + (totalAngle / 2);
//
//     return SizedBox(
//       width: size,
//       height: size,
//       child: Stack(
//         alignment: Alignment.center,
//         clipBehavior: Clip.none,
//         children: [
//           // 1. 가이드 이미지 (180도 회전 - 바리스타 시점)
//           Transform.rotate(
//             angle: math.pi,
//             child: Image.asset(
//               'assets/images/cafe_beta.png',
//               width: size,
//               height: size,
//               fit: BoxFit.contain,
//               // color: color.withOpacity(0.5), // 필요 시 색상 필터 적용 가능
//             ),
//           ),
//
//           // 2. 12시 방향 곡선 라벨
//           CustomPaint(
//             size: const Size(size, size),
//             painter: ArcTextPainter(
//               text: label,
//               radius: textRadius,
//               startAngle: startAngle12,
//               style: labelStyle,
//               icons: icons,
//             ),
//           ),
//
//           // 추후 여기에 Pulsing 애니메이션 등을 추가하기 매우 쉬워집니다.
//         ],
//       ),
//     );
//   }
// }
class OrderGuideWidget extends StatelessWidget {
  final String label;
  final Color color;
  final Map<String, ui.Image> icons;
  final int totalCups;
  // Customer's kiosk-session language ("en"/"ko"/"ja"/"zh") — the label can
  // be the customer's own nickname (see _buildComplexLabel), so it needs
  // whichever font actually covers that script (see
  // AppConstants.fontFamilyForLanguage).
  final String lang;

  const OrderGuideWidget({
    super.key,
    required this.label,
    this.color = Colors.cyanAccent,
    required this.icons,
    this.totalCups = 1,
    this.lang = '',
  });

  // Figma guideCircle spec (redesign) — order-number segment: 16px/700/
  // line-height 100%/letterSpacing 1%, white (circle is now a solid fill,
  // not a light gradient, so text needs to be white instead of the old
  // light-blue tones).
  static const TextStyle _baseNameStyle = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 16.0,
    height: 1.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.16,
    fontFamilyFallback: ['Noto Color Emoji'],
  );

  // "|" divider — kept as the boundary marker between name/icon segments
  // (guideCircle still has no per-segment background chip, just one
  // uniform fill color, same reasoning as before the redesign).
  static const TextStyle _pipeStyle = TextStyle(
    color: Color(0x4DFFFFFF),
    fontSize: 16.0,
    height: 1.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.16,
  );

  // Drink icon + its count digit: both tinted white directly — no separate
  // background chip behind them.
  static const TextStyle _baseNumberStyle = TextStyle(
    color: Color(0xFFFFFFFF),
    fontSize: 16.0,
    height: 17.91 / 16.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.08,
    fontFamilyFallback: ['Noto Color Emoji'],
  );

  TextStyle get _nameStyle =>
      _baseNameStyle.copyWith(fontFamily: AppConstants.fontFamilyForLanguage(lang));

  TextStyle get _numberStyle =>
      _baseNumberStyle.copyWith(fontFamily: AppConstants.fontFamilyForLanguage(lang));

  // label arrives as "아이콘+수량 | 주문번호". 바리스타가 보는 방향(코드상
  // 12시 = 바리스타 시점 6시) 기준으로 주문번호 우측에 아이콘+수량이 와야
  // 해서, 전체 문자열을 그대로 두면 좌측에 나오던 걸 순서만 뒤집어서
  // "주문번호 | 아이콘+수량"으로 넘김 — 전체 폭/중심 각도는 순서와 무관하게
  // 그대로라 이 스왑만으로 좌우가 정확히 뒤바뀜.
  String get _reversedLabel {
    final parts = label.split('|');
    if (parts.length != 2) return label;
    final icon = parts[0].trim();
    final name = parts[1].trim();
    return '$name | $icon';
  }

  @override
  Widget build(BuildContext context) {
    final double size = 180.0 + ((totalCups - 1) * 60.0);
    final double guideRadius = size / 2;
    final double textRadius = guideRadius - 25.0; // 텍스트가 그려질 궤도 (원 안쪽)
    final String displayLabel = _reversedLabel;

    // 12시 방향 중앙 정렬을 위한 각도 계산
    final textPainter = TextPainter(
      text: TextSpan(text: displayLabel, style: _nameStyle),
      textDirection: TextDirection.ltr,
    )..layout();

    final double totalAngle = textPainter.width / textRadius;
    // 12시 방향(-pi/2)을 기준으로 텍스트 너비의 절반만큼 뒤로 이동
    final double startAngle12 = -math.pi / 2 + (totalAngle / 2);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. 단색 채움 원 (#E93C3C)
          CustomPaint(
            size: Size(size, size),
            painter: const GuideCirclePainter(),
          ),

          // 2. 12시 방향 곡선 라벨 (주문번호 + | + 음료아이콘/수량)
          CustomPaint(
            size: Size(size, size),
            painter: ArcTextPainter(
              text: displayLabel,
              radius: textRadius,
              startAngle: startAngle12,
              style: _nameStyle,
              pipeStyle: _pipeStyle,
              numberStyle: _numberStyle,
              iconCountGapPx: 4,
              icons: icons,
            ),
          ),
        ],
      ),
    );
  }
}

// 점선 원을 그려주는 CustomPainter
// class DashedCirclePainter extends CustomPainter {
//   final Color color;
//   final double strokeWidth;
//   final double dashWidth;
//   final double dashSpace;
//   final double glowIntensity;
//
//   DashedCirclePainter({
//     required this.color,
//     this.strokeWidth = 3.0,
//     this.dashWidth = 15.0, // 점선 하나의 길이
//     this.dashSpace = 10.0, // 점선 사이의 간격
//     this.glowIntensity = 0.0,
//   });
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..strokeWidth = strokeWidth
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round; // 끝을 둥글게 처리하여 부드러운 느낌 제공
//
//     final center = Offset(size.width / 2, size.height / 2);
//     final radius = size.width / 2;
//     final perimeter = 2 * math.pi * radius; // 원의 둘레
//
//     int dashCount = (perimeter / (dashWidth + dashSpace)).floor();
//     double sweepAngle = (dashWidth / perimeter) * 2 * math.pi; // 선이 그려질 각도
//     double spaceAngle = (dashSpace / perimeter) * 2 * math.pi; // 비워둘 각도
//
//     double currentAngle = 0;
//     for (int i = 0; i < dashCount; i++) {
//       canvas.drawArc(
//         Rect.fromCircle(center: center, radius: radius),
//         currentAngle,
//         sweepAngle,
//         false,
//         paint,
//       );
//       currentAngle += sweepAngle + spaceAngle;
//     }
//   }
//
//   @override
//   bool shouldRepaint(DashedCirclePainter oldDelegate) {
//     return oldDelegate.color != color ||
//         oldDelegate.strokeWidth != strokeWidth;
//   }
// }
/// Figma guideCircle spec (redesign): solid-filled circle, no border — was
/// previously a dashed border + light gradient fill, replaced entirely.
class GuideCirclePainter extends CustomPainter {
  // Beta-Accent-Raspberry-R6
  static const Color _fillColor = Color(0xFFE93C3C);

  const GuideCirclePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawCircle(center, radius, Paint()..color = _fillColor);
  }

  @override
  bool shouldRepaint(covariant GuideCirclePainter oldDelegate) => false;
}

/// 실제 컵이 테이블에 놓였을 때 표시되는 원(baseCircle). [placedAt] 시점부터
/// 2단계 회전(4000ms에 2바퀴 → 이어서 10000ms에 3바퀴 → 정지)이 진행되고,
/// 회전하는 동안에는 guideCircle에 예전에 있던 것과 동일한 커졌다 작아졌다
/// (scale+opacity) 펄스 효과가 함께 적용된다.
// 회전/펄스 애니메이션은 컵 개수만큼 AnimationController가 곱해지는 구조라
// 성능 문제(컵 5개 이상 + 동시 입출 시 프리징/크래시)의 주요 원인으로
// 지목되어 완전히 제거함 — 항상 "정지" 상태(단색 링)로만 그림. 그 결과 내부
// 상태가 필요 없어져 StatefulWidget에서 StatelessWidget으로 전환(placedAt도
// 애니메이션 재생 시점 계산에만 쓰였던 값이라 함께 제거).
class BaseCircleWidget extends StatelessWidget {
  final String label;
  final double diameter;
  final Map<String, ui.Image> icons;
  /// effectCircle — 고객이 QR을 스캔해 이 주문이 확인됐을 때 true. 링/배경칩/
  /// 아이콘+숫자 색을 전부 강조색으로 덮어씀.
  final bool isHighlighted;
  /// null이 아니면 "픽업 고스트" 상태 — 컵을 치운 뒤 ghostDuration(5초)
  /// 동안 이 자리에 원이 남아 중심부가 채워지고 이 메시지가 표시됨. 주문번호
  /// 아치 텍스트는 평소 그대로.
  final String? pickupMessage;
  // Customer's kiosk-session language ("en"/"ko"/"ja"/"zh") — the label can
  // be the customer's own nickname, and pickupMessage is always a real
  // translated string, so both need whichever font actually covers that
  // script (see AppConstants.fontFamilyForLanguage).
  final String lang;
  // TEMP/디버그용: null이면 평소 크림색 원, 지정하면 이 색으로 채워짐 —
  // Depth 기반과 Amplitude 폴백 기반 감지를 화면에서 구분하기 위한 테스트용
  // 파라미터. 검증 끝나면 제거할 것.
  final Color? debugFillColor;

  const BaseCircleWidget({
    super.key,
    required this.label,
    required this.diameter,
    required this.icons,
    this.isHighlighted = false,
    this.pickupMessage,
    this.lang = '',
    this.debugFillColor,
  });

  // 주문번호: 16px/800/line-height 100%/letterSpacing 1%/#011722 — 배경칩과
  // 달리 강조(effectCircle) 상태에서도 글자색 자체는 안 바뀜(배경칩만
  // #FFF8EF → #FFABAB로 바뀜).
  static const TextStyle _baseNameStyle = TextStyle(
    color: Color(0xFF011722),
    fontSize: 16.0,
    height: 1.0,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.16,
    fontFamilyFallback: ['Noto Color Emoji'],
  );

  // "|" 구분선 색상은 스펙에 명시되어 있지 않아 guideCircle과 동일한 방식
  // (연한 반투명)으로 맞춤 — 다른 색을 원하시면 알려주세요. (baseCircle
  // 라벨엔 실제로 '|'가 없어서 이 스타일은 쓰이지 않음.)
  static const TextStyle _pipeStyle = TextStyle(
    color: Color(0x4D011722),
    fontSize: 16.0,
    height: 1.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.16,
  );

  // 우측 음료 아이콘/숫자: 평소엔 #FFF8EF, effectCircle일 땐 #FFFCF7.
  static const TextStyle _baseNumberStyleNormal = TextStyle(
    color: Color(0xFFFFF8EF),
    fontSize: 16.0,
    height: 17.91 / 16.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.08,
    fontFamilyFallback: ['Noto Color Emoji'],
  );
  static const TextStyle _baseNumberStyleHighlighted = TextStyle(
    color: Color(0xFFFFFCF7),
    fontSize: 16.0,
    height: 17.91 / 16.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.08,
    fontFamilyFallback: ['Noto Color Emoji'],
  );

  TextStyle get _nameStyle =>
      _baseNameStyle.copyWith(fontFamily: AppConstants.fontFamilyForLanguage(lang));

  TextStyle get _numberStyle => (isHighlighted ? _baseNumberStyleHighlighted : _baseNumberStyleNormal)
      .copyWith(fontFamily: AppConstants.fontFamilyForLanguage(lang));

  // 픽업 고스트 중심부 메시지: 14px/330(번들 폰트에 없어 가장 가까운 400)/
  // line-height 134%/letterSpacing 1%/#E0D5C8, 가운데 정렬.
  static const TextStyle _basePickupMessageStyle = TextStyle(
    color: Color(0xFFE0D5C8),
    fontSize: 14.0,
    height: 1.34,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.14,
    fontFamilyFallback: ['Noto Color Emoji'],
  );

  TextStyle get _pickupMessageStyle =>
      _basePickupMessageStyle.copyWith(fontFamily: AppConstants.fontFamilyForLanguage(lang));

  // label arrives as "아이콘+수량 | 주문번호" (같은 문자열을 guideCircle도
  // 그대로 씀). baseCircle은 음료아이콘+숫자가 주문번호 기준 우측에 와야
  // 해서, 글자를 소비하는 순서상 먼저 나온 세그먼트가 반대쪽(좌측)으로 가는
  // 구조를 뒤집어야 함 — "주문번호  아이콘+수량"으로 순서를 바꿔서 넘김.
  // guideCircle은 배경이 없어서 "|"로 구간을 구분해야 하지만, baseCircle은
  // 주문번호 뒤에 배경칩이 이미 있어서 "|"가 굳이 필요 없음 — 제거함. 간격은
  // 문자열 공백이 아니라 ArcTextPainter의 nameIconGapPx(8px)로 정확히 지정함.
  String get _reversedLabel {
    final parts = label.split('|');
    if (parts.length != 2) return label;
    final icon = parts[0].trim();
    final name = parts[1].trim();
    return '$name$icon';
  }

  // "|" 없이 문자열만 보고는 이름/아이콘 경계를 찾을 수 없어서, 여기서 이미
  // 알고 있는 이름 길이를 그대로 넘겨줌.
  int? get _nameLength {
    final parts = label.split('|');
    if (parts.length != 2) return null;
    return parts[1].trim().characters.length;
  }

  @override
  Widget build(BuildContext context) {
    final double textRadius = diameter / 2 + 15.0;
    final String reversedLabel = _reversedLabel;
    final int? nameLength = _nameLength;

    // 6시 방향에 "전체 문자열"이 아니라 "주문번호(name) 세그먼트"만 중앙
    // 정렬되어야 해서(음료아이콘+숫자는 그 옆으로 자연스럽게 밀려남),
    // guideCircle의 12시 방향(전체 문자열 중앙 정렬)과는 다른 계산이 필요함.
    final double startAngle6 = ArcTextPainter.startAngleForNameCenteredAt(
      text: reversedLabel,
      targetAngle: math.pi / 2,
      radius: textRadius,
      style: _nameStyle,
      pipeStyle: _pipeStyle,
      nameLeadingLength: nameLength,
      icons: icons,
    );

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (pickupMessage != null) ...[
            // 그림자 전용 레이어 — 아래 틴트 레이어와 분리해서 그림(그림자는
            // 원 바깥으로 퍼져야 하는데, 안쪽 채움과 같은 레이어에 있으면
            // 굳이 클립할 이유가 생겨 불필요하게 복잡해짐).
            IgnorePointer(
              child: Container(
                width: diameter,
                height: diameter,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(offset: Offset(0, 4), blurRadius: 17.9, color: Color(0x66000000)),
                    BoxShadow(offset: Offset(-2, -3), blurRadius: 12.4, color: Color(0x4DFFFFFF)),
                  ],
                ),
              ),
            ),
            // 원 내부 틴트 — BackdropFilter 블러는 매 프레임 재계산되는 무거운
            // 연산이라 제거하고 단색 반투명 채움만 사용(여러 개가 동시에 떠도
            // 가벼움, 뒤 영상이 재생 중이든 멈춰있든 비용 동일).
            IgnorePointer(
              child: Container(
                width: diameter,
                height: diameter,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xE568645E),
                ),
              ),
            ),
          ],
          CustomPaint(
            size: Size(diameter, diameter),
            painter: BaseCirclePainter(
              isHighlighted: isHighlighted,
              drawFill: pickupMessage == null,
              debugFillColor: debugFillColor,
            ),
          ),
          CustomPaint(
            size: Size(diameter, diameter),
            painter: ArcTextPainter(
              text: reversedLabel,
              radius: textRadius,
              startAngle: startAngle6,
              style: _nameStyle,
              pipeStyle: _pipeStyle,
              numberStyle: _numberStyle,
              nameBadgeColor: isHighlighted
                  ? const Color(0xFFFFABAB)
                  : const Color(0xFFFFF8EF),
              nameLeadingLength: nameLength,
              nameIconGapPx: 16,
              iconCountGapPx: 4,
              icons: icons,
            ),
          ),
          if (pickupMessage != null)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: diameter * 0.12),
                    child: Text(
                      pickupMessage!,
                      textAlign: TextAlign.center,
                      style: _pickupMessageStyle,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// baseCircle의 링 — 회전 중에는 크림색(#FFEDD5) 베이스 위로 흰색 하이라이트가
/// 도는 conic gradient, 정지하면 단색 크림 스트로크.
///
/// Figma baseCircle/effectCircle spec (redesign): solid-filled circle — the
/// fill color never changes; only the border and an outer glow (a box-shadow
/// with blur:0, i.e. a solid ring extending past the border with a sharp
/// edge) swap when [isHighlighted] (customer scanned their receipt QR). In
/// the normal state fill==border and the shadow is fully transparent, so it
/// just reads as a plain cream disc until highlighted.
class BaseCirclePainter extends CustomPainter {
  static const Color _fillColor = Color(0xFFFFF8EF);
  static const double _normalBorderWidth = 4.0;
  static const double _highlightedBorderWidth = 3.0;
  static const Color _highlightBorderColor = Color(0xFFFFABAB);
  static const Color _highlightShadowColor = Color(0x80FF6B6B);
  static const double _highlightShadowSpread = 8.0;

  final bool isHighlighted;
  // The pickup "thank you" ghost circle draws its own tint layer underneath
  // (#68645EE5 — a different fill than baseCircle's normal cream) and needs
  // only this painter's border ring on top of it; an opaque fill here would
  // paint over that tint and hide it entirely. Border/shadow still draw as
  // usual either way.
  final bool drawFill;
  // TEMP/디버그용: null이면 평소 크림색(_fillColor), 지정하면 이 색으로 채워짐.
  final Color? debugFillColor;

  const BaseCirclePainter({
    this.isHighlighted = false,
    this.drawFill = true,
    this.debugFillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final borderWidth = isHighlighted ? _highlightedBorderWidth : _normalBorderWidth;
    final Color fillColor = debugFillColor ?? _fillColor;

    // box-shadow: 0px 0px 0px 8px, blur 0 — a solid ring extending past the
    // border with a sharp edge (no blur to fake), invisible in the normal
    // state (spec's shadow there is fully transparent) so just skip it.
    if (isHighlighted) {
      canvas.drawCircle(
        center,
        outerRadius + _highlightShadowSpread,
        Paint()..color = _highlightShadowColor,
      );
    }

    // Fill extends under the full border ring (not just up to its inner
    // edge) so the two separately-rasterized circles overlap instead of
    // meeting edge-to-edge — otherwise anti-aliasing leaves a visible seam
    // at the boundary. The stroke below is painted on top and covers it.
    if (drawFill) {
      canvas.drawCircle(center, outerRadius, Paint()..color = fillColor);
    }

    canvas.drawCircle(
      center,
      outerRadius - borderWidth / 2,
      Paint()
        ..color = isHighlighted ? _highlightBorderColor : fillColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant BaseCirclePainter oldDelegate) =>
      oldDelegate.isHighlighted != isHighlighted ||
      oldDelegate.drawFill != drawFill ||
      oldDelegate.debugFillColor != debugFillColor;
}

// ── 상업용 모드 전용 위젯 ──────────────────────────────────────────────────────

/// 그리드 슬롯의 3가지 상태
enum GuideState {
  waiting, // 빈 슬롯 (컵 없음, 주문 대기 중)
  placed,  // 컵 안착됨
  ghost,   // 컵이 치워진 후 픽업 완료 대기 중
}

/// 인접 슬롯과 선 하나를 공유하는 선택적 테두리 드로잉 위젯.
///
/// 레이아웃:
///   drinkCount 개의 100px 라벨 박스 + 100px 컵 공간 = slotWidth
///   라벨 박스 안에 주문번호를 반시계 방향(quarterTurns:3) 90° 회전하여 표기.
///
/// 테두리 드로잉 규칙:
///   - Top, Left 는 항상 그린다.
///   - Right  는 우측 이웃이 없을 때만 그린다.
///   - Bottom 은 하단 이웃이 없을 때만 그린다.
class SquareGuideWidget extends StatelessWidget {
  final String orderNo;     // 주문번호 (e.g. "1001")
  final int drinkCount;     // 음료 수 — 라벨 박스 수 결정
  final GuideState state;
  final bool hasRightNeighbor;
  final bool hasBottomNeighbor;
  final bool topNeighborIsActive;
  final bool leftNeighborIsActive;
  final double slotWidth;   // 음료 수에 따라 가변 (drinkCount*100 + 100)

  static const double borderWidth  = 2.0;
  static const double slotHeight   = 200.0;
  static const double slotSize     = slotHeight; // 하위 호환 alias
  static const double labelBoxWidth = 100.0;

  const SquareGuideWidget({
    super.key,
    required this.orderNo,
    this.drinkCount = 1,
    this.state = GuideState.waiting,
    this.hasRightNeighbor = false,
    this.hasBottomNeighbor = false,
    this.topNeighborIsActive = false,
    this.leftNeighborIsActive = false,
    this.slotWidth = slotHeight,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = state == GuideState.placed || state == GuideState.ghost;
    final Color color = isActive ? Colors.greenAccent : Colors.white54;

    return SizedBox(
      width: slotWidth,
      height: slotHeight,
      child: CustomPaint(
        painter: GridBorderPainter(
          isActive: isActive,
          hasRightNeighbor: hasRightNeighbor,
          hasBottomNeighbor: hasBottomNeighbor,
          topNeighborIsActive: topNeighborIsActive,
          leftNeighborIsActive: leftNeighborIsActive,
        ),
        child: Row(
          children: [
            // 고정 100px 라벨 박스 (주문번호만 표기, drinkCount 무관)
            _LabelBox(orderNo: orderNo, color: color),
            // 나머지 = 컵 안착 공간 (drinkCount × 200px)
            const Expanded(child: SizedBox()),
          ],
        ),
      ),
    );
  }
}

/// 주문번호를 반시계 방향 90°로 표기하는 100×200 라벨 박스
class _LabelBox extends StatelessWidget {
  final String orderNo;
  final Color color;

  const _LabelBox({required this.orderNo, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SquareGuideWidget.labelBoxWidth,
      height: SquareGuideWidget.slotHeight,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: color.withValues(alpha: 0.5), width: 1.0),
        ),
      ),
      child: RotatedBox(
        quarterTurns: 3, // 반시계 방향 90°
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              orderNo,
              style: TextStyle(
                color: color,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 4면을 개별적으로 그리는 CustomPainter.
/// Top/Left 는 항상 그리고, Right/Bottom 은 이웃 없을 때만 그린다.
/// 공유 면 스타일: 양쪽 중 하나라도 active → 실선, 둘 다 waiting → 점선.
class GridBorderPainter extends CustomPainter {
  final bool isActive;
  final bool hasRightNeighbor;
  final bool hasBottomNeighbor;
  final bool topNeighborIsActive;
  final bool leftNeighborIsActive;

  static const double _bw = SquareGuideWidget.borderWidth; // 2.0
  static const Color _activeColor = Colors.greenAccent;
  static const Color _inactiveColor = Colors.white54;
  static const double _dashLen = 10.0;
  static const double _dashGap = 6.0;

  const GridBorderPainter({
    required this.isActive,
    this.hasRightNeighbor = false,
    this.hasBottomNeighbor = false,
    this.topNeighborIsActive = false,
    this.leftNeighborIsActive = false,
  });

  @override
  void paint(Canvas canvas, Size sz) {
    final w = sz.width;
    final h = sz.height;

    // Left 항상 그림. 왼쪽 이웃이 active이면 실선 override.
    _drawEdge(canvas, Offset(0, 0), Offset(0, h),
        solid: isActive || leftNeighborIsActive);

    // Top 항상 그림. 위쪽 이웃이 active이면 실선 override.
    _drawEdge(canvas, Offset(0, 0), Offset(w, 0),
        solid: isActive || topNeighborIsActive);

    // Right: 이웃 없을 때만 그림 (이웃이 있으면 이웃의 Left 가 대신 그림).
    if (!hasRightNeighbor) {
      _drawEdge(canvas, Offset(w, 0), Offset(w, h), solid: isActive);
    }

    // Bottom: 이웃 없을 때만 그림 (이웃이 있으면 이웃의 Top 이 대신 그림).
    if (!hasBottomNeighbor) {
      _drawEdge(canvas, Offset(0, h), Offset(w, h), solid: isActive);
    }
  }

  void _drawEdge(Canvas canvas, Offset p1, Offset p2, {required bool solid}) {
    final paint = Paint()
      ..color = solid ? _activeColor : _inactiveColor
      ..strokeWidth = _bw
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    if (solid) {
      canvas.drawLine(p1, p2, paint);
    } else {
      _drawDashed(canvas, paint, p1, p2);
    }
  }

  void _drawDashed(Canvas canvas, Paint paint, Offset p1, Offset p2) {
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len == 0) return;
    final ux = dx / len;
    final uy = dy / len;
    double dist = 0;
    while (dist < len) {
      final end = math.min(dist + _dashLen, len);
      canvas.drawLine(
        Offset(p1.dx + ux * dist, p1.dy + uy * dist),
        Offset(p1.dx + ux * end, p1.dy + uy * end),
        paint,
      );
      dist += _dashLen + _dashGap;
    }
  }

  @override
  bool shouldRepaint(GridBorderPainter old) =>
      old.isActive != isActive ||
      old.hasRightNeighbor != hasRightNeighbor ||
      old.hasBottomNeighbor != hasBottomNeighbor ||
      old.topNeighborIsActive != topNeighborIsActive ||
      old.leftNeighborIsActive != leftNeighborIsActive;
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  const DashedRectPainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashWidth = 10.0,
    this.dashSpace = 6.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    _drawDashedLine(canvas, paint, Offset.zero, Offset(size.width, 0));
    _drawDashedLine(canvas, paint, Offset(size.width, 0), Offset(size.width, size.height));
    _drawDashedLine(canvas, paint, Offset(size.width, size.height), Offset(0, size.height));
    _drawDashedLine(canvas, paint, Offset(0, size.height), Offset.zero);
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end) {
    final double dx = end.dx - start.dx;
    final double dy = end.dy - start.dy;
    final double length = math.sqrt(dx * dx + dy * dy);
    if (length == 0) return;
    final double ux = dx / length;
    final double uy = dy / length;

    double drawn = 0;
    while (drawn < length) {
      final double segEnd = math.min(drawn + dashWidth, length);
      canvas.drawLine(
        Offset(start.dx + ux * drawn, start.dy + uy * drawn),
        Offset(start.dx + ux * segEnd, start.dy + uy * segEnd),
        paint,
      );
      drawn += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DashedRectPainter oldDelegate) => oldDelegate.color != color;
}