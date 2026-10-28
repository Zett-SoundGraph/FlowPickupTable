import 'package:flutter/material.dart';

/// The fixed 9×5 grid of 188×188 themed-square cells that exactly tiles a
/// 1920×1080 screen with the given margins/gaps:
///   left margin 58, right margin 58, gap 14 → 58 + 9×188 + 8×14 + 58 = 1920
///   top margin 36, bottom margin 48, gap 14 → 36 + 5×188 + 4×14 + 48 = 1080
///
/// This IS the live positioning system once a theme is active — guide/
/// matched/timed-out/thank-you squares render at these fixed cell
/// coordinates (see PickupTableCubit.buildGridOrderGroups), not the
/// original circle-based widgets' continuous camera-derived positions
/// (guidePositions/buildOrderGroups, still used only when no theme is
/// set). The camera's role under a theme is reduced to a per-cell
/// validity check — see [nearestCellIndex].
class PickupTableGridLayout {
  const PickupTableGridLayout._();

  static const int columns = 9;
  static const int rows = 5;
  static const double cellSize = 188.0;
  static const double gap = 14.0;
  static const double leftMargin = 58.0;
  static const double rightMargin = 58.0;
  static const double topMargin = 36.0;
  static const double bottomMargin = 48.0;

  static const double screenWidth = 1920.0;
  static const double screenHeight = 1080.0;

  static const int totalCells = rows * columns;

  /// The on-screen rect for grid cell (row, col), both 0-indexed —
  /// row 0/col 0 is the top-left cell.
  static Rect cellRect(int row, int col) {
    assert(row >= 0 && row < rows, 'row out of range: $row');
    assert(col >= 0 && col < columns, 'col out of range: $col');
    final double left = leftMargin + col * (cellSize + gap);
    final double top = topMargin + row * (cellSize + gap);
    return Rect.fromLTWH(left, top, cellSize, cellSize);
  }

  /// Same as [cellRect], addressed by a single row-major index
  /// (0..[totalCells)) instead of (row, col) — the indexing scheme
  /// [PickupTableCubit]'s grid-cell allocator uses internally.
  static Rect cellRectByIndex(int index) => cellRect(index ~/ columns, index % columns);

  /// Which cell [point] belongs to, by nearest cell CENTER — not strict
  /// rect containment. A detected cup's center rarely lands exactly
  /// inside a cell's own 188×188 square (camera calibration has a few
  /// centimeters of slack, and any point that drifts into the 14px
  /// gap/margin between cells would fall inside NO cell's rect at all,
  /// which is exactly what made every guide→matched transition silently
  /// never fire — see PickupTableCubit._updateGridOccupancy's own doc
  /// comment). Snapping to the nearest center instead means every point
  /// on screen resolves to exactly one cell, so this always returns a
  /// valid index.
  static int nearestCellIndex(Offset point) {
    int best = 0;
    double bestDistanceSquared = double.infinity;
    for (int i = 0; i < totalCells; i++) {
      final double d = (point - cellRect(i ~/ columns, i % columns).center).distanceSquared;
      if (d < bestDistanceSquared) {
        bestDistanceSquared = d;
        best = i;
      }
    }
    return best;
  }
}
