import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Shared low-level geometry/painting primitives for the Pickup Table
/// Theme feature's square-card slot widgets (themed_slot_widgets.dart) —
/// factored out here because [PlacedSlotPainter] and [steppedCardPath] are
/// reused as-is by that file rather than being reimplemented.
const double cornerRadius = 40.0;
const double borderWidth = 1.0;
const double tagSize = 88.0;
// Anchoring the tag text at the diagonal's own midpoint centers it ON the
// diagonal line itself — half the glyph ends up outside the triangle,
// where it's invisible against a differently-colored area (page
// background for the dashed guide tag, or simply the wrong side of a
// filled tag's own contrasting text color). Anchoring at the right-
// triangle's centroid (average of its 3 vertices, here (0,0)/(tagSize,0)/
// (0,tagSize) or the corner-mirrored equivalent) instead keeps the whole
// label solidly inside the shaded/bordered area.
const double tagTextAnchor = tagSize / 3;

const TextStyle tagTextStyle = TextStyle(
  fontSize: 16,
  height: 1.0,
  fontWeight: FontWeight.w700,
  letterSpacing: -0.16,
);

/// Builds the outer boundary for a multi-cell order group — a genuine
/// stepped/L-shaped outline (see test_base_light.png's 5-cell example),
/// NOT a rounded rect covering the group's full bounding box. [rowWidths]
/// lists each row's cell-count top-to-bottom (e.g. `[2, 3]` for a 5-cell
/// card: a narrower 2-wide row on top, a wider 3-wide row below) — the
/// shape [PickupTableCubit._allocateGridCells] always produces is
/// left-aligned and weakly widens going down, so only 3 corner-rounding
/// cases are ever needed: the very top-left/top-right corners, a
/// convex corner wherever a row is wider than the row above it, and the
/// very bottom-left/bottom-right corners — every other corner sits on an
/// internal seam between two rows and disappears once the per-row rects
/// are unioned, so leaving it sharp is harmless regardless of what the
/// image actually looks like at that point.
Path steppedCardPath(Size size, List<int> rowWidths, double radius) {
  if (rowWidths.length <= 1) {
    return Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
  }

  final int maxWidth = rowWidths.reduce(math.max);
  final double rowHeight = size.height / rowWidths.length;
  Path result = Path();

  for (int r = 0; r < rowWidths.length; r++) {
    final double rowWidthPx = size.width * rowWidths[r] / maxWidth;
    final Rect rowRect = Rect.fromLTWH(0, r * rowHeight, rowWidthPx, rowHeight);
    final bool roundTop = r == 0;
    final bool roundTopRight = r == 0 || rowWidths[r] > rowWidths[r - 1];
    final bool roundBottom = r == rowWidths.length - 1;

    final rrect = RRect.fromRectAndCorners(
      rowRect,
      topLeft: roundTop ? Radius.circular(radius) : Radius.zero,
      topRight: roundTopRight ? Radius.circular(radius) : Radius.zero,
      bottomLeft: roundBottom ? Radius.circular(radius) : Radius.zero,
      bottomRight: roundBottom ? Radius.circular(radius) : Radius.zero,
    );
    result = Path.combine(PathOperation.union, result, Path()..addRRect(rrect));
  }

  // The one corner this function's own doc comment used to call "harmless
  // to leave sharp" — the concave/reflex notch where a narrower row meets
  // a wider row below it (e.g. the 2-wide-over-3-wide 5-cell card) — now
  // gets rounded too, radius [reflexRadius] (48 — deliberately different
  // from the convex corners' own [radius], 40). Unlike every OTHER corner
  // here (a true circular arc via RRect), this one uses a quadratic Bézier
  // whose control point sits ON the original sharp vertex itself: curve
  // from (x, y-radius) to (x+radius, y) with control point (x, y). A true
  // arc of this radius bulges all the way out to a uniform distance
  // [reflexRadius] from the corner in every direction, which read on-
  // device as an obvious round "bump" rather than a corner easing; a
  // Bézier control point pinned at the corner instead pulls the curve
  // in noticeably closer to the corner than that (its middle sits at
  // ~0.35×radius from the corner vs. an arc's uniform 1.0×radius), which
  // is what actually reads as a gentle concave fillet instead of a bump.
  // Both of the sliver's own straight edges still coincide with edges
  // that already existed (row (r-1)'s own right edge, row r's own top
  // edge), so — same as the arc version — this reads as one continuous
  // curve rather than introducing a new, unrelated straight segment.
  const double reflexRadius = 48.0;
  for (int r = 1; r < rowWidths.length; r++) {
    if (rowWidths[r] > rowWidths[r - 1]) {
      final double x = size.width * rowWidths[r - 1] / maxWidth;
      final double y = r * rowHeight;
      final Path fillet = Path()
        ..moveTo(x, y - reflexRadius)
        ..quadraticBezierTo(x, y, x + reflexRadius, y)
        ..lineTo(x, y)
        ..close();
      result = Path.combine(PathOperation.union, result, fillet);
    }
  }

  return result;
}

