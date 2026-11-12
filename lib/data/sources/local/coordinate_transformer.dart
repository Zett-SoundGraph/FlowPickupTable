import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:pickup_table/core/constants/app_constants.dart';

class CoordinateTransformer {
  // [굴절/투영 상수] ToF 센서의 초점 거리 (수직 Z 계산을 위한 상수)
  // 센서 해상도(640x480)의 기하학적 중심일 뿐, 카메라가 실제로 수직으로
  // 내려다보는 광학 중심(렌즈 설치 오차/틀어짐 포함)과 정확히 일치한다는
  // 보장은 없음 - 9점 캘리브레이션 시 HomographySolver.solveWithOptimalCenter()가
  // 이 값들을 실측 기반으로 덮어씀 (setOpticalCenter 참고). 캘리브레이션 전이나
  // 리셋 직후엔 이 기본값으로 동작.
  static const double _defaultOpticalCenterX = 320.0;
  static const double _defaultOpticalCenterY = 240.0;
  static double opticalCenterX = _defaultOpticalCenterX;
  static double opticalCenterY = _defaultOpticalCenterY;
  static const double _fx = 620.0;
  static const double _fy = 620.0;

  // [9점 캘리브레이션 행렬] 초기값: 단순 3배 스케일링
  static List<double> _h = [3.0, 0.0, 0.0, 0.0, 2.25, 0.0, 0.0, 0.0, 1.0];

  // 모드 플래그
  static bool isCalibrationMode = false;

  static void resetMatrix() {
    _h = [3.0, 0.0, 0.0, 0.0, 2.25, 0.0, 0.0, 0.0, 1.0];
    opticalCenterX = _defaultOpticalCenterX;
    opticalCenterY = _defaultOpticalCenterY;
  }

  static void setHomographyMatrix(List<double> matrix) {
    _h = matrix;
    debugPrint("🚨 [MATRIX_UPDATED] Homography Matrix Applied.");
  }

  /// 9점 캘리브레이션에서 실측 기반으로 찾아낸 "진짜" 광학 중심으로 교체.
  /// solveWithOptimalCenter()의 결과와 함께, 캘리브레이션 완료 시 한 번 호출됨.
  static void setOpticalCenter(double cx, double cy) {
    opticalCenterX = cx;
    opticalCenterY = cy;
    debugPrint("🚨 [OPTICAL_CENTER_UPDATED] cx=$cx cy=$cy (was $_defaultOpticalCenterX,$_defaultOpticalCenterY)");
  }

  /// [핵심 1: 시차 보정 (Parallax Correction)]
  /// 직선 거리를 수직 거리로 변환하고 바닥면(Floor)으로 투영합니다.
  static Offset getFloorProjectedOffset(double rawX, double rawY, double zRaw) =>
      floorProjectedOffsetWithCenter(rawX, rawY, zRaw, opticalCenterX, opticalCenterY);

  /// getFloorProjectedOffset()과 동일한 계산이지만, 중심점(cx,cy)을 직접
  /// 지정할 수 있는 버전 - HomographySolver.solveWithOptimalCenter()가 여러
  /// 후보 중심점에 대해 재투영 오차를 비교할 때 전역 상태(opticalCenterX/Y)를
  /// 건드리지 않고 테스트해보기 위해 필요함.
  static Offset floorProjectedOffsetWithCenter(
      double rawX, double rawY, double zRaw, double cx, double cy) {
    // 1. 중심 기준 상대 좌표
    double dx = rawX - cx;
    double dy = rawY - cy;

    // 2. 수직 거리(Z-Depth) 계산 (굴절 상수 이용)
    double projectionFactor = math.sqrt(1 + math.pow(dx / _fx, 2) + math.pow(dy / _fy, 2));
    double zVert = zRaw / projectionFactor;

    // 3. 시차 보정 비율 계산 (천장높이 / 수직거리)
    double H = AppConstants.totalSensorHeight;
    double ratio = zVert / H;

    // 4. 바닥면 투영 좌표 반환
    return Offset(
      cx + (dx * ratio),
      cy + (dy * ratio),
    );
  }

  /// [핵심 2: 9점 캘리브레이션 변환 (Homography)]
  /// 보정된 바닥 좌표를 최종 UI 디스플레이 좌표로 변환합니다.
  static Offset transform(double rawX, double rawY, double zValue) {
    // 1단계: 시차 보정 적용
    Offset floorPos = getFloorProjectedOffset(rawX, rawY, zValue);

    double x = floorPos.dx;
    double y = floorPos.dy;

    // 2단계: 호모그래피 투영 변환 연산
    double denominator = _h[6] * x + _h[7] * y + _h[8];
    if (denominator == 0) denominator = 1.0;

    double ux = (_h[0] * x + _h[1] * y + _h[2]) / denominator;
    double uy = (_h[3] * x + _h[4] * y + _h[5]) / denominator;

    return Offset(ux, uy);
  }

  /// [핵심 3: 수직 거리 보정 (Corrected Z)]
  /// 렌즈 왜곡이 제거된 순수 수직 거리를 반환합니다.
  static double getCorrectedZ(double rawX, double rawY, double zRaw) {
    double dx = rawX - opticalCenterX;
    double dy = rawY - opticalCenterY;
    double projectionFactor = math.sqrt(1 + math.pow(dx / _fx, 2) + math.pow(dy / _fy, 2));
    return zRaw / projectionFactor;
  }

  // UI 크기 변환 헬퍼
  static Size getUiSize(double rawWidth, double rawHeight) => Size(rawWidth * 3.0, rawHeight * 3.0);
  static double getUiDiameter(double rawDiameter) => rawDiameter * 3.0;

  static void logTrace(String label, double rawX, double rawY, double zValue) {
    Offset floor = getFloorProjectedOffset(rawX, rawY, zValue);
    Offset finalPos = transform(rawX, rawY, zValue);

    debugPrint("""
[TRACE] 🔍 [$label]
   - Raw Input : (${rawX.toInt()}, ${rawY.toInt()}) Z: ${zValue.toInt()}
   - Floor Proj: (${floor.dx.toInt()}, ${floor.dy.toInt()}) [Parallax Applied]
   - UI Final  : (${finalPos.dx.toInt()}, ${finalPos.dy.toInt()}) [Homography Applied]
    """);
  }
}