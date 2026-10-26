import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:pickup_table/core/constants/app_constants.dart';
import 'package:pickup_table/domain/entities/pickup_table_theme/pickup_table_theme_colors.dart';
import 'package:pickup_table/domain/entities/pickup_table_theme/pickup_table_theme_selection.dart';
import 'package:pickup_table/presentation/widgets/pickup_table_theme/slot_card_shared.dart';

/// Pickup Table Theme feature's own slot widgets — a translucent
/// guide/highlight background, a dotted (not dashed) guide border, and a
/// real gradient fill+border for the timeout/highlighted card (things
/// [PickupTableThemeColors] structurally can't hold). Shares the same
/// 188×188/40px-radius/stepped-card geometry and the exact same
/// matched-slot rendering as the plain-Color model (via [PlacedSlotPainter],
/// reused directly from slot_card_shared.dart — see [ThemedPlacedSlot]).

// Dot radius/spacing now come from the selected [PickupTableThemeDotStyle]
// (standard = Figma-spec-derived 0.5/3.0, large = 1.5/9.0 for a live A/B
// comparison) — see [_drawDottedPath]'s parameters and
// [ThemedGuideSlot.dotStyle].

// This feature's own corner-tag geometry — bigger than the shared
// 88px/16px (tagSize/tagTextAnchor/16 from slot_card_shared.dart), used uniformly
// across all 3 slot kinds (guide/matched/highlight) — "matched behaves
// like the original theme system" (see ThemedPlacedSlot's own doc
// comment) is about its COLOR handling only, not this geometry. Anchor is
// a bit past the triangle's geometric centroid
// (tagSize/3) — nudged further from the corner (which reads as "up" along
// the diagonal) so the bigger 20px text doesn't sit as low/close to the
// corner as the pure centroid would place it.
const double _tagSize2 = 100.0;
const double _tagTextAnchor2 = _tagSize2 / 3 + 2.0;
const double _fontSize2 = 20.0;
// How far each end of the highlight/timeout FILL divider is trimmed back
// from the card border — line style has no divider at all (nothing to
// trim), fill style's previously went corner-to-corner flush against the
// border on both ends.
const double _dividerEndMargin2 = 14.0;

/// Insets a line segment's two endpoints toward each other by [margin]
/// along its own direction, keeping it centered — used to pull the
/// highlight/timeout FILL divider's ends off the card border (see
/// [_dividerEndMargin2]).
(Offset, Offset) _insetLine(Offset a, Offset b, double margin) {
  final Offset delta = b - a;
  final double length = delta.distance;
  if (length <= margin * 2) return (a, b);
  final Offset unit = delta / length;
  return (a + unit * margin, b - unit * margin);
}

/// Draws evenly-spaced filled circles along [path] — the dotted
/// counterpart to themed_slot_widgets.dart's `_drawDashedPath`. A closed
/// path (the card border) just tiles dots all the way around; an open path
/// (the diagonal divider) centers its dots so both ends land in a gap
/// rather than a dot sitting exactly on the card's own border.
void _drawDottedPath(Canvas canvas, Path path, Color color, {required double radius, required double spacing}) {
  final paint = Paint()
    ..color = color
    ..style = PaintingStyle.fill;
  for (final metric in path.computeMetrics()) {
    final double length = metric.length;
    if (length <= 0) continue;
    final int count = math.max(1, (length / spacing).round());
    final double step = length / count;
    final double start = metric.isClosed ? 0 : step / 2;
    final int dots = metric.isClosed ? count : count;
    for (int i = 0; i < dots; i++) {
      final double distance = start + i * step;
      if (distance > length) break;
      final tangent = metric.getTangentForOffset(distance);
      if (tangent != null) canvas.drawCircle(tangent.position, radius, paint);
    }
  }
}

/// A cup slot with an order assigned but no cup placed yet — same 188×188/
/// 40px-radius/diagonal-divider geometry as [ThemedGuideSlot], but with a
/// DOTTED border/divider (not dashed) and a translucent full-card
/// background wash behind it (both confirmed to apply the same regardless
/// of line/fill style — this design doesn't distinguish them for the guide
/// slot at all).
class ThemedGuideSlot extends StatelessWidget {
  final String orderNo;
  final double width;
  final double height;
  final PickupTableThemeColors colors;
  final List<int> rowWidths;
  final String lang;
  final PickupTableThemeDotStyle dotStyle;

