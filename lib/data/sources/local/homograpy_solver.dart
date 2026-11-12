import 'dart:math';
import 'dart:ui';
import 'package:ml_linalg/matrix.dart';
import 'package:ml_linalg/dtype.dart';
import 'package:ml_linalg/vector.dart';
import 'coordinate_transformer.dart';

class HomographySolver {
  /// 9개의 점을 바탕으로 3x3 호모그래피 행렬(9개 계수)을 산출합니다.
  /// [cx]/[cy]를 지정하면 그 중심점 기준으로, 생략하면 현재
  /// CoordinateTransformer.opticalCenterX/Y 기준으로 바닥 투영 후 피팅함.
  static List<double> solve(
    List<Point<double>> src,
    List<double> zs,
    List<Point<double>> dst, {
    double? cx,
    double? cy,
  }) {
    List<List<double>> aRows = [];
    List<double> bValues = [];

    for (int i = 0; i < src.length; i++) {
      // 1. 입력 좌표를 먼저 물리적 '바닥면' 좌표로 변환 (중요!)
      Offset floor = (cx != null && cy != null)
          ? CoordinateTransformer.floorProjectedOffsetWithCenter(src[i].x, src[i].y, zs[i], cx, cy)
          : CoordinateTransformer.getFloorProjectedOffset(src[i].x, src[i].y, zs[i]);
      double x = floor.dx;
      double y = floor.dy;
      double u = dst[i].x;
      double v = dst[i].y;

      // 2. 호모그래피 방정식을 위한 행렬 구성 (u = (h0x + h1y + h2) / (h6x + h7y + 1))
      // Row 1: x, y, 1, 0, 0, 0, -ux, -uy
      aRows.add([x, y, 1.0, 0.0, 0.0, 0.0, -u * x, -u * y]);
      bValues.add(u);

      // Row 2: 0, 0, 0, x, y, 1, -vx, -vy
      aRows.add([0.0, 0.0, 0.0, x, y, 1.0, -v * x, -v * y]);
      bValues.add(v);
    }

    final A = Matrix.fromList(aRows, dtype: DType.float64);
    final B = Vector.fromList(bValues, dtype: DType.float64);

    // 최소자승법: (At * A)^-1 * At * B
    final At = A.transpose();
    final AtA = At * A;
    final AtA_inv = AtA.inverse();
    final sol = AtA_inv * At * Matrix.fromColumns([B], dtype: DType.float64);

    List<double> res = sol.getColumn(0).toList();
    res.add(1.0); // h8 값은 1.0으로 고정

    return res; // [h0, h1, h2, h3, h4, h5, h6, h7, h8]
  }

  /// 주어진 중심점(cx,cy)과 호모그래피로, 9개 보정점 전체의 재투영
  /// 오차(제곱합)를 계산 - solveWithOptimalCenter()가 후보 중심점들을
  /// 비교하는 기준.
  static double _reprojectionError(
    List<Point<double>> src,
    List<double> zs,
    List<Point<double>> dst,
    double cx,
    double cy,
    List<double> h,
  ) {
    double totalSqErr = 0.0;
    for (int i = 0; i < src.length; i++) {
      final floor = CoordinateTransformer.floorProjectedOffsetWithCenter(src[i].x, src[i].y, zs[i], cx, cy);
      double denom = h[6] * floor.dx + h[7] * floor.dy + h[8];
      if (denom == 0) denom = 1.0;
      final ux = (h[0] * floor.dx + h[1] * floor.dy + h[2]) / denom;
      final uy = (h[3] * floor.dx + h[4] * floor.dy + h[5]) / denom;
      final edx = ux - dst[i].x;
      final edy = uy - dst[i].y;
      totalSqErr += edx * edx + edy * edy;
    }
    return totalSqErr;
  }

  /// [카메라 광학 중심점 자동 탐색]
  /// (320,240)은 센서 해상도의 기하학적 중심일 뿐, 카메라가 실제로 수직
  /// 아래를 내려다보는 지점(렌즈 설치 오차 포함)과 다를 수 있음 - 이 오차는
  /// 캘리브레이션에 쓴 물체와 "같은 높이(z) 비율"을 쓰는 물체에 대해서는
  /// 호모그래피 피팅 과정에서 자동으로 흡수되어 드러나지 않지만, 전혀 다른
  /// 높이(예: 실측 불가능한 아이스컵의 가정 높이)를 쓰는 물체에는 그
  /// 차이만큼 보정되지 않은 오차로 남아 가장자리일수록 크게 드러남
  /// (9점 캘리브레이션에서 확인된 증상: 끝 칸에 둔 아이스컵이 한 칸씩
  /// 안쪽/바깥쪽으로 밀려 보임).
  ///
  /// 중심점을 320,240으로 고정하는 대신, 9개 보정점 자체의 재투영 오차가
  /// 최소가 되는 (cx,cy)를 격자 탐색으로 찾아낸다 - 매장별로 실측할 필요
  /// 없이 캘리브레이션 한 번으로 그 설치 환경의 실제 광학 중심을 추정.
  static ({double cx, double cy, List<double> matrix}) solveWithOptimalCenter(
    List<Point<double>> src,
    List<double> zs,
    List<Point<double>> dst,
  ) {
    double bestCx = CoordinateTransformer.opticalCenterX;
    double bestCy = CoordinateTransformer.opticalCenterY;
    List<double> bestMatrix = solve(src, zs, dst, cx: bestCx, cy: bestCy);
    double bestErr = _reprojectionError(src, zs, dst, bestCx, bestCy, bestMatrix);

    // 1단계: 넓은 범위(기본 가정 중심점 ±80px)를 4px 간격으로 성긴 탐색
    double searchCenterX = CoordinateTransformer.opticalCenterX;
    double searchCenterY = CoordinateTransformer.opticalCenterY;
    for (final step in [4.0, 1.0, 0.25]) {
      final range = step == 4.0 ? 80.0 : (step == 1.0 ? 6.0 : 1.5);
      double roundCx = bestCx, roundCy = bestCy, roundErr = bestErr;
      for (double cx = searchCenterX - range; cx <= searchCenterX + range; cx += step) {
        for (double cy = searchCenterY - range; cy <= searchCenterY + range; cy += step) {
          final h = solve(src, zs, dst, cx: cx, cy: cy);
          final err = _reprojectionError(src, zs, dst, cx, cy, h);
          if (err < roundErr) {
            roundErr = err;
            roundCx = cx;
            roundCy = cy;
          }
        }
      }
      bestCx = roundCx;
      bestCy = roundCy;
      bestErr = roundErr;
      searchCenterX = bestCx; // 다음(더 촘촘한) 라운드는 이번 라운드 최적점 주변만 탐색
      searchCenterY = bestCy;
    }

    bestMatrix = solve(src, zs, dst, cx: bestCx, cy: bestCy);
    return (cx: bestCx, cy: bestCy, matrix: bestMatrix);
  }
}