import 'dart:math';
import 'dart:ui';
import 'package:ml_linalg/matrix.dart';
import 'package:ml_linalg/dtype.dart';
import 'package:ml_linalg/vector.dart';
import 'coordinate_transformer.dart';

class HomographySolver {
  /// 9개의 점을 바탕으로 3x3 호모그래피 행렬(9개 계수)을 산출합니다.
  /// Projects onto the floor around [cx]/[cy] when given, otherwise around the
  /// current CoordinateTransformer.opticalCenterX/Y, then fits.
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

  /// Sum of squared reprojection errors of all 9 calibration points for the
  /// given center (cx, cy) and homography.
  /// The score solveWithOptimalCenter() compares candidate centers by.
  /// 1. Project each source point onto the floor around (cx, cy)
  /// 2. Map it through the homography [h]
  /// 3. Add the squared distance to its destination point
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

  /// [Automatic camera optical-center search]
  /// (320,240) is only the geometric center of the sensor resolution and can
  /// differ from the point the camera actually looks straight down at (lens
  /// mounting error included). For objects with the same height (z) ratio as
  /// the calibration objects, the homography fit absorbs this error and it
  /// never shows. For objects of a very different height (e.g. the assumed
  /// height of an ice cup, which can't be measured) it stays as uncorrected
  /// error that grows toward the edges (symptom seen in 9-point calibration:
  /// an ice cup in an edge cell appears shifted one cell inward/outward).
  ///
  /// Instead of fixing the center at 320,240, this grid-searches for the
  /// (cx, cy) that minimizes the reprojection error of the 9 calibration
  /// points themselves, estimating the install's real optical center from a
  /// single calibration with no per-store measurement.
  /// 1. Start from the current center and its fitted matrix
  /// 2. Coarse search: ±80px around it in 4px steps
  /// 3. Refine around the best point: ±6px in 1px, then ±1.5px in 0.25px steps
  /// 4. Refit the matrix at the best center and return both
  static ({double cx, double cy, List<double> matrix}) solveWithOptimalCenter(
    List<Point<double>> src,
    List<double> zs,
    List<Point<double>> dst,
  ) {
    double bestCx = CoordinateTransformer.opticalCenterX;
    double bestCy = CoordinateTransformer.opticalCenterY;
    List<double> bestMatrix = solve(src, zs, dst, cx: bestCx, cy: bestCy);
    double bestErr = _reprojectionError(src, zs, dst, bestCx, bestCy, bestMatrix);

    // Round 1: coarse search over a wide range (assumed center ±80px) in 4px steps
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
      searchCenterX = bestCx; // The next (finer) round searches only around this round's best point
      searchCenterY = bestCy;
    }

    bestMatrix = solve(src, zs, dst, cx: bestCx, cy: bestCy);
    return (cx: bestCx, cy: bestCy, matrix: bestMatrix);
  }
}