  const ThemedGuideSlot({
    super.key,
    required this.orderNo,
    required this.width,
    required this.height,
    required this.colors,
    this.rowWidths = const [1],
    this.lang = '',
    this.dotStyle = PickupTableThemeDotStyle.standard,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(width, height),
              painter: _ThemeGuideSlotPainter(
                background: colors.guideBackground,
                border: colors.guideBorder,
                rowWidths: rowWidths,
                dotRadius: dotStyle.dotRadius,
                dotSpacing: dotStyle.dotSpacing,
              ),
            ),
            Positioned(
              left: _tagTextAnchor2,
              top: _tagTextAnchor2,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Transform.rotate(
                  angle: -math.pi / 4 + math.pi,
                  child: Text(
                    orderNo,
                    textAlign: TextAlign.center,
                    style: tagTextStyle.copyWith(
                      color: colors.guideBorder,
                      fontFamily: AppConstants.fontFamilyForLanguage(lang),
                      fontSize: _fontSize2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeGuideSlotPainter extends CustomPainter {
  final Color background;
  final Color border;
  final List<int> rowWidths;
  final double dotRadius;
  final double dotSpacing;

  const _ThemeGuideSlotPainter({
    required this.background,
    required this.border,
    this.rowWidths = const [1],
    this.dotRadius = 0.5,
    this.dotSpacing = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = steppedCardPath(size, rowWidths, cornerRadius);

    // Translucent full-card wash — new in this design (the original guide
    // slot is always fully transparent).
    canvas.drawPath(path, Paint()..color = background);

    _drawDottedPath(canvas, path, border, radius: dotRadius, spacing: dotSpacing);
    // Pulled in from the card's own border by _dividerEndMargin2 on both
    // ends — same margin as the highlight/timeout FILL divider, so all of
    // this design's tag-divider lines read consistently instead of only
    // some of them floating clear of the border.
    final (Offset diagonalStart, Offset diagonalEnd) =
        _insetLine(const Offset(_tagSize2, 0), const Offset(0, _tagSize2), _dividerEndMargin2);
    final diagonal = Path()
      ..moveTo(diagonalStart.dx, diagonalStart.dy)
      ..lineTo(diagonalEnd.dx, diagonalEnd.dy);
    _drawDottedPath(canvas, diagonal, border, radius: dotRadius, spacing: dotSpacing);
  }

  @override
  bool shouldRepaint(covariant _ThemeGuideSlotPainter oldDelegate) =>
      oldDelegate.background != background ||
      oldDelegate.dotRadius != dotRadius ||
      oldDelegate.dotSpacing != dotSpacing ||
      oldDelegate.border != border ||
      !listEquals(oldDelegate.rowWidths, rowWidths);
}

/// Which of the 3 same-shaped-but-differently-colored states
/// [ThemedPlacedSlot] is in — a cup is simply on the table ([matched]),
/// it's been there 10+ minutes with no pickup ([timedOut]), or the
/// customer scanned their receipt's pickup QR ([highlighted]).
enum ThemedPlacedEmphasis { matched, timedOut, highlighted }

/// A cup slot with a real cup on the table. All 3 emphasis kinds (matched/
/// timeout/highlighted) now render through the SAME gradient-fill path
/// ([_ThemeHighlightGradientPainter]) — matched's [PickupTableThemeColors.
/// matchedGradient] used to be a single solid [Color] via [PlacedSlotPainter]
/// directly, but is a real gradient now too (unified with timeout/receipt-
/// scan's fill1/fill2 palette editing in FlowHub). [PlacedSlotPainter] is
/// only still reachable via matched's LINE style, which itself has been
/// unreachable from the FlowHub UI since style was fixed to fill (kept, not
/// deleted, per usual — see [PickupTableThemeCubit.selectStyle]'s own doc
/// comment).
class ThemedPlacedSlot extends StatelessWidget {
  final String orderNo;
  final double width;
  final double height;
  final PickupTableThemeColors colors;
  final ThemedPlacedEmphasis emphasis;
  final List<int> rowWidths;
  final PickupTableThemeStyle style;
  final String lang;

  const ThemedPlacedSlot({
    super.key,
    required this.orderNo,
    required this.width,
    required this.height,
    required this.colors,
    this.emphasis = ThemedPlacedEmphasis.matched,
    this.rowWidths = const [1],
    this.style = PickupTableThemeStyle.line,
    this.lang = '',
  });

  @override
  Widget build(BuildContext context) {
    final String fontFamily = AppConstants.fontFamilyForLanguage(lang);
    final bool fill = style == PickupTableThemeStyle.fill;

    // Timeout and receipt-scan used to look identical (same gradient),
    // distinguished only by BlinkingVisibility at the call site — each now
    // has its own gradient; matched has its own too (previously a plain
    // solid Color).
    final Gradient emphasisGradient = switch (emphasis) {
      ThemedPlacedEmphasis.matched => colors.matchedGradient,
      ThemedPlacedEmphasis.highlighted => colors.receiptScanGradient,
      ThemedPlacedEmphasis.timedOut => colors.highlightGradientFill,
    };
    // highlightDividerColor (MAMMOTH/MAGA) only applies to the timeout
    // square, never to matched or receipt-scan.
    final Color? dividerColor =
        emphasis == ThemedPlacedEmphasis.timedOut ? colors.highlightDividerColor : null;

    if (!fill && emphasis == ThemedPlacedEmphasis.matched) {
      // Dead/unreachable via the FlowHub UI (style is fixed to fill) — a
      // representative solid color is good enough here, no need to model
      // a gradient border/tag for a path nothing can ever select.
      final Color lineColor = (emphasisGradient as LinearGradient).colors.first;
      return IgnorePointer(
        child: SizedBox(
          width: width,
          height: height,
          child: CustomPaint(
            size: Size(width, height),
            painter: PlacedSlotPainter(
              border: lineColor,
              tagBg: lineColor,
              orderNo: orderNo,
              rowWidths: rowWidths,
              fill: false,
              fontFamily: fontFamily,
              dividerEndMarginPx: _dividerEndMargin2,
              tagSizePx: _tagSize2,
              textAnchorPx: _tagTextAnchor2,
              fontSizePx: _fontSize2,
            ),
          ),
        ),
      );
    }

    return IgnorePointer(
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(
          size: Size(width, height),
          painter: fill
              ? _ThemeHighlightGradientPainter(
                  gradient: emphasisGradient,
                  orderNo: orderNo,
                  rowWidths: rowWidths,
                  fontFamily: fontFamily,
                  dividerColor: dividerColor,
                )
              : _ThemeHighlightLinePainter(
                  background: colors.highlightBackgroundLine,
                  border: colors.highlightBorderLine,
                  orderNo: orderNo,
                  rowWidths: rowWidths,
                  fontFamily: fontFamily,
                ),
        ),
      ),
    );
  }
}

/// Timeout/highlighted, LINE style — a translucent full-card wash (unlike
/// [PlacedSlotPainter]'s own fully-transparent-except-the-corner-tag line
/// look) underneath the same corner-tag-triangle+border rendering
/// [PlacedSlotPainter] already produces — composed by literally calling
/// its `paint` on the same canvas, not reimplemented.
class _ThemeHighlightLinePainter extends CustomPainter {
  final Color background;
  final Color border;
  final String orderNo;
  final List<int> rowWidths;
  final String? fontFamily;

  const _ThemeHighlightLinePainter({
    required this.background,
    required this.border,
    required this.orderNo,
    this.rowWidths = const [1],
    this.fontFamily,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = steppedCardPath(size, rowWidths, cornerRadius);
    canvas.drawPath(path, Paint()..color = background);
    PlacedSlotPainter(
      border: border,
      tagBg: border,
      orderNo: orderNo,
      rowWidths: rowWidths,
      fontFamily: fontFamily,
      tagSizePx: _tagSize2,
      textAnchorPx: _tagTextAnchor2,
      fontSizePx: _fontSize2,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant _ThemeHighlightLinePainter oldDelegate) =>
      oldDelegate.background != background ||
      oldDelegate.border != border ||
      oldDelegate.orderNo != orderNo ||
      oldDelegate.fontFamily != fontFamily ||
      !listEquals(oldDelegate.rowWidths, rowWidths);
}

/// Timeout/highlighted, FILL style — the whole card filled with
/// [gradient] (used as both the fill shader AND the border stroke
/// shader, per spec), with the same divider-line and order-number
/// knockouts as [PlacedSlotPainter]'s own fill style — see that class's
/// doc comment for the knockout technique itself; this only differs in
/// using a gradient Shader instead of a solid Color for the base fill.
/// [dividerColor], when set (MAMMOTH/MAGA's timeout square only — see
/// [PickupTableThemeColors.highlightDividerColor]), skips that knockout
/// entirely and draws the divider/number directly in this color instead.
class _ThemeHighlightGradientPainter extends CustomPainter {
  final Gradient gradient;
  final String orderNo;
  final List<int> rowWidths;
  final String? fontFamily;
  final Color? dividerColor;

  const _ThemeHighlightGradientPainter({
    required this.gradient,
    required this.orderNo,
    this.rowWidths = const [1],
    this.fontFamily,
    this.dividerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = steppedCardPath(size, rowWidths, cornerRadius);
    final Rect cardRect = Offset.zero & size;

    // Divider between the tag corner and the rest of the card — same
    // hypotenuse as PlacedSlotPainter's own fill style, but at this
    // feature's bigger [_tagSize2] and pulled in [_dividerEndMargin2] from each end
    // (per spec — fill style's divider previously ran corner-to-corner
    // flush against the border on both ends).
    final (Offset dividerStart, Offset dividerEnd) = _insetLine(
      Offset(0, size.height - _tagSize2),
      Offset(_tagSize2, size.height),
      _dividerEndMargin2,
    );

    if (dividerColor != null) {
      // Explicit-color divider/number, no background cutout.
      canvas.drawPath(path, Paint()..shader = gradient.createShader(cardRect));

      canvas.drawLine(
        dividerStart,
        dividerEnd,
        Paint()
          ..color = dividerColor!
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: orderNo,
          style: tagTextStyle.copyWith(color: dividerColor, fontFamily: fontFamily, fontSize: _fontSize2),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.translate(_tagTextAnchor2, size.height - _tagTextAnchor2);
      canvas.rotate(math.pi / 4);
      canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();

      canvas.drawPath(
        path,
        Paint()
          ..shader = gradient.createShader(cardRect)
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth,
      );
      return;
    }

    canvas.save();
    canvas.clipPath(path);

    canvas.saveLayer(cardRect, Paint());
    canvas.drawPath(path, Paint()..shader = gradient.createShader(cardRect));

    final dividerPath = Path()
      ..moveTo(dividerStart.dx, dividerStart.dy)
      ..lineTo(dividerEnd.dx, dividerEnd.dy);
    canvas.saveLayer(cardRect, Paint()..blendMode = BlendMode.dstOut);
    canvas.drawPath(
      dividerPath,
      Paint()
        ..color = const Color(0xFF000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
    canvas.restore();

    final textPainter = TextPainter(
      text: TextSpan(
        text: orderNo,
        style: tagTextStyle.copyWith(
            color: const Color(0xFF000000), fontFamily: fontFamily, fontSize: _fontSize2),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    canvas.saveLayer(cardRect, Paint()..blendMode = BlendMode.dstOut);
    canvas.save();
    canvas.translate(_tagTextAnchor2, size.height - _tagTextAnchor2);
    canvas.rotate(math.pi / 4);
    canvas.translate(-textPainter.width / 2, -textPainter.height / 2);
    textPainter.paint(canvas, Offset.zero);
    canvas.restore();
    canvas.restore();

    canvas.restore(); // composite the (holed) gradient fill onto the card
    canvas.restore(); // undo clip

    canvas.drawPath(
      path,
      Paint()
        ..shader = gradient.createShader(cardRect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant _ThemeHighlightGradientPainter oldDelegate) =>
      oldDelegate.gradient != gradient ||
      oldDelegate.orderNo != orderNo ||
      oldDelegate.fontFamily != fontFamily ||
      oldDelegate.dividerColor != dividerColor ||
      !listEquals(oldDelegate.rowWidths, rowWidths);
}

/// Post-pickup "thank you" card — text only, no border/fill.
class ThemedThankYouSlot extends StatelessWidget {
  final String message;
  final double width;
  final double height;
  final PickupTableThemeColors colors;
  final String lang;

  const ThemedThankYouSlot({
    super.key,
    required this.message,
    required this.width,
    required this.height,
    required this.colors,
    this.lang = '',
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.thankYouColor,
                fontFamily: AppConstants.fontFamilyForLanguage(lang),
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
