import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

final RegExp _digit = RegExp(r'^[0-9]$');

class ArcTextPainter extends CustomPainter {
  final String text;
  final double radius;
  final double startAngle;
  final TextStyle style;
  final TextStyle pipeStyle;
  final TextStyle numberStyle;
  /// Optional background pill behind an icon+count group (e.g. "☕1"). Both
  /// guideCircle and baseCircle turned out to want no chip here at all —
  /// just the icon tinted to [numberStyle]'s color — so this defaults to
  /// null (no badge drawn) and is only opt-in for a future caller that does
  /// want one.
  final Color? badgeColor;
  /// Optional background pill behind the "name" segment — the text after
  /// the last '|' by default, or (if [nameLeadingLength] is set) exactly
  /// the first [nameLeadingLength] characters instead, regardless of any
  /// '|' in the string. Used by baseCircle's order-number chip; guideCircle
  /// leaves this null (no chip behind its order number).
  final Color? nameBadgeColor;
  /// When set, the "name" segment is exactly the first N characters of
  /// [text] (baseCircle has no '|' in its label at all, so it can't be
  /// found by scanning — the caller already knows the boundary since it
  /// built the string from separate name/icon parts). Leave null to fall
  /// back to the '|'-scanning default above.
  final int? nameLeadingLength;
  /// Extra gap (px, converted to an arc-length angle at paint time) inserted
  /// right after the name segment, before whatever follows it. Only takes
  /// effect when [nameLeadingLength] is set — text laid out via the '|'
  /// scanning fallback keeps its literal characters (e.g. the " | "
  /// separator) as the only spacing between segments.
  final double nameIconGapPx;
  /// Extra gap (px) inserted right after each icon glyph, before its
  /// trailing count digit(s) (e.g. the space between "☕" and "1").
  final double iconCountGapPx;
  final Map<String, ui.Image> icons;

  ArcTextPainter({
    required this.text,
    required this.radius,
    required this.startAngle,
    required this.style,
    TextStyle? pipeStyle,
    TextStyle? numberStyle,
    this.badgeColor,
    this.nameBadgeColor,
    this.nameLeadingLength,
    this.nameIconGapPx = 0,
    this.iconCountGapPx = 0,
    required this.icons,
  }) : pipeStyle = pipeStyle ?? style,
       numberStyle = numberStyle ?? style;

  /// Computes the [startAngle] needed so that the "name" segment ends up
  /// centered exactly at [targetAngle] — the icon+count part (if any)
  /// trails off to whichever side the extra angular width naturally falls
  /// on. Used by baseCircle, which needs the order number centered at 6
  /// o'clock specifically (not the whole string).
  static double startAngleForNameCenteredAt({
    required String text,
    required double targetAngle,
    required double radius,
    required TextStyle style,
    TextStyle? pipeStyle,
    int? nameLeadingLength,
    required Map<String, ui.Image> icons,
  }) {
    final effectivePipeStyle = pipeStyle ?? style;
    const double iconSize = 16.0;
    final chars = text.characters.toList();

    double angleFor(String ch) {
      if (icons[ch] != null) return iconSize / radius;
      final tp = TextPainter(
        text: TextSpan(text: ch, style: ch == '|' ? effectivePipeStyle : style),
        textDirection: TextDirection.ltr,
      )..layout();
      return tp.width / radius;
    }

    if (nameLeadingLength != null) {
      // Name is the leading segment, so it sits flush at startAngle with
      // nothing consumed ahead of it.
      double nameWidth = 0;
      for (int i = 0; i < nameLeadingLength; i++) {
        nameWidth += angleFor(chars[i]);
      }
      return targetAngle + nameWidth / 2;
    }

    final int nameStart = chars.lastIndexOf('|') + 1;
    double prefixWidth = 0;
    for (int i = 0; i < nameStart; i++) {
      prefixWidth += angleFor(chars[i]);
    }
    double nameWidth = 0;
    for (int i = nameStart; i < chars.length; i++) {
      nameWidth += angleFor(chars[i]);
    }

    return targetAngle + prefixWidth + nameWidth / 2;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final chars = text.characters.toList();

    // Pass 1: measure every character's angular width without drawing —
    // needed up front so an icon+count "badge" group's background pill can
    // be drawn before the icon/digits themselves are painted on top of it.
    const double iconSize = 16.0;
    final List<double> charAngles = [];
    for (final ch in chars) {
      if (icons[ch] != null) {
        charAngles.add(iconSize / radius);
      } else {
        final tp = TextPainter(
          text: TextSpan(text: ch, style: ch == '|' ? pipeStyle : style),
          textDirection: TextDirection.ltr,
        )..layout();
        charAngles.add(tp.width / radius);
      }
    }

    double currentAngle = startAngle;
    final List<double> centerAngles = [];
    for (int idx = 0; idx < charAngles.length; idx++) {
      final a = charAngles[idx];
      centerAngles.add(currentAngle - a / 2);
      currentAngle -= a;
      if (nameLeadingLength != null && idx == nameLeadingLength! - 1 && nameIconGapPx != 0) {
        currentAngle -= nameIconGapPx / radius;
      }
      if (icons[chars[idx]] != null && iconCountGapPx != 0) {
        currentAngle -= iconCountGapPx / radius;
      }
    }

    // An icon char followed by a run of digits (e.g. "☕1", "🥪12") forms one
    // badge group sharing a single pill-shaped background.
    final List<(int, int)> badgeGroups = [];
    int i = 0;
    while (i < chars.length) {
      if (icons[chars[i]] != null) {
        int j = i + 1;
        while (j < chars.length && _digit.hasMatch(chars[j])) {
          j++;
        }
        badgeGroups.add((i, j));
        i = j;
      } else {
        i++;
      }
    }

    // Pass 2: badge backgrounds first (only if requested), as a thick
    // round-capped arc (a "pill" that follows the circle's own curvature)
    // spanning each group's full angular width, so the icon/digits painted
    // next land on top of it.
    if (badgeColor != null) {
      for (final (start, end) in badgeGroups) {
        final double leadingEdge = centerAngles[start] + charAngles[start] / 2;
        final double trailingEdge = centerAngles[end - 1] - charAngles[end - 1] / 2;
        final badgePaint = Paint()
          ..color = badgeColor!
          ..style = PaintingStyle.stroke
          ..strokeWidth = iconSize + 8.0
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          trailingEdge,
          leadingEdge - trailingEdge,
          false,
          badgePaint,
        );
      }
    }

