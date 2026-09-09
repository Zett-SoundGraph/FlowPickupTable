import 'dart:math';
import 'dart:ui';

import 'package:injectable/injectable.dart';

import 'package:pickup_table/data/sources/local/coordinate_transformer.dart';
import 'package:pickup_table/data/sources/local/homograpy_solver.dart';
import 'package:pickup_table/domain/repositories/coordinate_repository.dart';

@Singleton(as: CoordinateRepository)
class CoordinateRepositoryImpl implements CoordinateRepository {
  @override
  Offset transform(double rawX, double rawY, double zValue) =>
      CoordinateTransformer.transform(rawX, rawY, zValue);

  @override
  Offset getFloorProjectedOffset(double rawX, double rawY, double zRaw) =>
      CoordinateTransformer.getFloorProjectedOffset(rawX, rawY, zRaw);

  @override
  double getCorrectedZ(double rawX, double rawY, double zRaw) =>
      CoordinateTransformer.getCorrectedZ(rawX, rawY, zRaw);

  @override
  double getUiDiameter(double rawDiameter) => CoordinateTransformer.getUiDiameter(rawDiameter);

  @override
  Size getUiSize(double rawWidth, double rawHeight) =>
      CoordinateTransformer.getUiSize(rawWidth, rawHeight);

  @override
  void setHomographyMatrix(List<double> matrix) =>
      CoordinateTransformer.setHomographyMatrix(matrix);

  @override
  void resetMatrix() => CoordinateTransformer.resetMatrix();

  @override
  void logTrace(String label, double rawX, double rawY, double zValue) =>
      CoordinateTransformer.logTrace(label, rawX, rawY, zValue);

  @override
  bool get isCalibrationMode => CoordinateTransformer.isCalibrationMode;

  @override
  set isCalibrationMode(bool value) => CoordinateTransformer.isCalibrationMode = value;

  @override
  List<double> solveHomography(
    List<Point<double>> src,
    List<double> zs,
    List<Point<double>> dst,
  ) =>
      HomographySolver.solve(src, zs, dst);
}
