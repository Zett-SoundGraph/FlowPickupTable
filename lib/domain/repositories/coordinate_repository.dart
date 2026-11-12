import 'dart:math';
import 'dart:ui';

/// Thin interface over the ToF sensor's coordinate math (parallax
/// correction + 9-point homography calibration) — the actual math lives
/// unchanged in data/sources/local/coordinate_transformer.dart and
/// homograpy_solver.dart; this just gives the presentation layer a
/// mockable seam instead of calling those statics directly.
abstract interface class CoordinateRepository {
  Offset transform(double rawX, double rawY, double zValue);

  Offset getFloorProjectedOffset(double rawX, double rawY, double zRaw);

  double getCorrectedZ(double rawX, double rawY, double zRaw);

  double getUiDiameter(double rawDiameter);

  Size getUiSize(double rawWidth, double rawHeight);

  void setHomographyMatrix(List<double> matrix);

  /// Replaces the optical center with the real one the 9-point calibration
  /// found. Called together with the result of
  /// solveHomographyWithOptimalCenter() (the default is the sensor
  /// resolution's geometric center, 320,240).
  void setOpticalCenter(double cx, double cy);

  void resetMatrix();

  void logTrace(String label, double rawX, double rawY, double zValue);

  bool get isCalibrationMode;

  set isCalibrationMode(bool value);

  /// Solves the 3x3 homography matrix (9 coefficients) for the given
  /// calibration point correspondences.
  List<double> solveHomography(
    List<Point<double>> src,
    List<double> zs,
    List<Point<double>> dst,
  );

  /// Same calibration-point correspondences as [solveHomography], but also
  /// searches for the (cx, cy) optical center that minimizes the 9 points'
  /// own reprojection error, instead of assuming it's exactly the sensor's
  /// geometric center (320, 240). Apply the result with [setOpticalCenter]
  /// before [setHomographyMatrix].
  ({double cx, double cy, List<double> matrix}) solveHomographyWithOptimalCenter(
    List<Point<double>> src,
    List<double> zs,
    List<Point<double>> dst,
  );
}