/// A cup slot with a real cup on the table — 188×188, 40px-radius solid
/// border, with a diagonal corner-tag triangle in the bottom-left. [fill]
/// decides how much of the card past that corner tag is filled — line
/// style leaves the rest of the card fully transparent; fill style fills
/// the entire card the same color, with a knocked-out divider line marking
/// where the corner tag ends.
///
/// The order number itself is a cutout, not a drawn label — the fill area
/// is filled solid, then the number is erased back out of that fill (via a
/// nested saveLayer composited with BlendMode.dstOut — the standard Skia
/// "knockout text" technique), so whatever sits behind this whole card —
/// the actual page background — shows through in exactly the shape of the
/// digits.
///
/// BlendMode.dstOut, not BlendMode.clear — clear's Porter-Duff formula
/// zeroes the destination unconditionally across the WHOLE composited
/// layer region regardless of the source's own per-pixel alpha, wiping
/// out the entire fill instead of just the text-/divider-shaped part of it
/// (this is exactly what briefly shipped and made the whole tag vanish).
/// dstOut's formula (`Cd × (1 − Sa)`) only clears where the source (the
/// text/divider) actually has alpha, leaving every other pixel of the fill
/// untouched.
class PlacedSlotPainter extends CustomPainter {
  final Color border;
  final Color tagBg;
  final String orderNo;
  final List<int> rowWidths;
  final bool fill;
  final String? fontFamily;
  // Overridable geometry — default to the original base/theme01-04 look
  // exactly (so every existing caller that doesn't pass these keeps
  // rendering identically); the Pickup Table Theme feature's bigger corner
  // tag + 20px order-number text (see themed_slot_widgets.dart) passes
  // larger values here instead of reimplementing this whole painter.
  final double tagSizePx;
  final double textAnchorPx;
  final double fontSizePx;
  // How far each end of the FILL-style divider is trimmed back from the
  // card border — 0 (default) keeps every existing caller's exact prior
  // look (corner-to-corner, flush against the border on both ends).
  final double dividerEndMarginPx;

  const PlacedSlotPainter({
    required this.border,
    required this.tagBg,
    required this.orderNo,
    this.rowWidths = const [1],
    this.fill = false,
    this.fontFamily,
    this.tagSizePx = tagSize,
    this.textAnchorPx = tagTextAnchor,
    this.fontSizePx = 16,
    this.dividerEndMarginPx = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = steppedCardPath(size, rowWidths, cornerRadius);
    final Rect cardRect = Offset.zero & size;

    canvas.save();
    canvas.clipPath(path);

    // The bottom-left cell always exists (every row this shape produces is
    // left-aligned, and the last row is never narrower than 1 cell), so the
    // tag triangle's fixed (0,height-tagSizePx)/(0,height)/(tagSizePx,height)
    // coordinates (and the divider's matching hypotenuse) stay correct
    // regardless of the overall group's row widths.
    final trianglePath = Path()
      ..moveTo(0, size.height - tagSizePx)
      ..lineTo(0, size.height)
      ..lineTo(tagSizePx, size.height)
      ..close();

    // Outer layer: the solid fill (tag-only in line style, whole card in
    // fill style) that the number (and, in fill style, the divider) get
    // knocked out of.
    canvas.saveLayer(cardRect, Paint());
    canvas.drawPath(fill ? path : trianglePath, Paint()..color = tagBg);

    if (fill) {
      // Divider between the tag corner and the rest of the now-uniformly-
      // filled card — see this class's own doc comment for why this only
      // exists in fill style. Pulled in from the border by
      // dividerEndMarginPx on both ends (0 = flush, the original look).
      Offset dividerA = Offset(0, size.height - tagSizePx);
      Offset dividerB = Offset(tagSizePx, size.height);
      if (dividerEndMarginPx > 0) {
        final Offset delta = dividerB - dividerA;
        final double length = delta.distance;
        if (length > dividerEndMarginPx * 2) {
          final Offset unit = delta / length;
          dividerA += unit * dividerEndMarginPx;
          dividerB -= unit * dividerEndMarginPx;
        }
      }
      final dividerPath = Path()
        ..moveTo(dividerA.dx, dividerA.dy)
        ..lineTo(dividerB.dx, dividerB.dy);
      canvas.saveLayer(cardRect, Paint()..blendMode = BlendMode.dstOut);
      canvas.drawPath(
        dividerPath,
        Paint()
          ..color = const Color(0xFF000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth,
      );
      canvas.restore();
    }

    // Inner layer, composited with BlendMode.dstOut: wherever the text is
    // drawn here (and only there — everywhere else this layer is fully
    // transparent, so dstOut leaves the fill beneath it untouched), the
    // outer layer's pixels get erased to fully transparent when this inner
    // layer is composited onto it below — the text's own color is
    // irrelevant (dstOut only reads source ALPHA, not color), so any
    // opaque color works.
    final textPainter = TextPainter(
      text: TextSpan(
        text: orderNo,
        style: tagTextStyle.copyWith(
            color: const Color(0xFF000000), fontFamily: fontFamily, fontSize: fontSizePx),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.saveLayer(cardRect, Paint()..blendMode = BlendMode.dstOut);
    canvas.save();
    // Pin the text's own center at the tag's anchor point, then rotate
    // about that point.
    canvas.translate(textAnchorPx, size.height - textAnchorPx);
    canvas.rotate(math.pi / 4);
    canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
    canvas.restore(); // composites the dstOut-layer onto the fill, punching the hole

    canvas.restore(); // composites the (now-holed) fill onto the card normally

    canvas.restore(); // undo clip

    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant PlacedSlotPainter oldDelegate) =>
      oldDelegate.border != border ||
      oldDelegate.tagBg != tagBg ||
      oldDelegate.orderNo != orderNo ||
      oldDelegate.fill != fill ||
      oldDelegate.fontFamily != fontFamily ||
      oldDelegate.tagSizePx != tagSizePx ||
      oldDelegate.textAnchorPx != textAnchorPx ||
      oldDelegate.fontSizePx != fontSizePx ||
      oldDelegate.dividerEndMarginPx != dividerEndMarginPx ||
      !listEquals(oldDelegate.rowWidths, rowWidths);
}