    // The "name" segment gets its own pill background if requested — after
    // the last '|' by default, or the first [nameLeadingLength] characters
    // when that's set (baseCircle's label has no '|' to scan for at all).
    if (nameBadgeColor != null && chars.isNotEmpty) {
      final int nameFrom = nameLeadingLength != null ? 0 : chars.lastIndexOf('|') + 1;
      final int nameTo = nameLeadingLength ?? chars.length;
      if (nameFrom < nameTo) {
        final double leadingEdge = centerAngles[nameFrom] + charAngles[nameFrom] / 2;
        final double trailingEdge = centerAngles[nameTo - 1] - charAngles[nameTo - 1] / 2;
        const double nameBadgeHeight = 22.0;
        final nameBadgePaint = Paint()
          ..color = nameBadgeColor!
          ..style = PaintingStyle.stroke
          ..strokeWidth = nameBadgeHeight
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          trailingEdge,
          leadingEdge - trailingEdge,
          false,
          nameBadgePaint,
        );
      }
    }

    // Pass 3: icons and glyphs on top of any badge backgrounds.
    for (int k = 0; k < chars.length; k++) {
      final ch = chars[k];
      final angle = centerAngles[k];
      final icon = icons[ch];

      if (icon != null) {
        final x = center.dx + radius * math.cos(angle);
        final y = center.dy + radius * math.sin(angle);
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(angle - math.pi / 2);
        canvas.drawImageRect(
          icon,
          Rect.fromLTWH(0, 0, icon.width.toDouble(), icon.height.toDouble()),
          Rect.fromLTWH(-iconSize / 2, -iconSize / 2, iconSize, iconSize),
          Paint()
            ..filterQuality = ui.FilterQuality.high
            // Both guideCircle and baseCircle want the drink icon tinted to
            // match its trailing count digit's color (no separate chip
            // behind them) rather than the icon's own original artwork
            // color.
            ..colorFilter = numberStyle.color != null
                ? ColorFilter.mode(numberStyle.color!, BlendMode.srcIn)
                : null,
        );
        canvas.restore();
        continue;
      }

      final bool inBadge = badgeGroups.any((g) => k >= g.$1 && k < g.$2);
      final TextStyle finalStyle = ch == '|'
          ? pipeStyle
          : (inBadge && _digit.hasMatch(ch))
              ? numberStyle
              : style;

      final textPainter = TextPainter(
        text: TextSpan(text: ch, style: finalStyle),
        textDirection: TextDirection.ltr,
      )..layout();

      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle - math.pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ArcTextPainter oldDelegate) =>
      oldDelegate.text != text ||
      oldDelegate.icons != icons ||
      oldDelegate.radius != radius ||
      oldDelegate.startAngle != startAngle ||
      oldDelegate.badgeColor != badgeColor ||
      oldDelegate.nameBadgeColor != nameBadgeColor ||
      oldDelegate.nameLeadingLength != nameLeadingLength ||
      oldDelegate.nameIconGapPx != nameIconGapPx ||
      oldDelegate.iconCountGapPx != iconCountGapPx;
}
