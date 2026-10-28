import 'package:flutter/material.dart';

import 'package:pickup_table/domain/entities/pickup_table_theme/pickup_table_theme_color_overrides.dart';
import 'package:pickup_table/domain/entities/pickup_table_theme/pickup_table_theme_colors.dart';
import 'package:pickup_table/domain/entities/pickup_table_theme/pickup_table_theme_selection.dart';

/// Resolves a [PickupTableThemeBackground] (named theme) to its concrete
/// color set. Each named theme below is a complete, independently
/// specified [PickupTableThemeColors] — nothing is shared/derived between
/// themes.
class PickupTableThemeRegistry {
  const PickupTableThemeRegistry._();

  static PickupTableThemeColors resolve(PickupTableThemeBackground background) =>
      _palettes[background]!;

  /// Same as [resolve], but honors [PickupTableThemeSelection.colorOverrides]
  /// (FlowHub's palette editor) when present — the named [selection]'s own
  /// [PickupTableThemeSelection.background] is only used as a fallback/
  /// starting point in that case, not the source of truth for colors.
  static PickupTableThemeColors resolveSelection(PickupTableThemeSelection selection) {
    final overrides = selection.colorOverrides;
    if (overrides == null) return resolve(selection.background);
    return PickupTableThemeColors(
      background: overrides.background,
      guideBackground: overrides.guideFill,
      guideBorder: overrides.guideStroke,
      matchedGradient: _gradientFrom(overrides.matchedFill1, overrides.matchedFill2),
      // LINE style is unreachable from the FlowHub UI — these two never
      // get a palette editor of their own, so just fall back to the
      // named theme's own (equally-unreachable) LINE-style colors.
      highlightBackgroundLine: resolve(selection.background).highlightBackgroundLine,
      highlightBorderLine: resolve(selection.background).highlightBorderLine,
      highlightGradientFill: _gradientFrom(overrides.timeoutFill1, overrides.timeoutFill2),
      receiptScanGradient: _gradientFrom(overrides.receiptFill1, overrides.receiptFill2),
      thankYouColor: overrides.thankYouColor,
      highlightDividerColor: resolve(selection.background).highlightDividerColor,
    );
  }

  static LinearGradient _gradientFrom(Color a, Color b) =>
      a == b ? _solidGradient(a) : _diagonalGradient(a, b);

  static LinearGradient _diagonalGradient(Color start, Color end) => LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [start, start, end, end],
        stops: const [0.0, 0.2487, 0.9109, 1.0],
      );

  // A single-color theme's receiptScanGradient is just this color repeated
  // — keeps the field type uniform (Gradient) across every theme, whether
  // its receipt-scan look is a plain color (Forest Green) or a real
  // 2-color gradient (Charcoal onward).
  static LinearGradient _solidGradient(Color color) => LinearGradient(colors: [color, color]);

  static final Map<PickupTableThemeBackground, PickupTableThemeColors> _palettes = {
    // Forest Green — first of the 11 confirmed color-combo themes replacing
    // the old 5-background system. Guide/matched slots both use the same
    // FDF6E2 (border/text on the guide slot; fill on the matched slot,
    // with the order number/divider knocked out to reveal the background —
    // see PlacedSlotPainter's fill-style knockout, reused as-is here).
    PickupTableThemeBackground.forestGreen: PickupTableThemeColors(
      background: const Color(0xFF2C3D2F),
      guideBackground: const Color(0x1AFDF6E2), // FDF6E2 @ 10%
      guideBorder: const Color(0xFFFDF6E2),
      matchedGradient: _solidGradient(const Color(0xFFFDF6E2)),
      // LINE style is no longer reachable from the FlowHub UI (style is
      // fixed to fill), so these two are only a safe fallback for that
      // dead code path — not part of the confirmed Forest Green spec.
      highlightBackgroundLine: const Color(0x33FF6B6B),
      highlightBorderLine: const Color(0xFFFF6B6B),
      highlightGradientFill: _diagonalGradient(const Color(0xFFFF6B6B), const Color(0xFFFFABAB)),
      receiptScanGradient: _solidGradient(const Color(0xFFF4CF33)),
      thankYouColor: const Color(0xFFFFFFFF),
    ),
    // Charcoal — same as Forest Green except background + receipt-scan
    // (which is a real 2-color gradient here, unlike Forest Green's flat
    // color).
    PickupTableThemeBackground.charcoal: PickupTableThemeColors(
      background: const Color(0xFF202422),
      guideBackground: const Color(0x1AFDF6E2),
      guideBorder: const Color(0xFFFDF6E2),
      matchedGradient: _solidGradient(const Color(0xFFFDF6E2)),
      highlightBackgroundLine: const Color(0x33FF6B6B),
      highlightBorderLine: const Color(0xFFFF6B6B),
      highlightGradientFill: _diagonalGradient(const Color(0xFFFF6B6B), const Color(0xFFFFABAB)),
      receiptScanGradient: _diagonalGradient(const Color(0xFFC4A96E), const Color(0xFFE2D0A8)),
      thankYouColor: const Color(0xFFFFFFFF),
    ),
    PickupTableThemeBackground.deepNavy: PickupTableThemeColors(
      background: const Color(0xFF182649),
      guideBackground: const Color(0x1AFDF6E2),
      guideBorder: const Color(0xFFFDF6E2),
      matchedGradient: _solidGradient(const Color(0xFFB5BCCA)),
      highlightBackgroundLine: const Color(0x33FF6B6B),
      highlightBorderLine: const Color(0xFFFF6B6B),
      highlightGradientFill: _diagonalGradient(const Color(0xFFFF6B6B), const Color(0xFFFFABAB)),
      receiptScanGradient: _solidGradient(const Color(0xFFB99174)),
      thankYouColor: const Color(0xFFFFFFFF),
    ),
    PickupTableThemeBackground.slateBlue: PickupTableThemeColors(
      background: const Color(0xFF2C2310),
      guideBackground: const Color(0x1AA4C3E1),
      guideBorder: const Color(0xFFA4C3E1),
      matchedGradient: _solidGradient(const Color(0xFFA4C3E1)),
      highlightBackgroundLine: const Color(0x33FF6B6B),
      highlightBorderLine: const Color(0xFFFF6B6B),
      highlightGradientFill: _diagonalGradient(const Color(0xFFFF6B6B), const Color(0xFFFFABAB)),
      receiptScanGradient: _diagonalGradient(const Color(0xFFDECBA1), const Color(0xFFE6E2D9)),
      thankYouColor: const Color(0xFFFFFFFF),
    ),
    // "#05" — no proper name given, displayed as-is.
    PickupTableThemeBackground.theme05: PickupTableThemeColors(
      background: const Color(0xFF2C1414),
      guideBackground: const Color(0x1ADECBA1),
      guideBorder: const Color(0xFFDECBA1),
      matchedGradient: _solidGradient(const Color(0xFFDECBA1)),
      highlightBackgroundLine: const Color(0x33FF6B6B),
      highlightBorderLine: const Color(0xFFFF6B6B),
      highlightGradientFill: _diagonalGradient(const Color(0xFFFF6B6B), const Color(0xFFFFABAB)),
      receiptScanGradient: _solidGradient(const Color(0xFFECC060)),
      thankYouColor: const Color(0xFFFFFFFF),
    ),
    // "#06" — no proper name given, displayed as-is. Guide fill (DDCAA0)
    // and guide border/order-number color (DECBA1) are intentionally two
    // slightly different hexes — confirmed per spec, not a typo.
    PickupTableThemeBackground.theme06: PickupTableThemeColors(
      background: const Color(0xFF032843),
      guideBackground: const Color(0x1ADDCAA0),
      guideBorder: const Color(0xFFDECBA1),
      matchedGradient: _solidGradient(const Color(0xFF6EB7DB)),
      highlightBackgroundLine: const Color(0x33FF6B6B),
      highlightBorderLine: const Color(0xFFFF6B6B),
      highlightGradientFill: _diagonalGradient(const Color(0xFFFF6B6B), const Color(0xFFFFABAB)),
      receiptScanGradient: _solidGradient(const Color(0xFFDDCAA0)),
      thankYouColor: const Color(0xFFFFFFFF),
    ),

    // ---- Brand themes (5) ----

    // Guide fill (D4E9E2) vs guide border/order-number (DECBA1) are two
    // different hexes — confirmed per spec, not a typo (same pattern as
    // "#06" above).
    PickupTableThemeBackground.starbucks: PickupTableThemeColors(
      background: const Color(0xFF1E3932),
      guideBackground: const Color(0x1AD4E9E2),
      guideBorder: const Color(0xFFDECBA1),
      matchedGradient: _solidGradient(const Color(0xFFD4E9E2)),
      highlightBackgroundLine: const Color(0x33E75B52),
      highlightBorderLine: const Color(0xFFE75B52),
      highlightGradientFill: _solidGradient(const Color(0xFFE75B52)),
      receiptScanGradient: _solidGradient(const Color(0xFFCBA258)),
      thankYouColor: const Color(0xFFFFFFFF),
    ),
    // Only MAMMOTH/MAGA want the timeout square's divider/order-number
    // drawn in an explicit color (highlightDividerColor) instead of the
    // usual background-cutout knockout every other theme uses.
    PickupTableThemeBackground.mammoth: PickupTableThemeColors(
      background: const Color(0xFF231F20),
      guideBackground: const Color(0x1AF7F1EB),
      guideBorder: const Color(0xFFF7F1EB),
      matchedGradient: _solidGradient(const Color(0xFFF7F1EB)),
      highlightBackgroundLine: const Color(0x33EE4045),
      highlightBorderLine: const Color(0xFFEE4045),
      highlightGradientFill: _solidGradient(const Color(0xFFEE4045)),
      highlightDividerColor: const Color(0xFFF7F1EB),
      receiptScanGradient: _solidGradient(const Color(0xFFBD9075)),
      thankYouColor: const Color(0xFFFFFFFF),
    ),
    PickupTableThemeBackground.maga: PickupTableThemeColors(
      background: const Color(0xFF271411),
      guideBackground: const Color(0x1AF6F6F6),
      guideBorder: const Color(0xFFF6F6F6),
      matchedGradient: _solidGradient(const Color(0xFFB5BCCA)),
      highlightBackgroundLine: const Color(0x33F04B5E),
      highlightBorderLine: const Color(0xFFF04B5E),
      highlightGradientFill: _solidGradient(const Color(0xFFF04B5E)),
      highlightDividerColor: const Color(0xFFFFFFFF),
      receiptScanGradient: _solidGradient(const Color(0xFFF6F6F6)),
      thankYouColor: const Color(0xFFFFFFFF),
    ),
    PickupTableThemeBackground.doutor: PickupTableThemeColors(
      background: const Color(0xFF000000),
      guideBackground: const Color(0x1AFDB813),
      guideBorder: const Color(0xFFFDB813),
      matchedGradient: _solidGradient(const Color(0xFFF1F1F1)),
      highlightBackgroundLine: const Color(0x33FF6641),
      highlightBorderLine: const Color(0xFFFF6641),
      highlightGradientFill: _solidGradient(const Color(0xFFFF6641)),
      receiptScanGradient: _solidGradient(const Color(0xFFF6F6F6)),
      thankYouColor: const Color(0xFFFFFFFF),
    ),
    PickupTableThemeBackground.supreme: PickupTableThemeColors(
      background: const Color(0xFF17110C),
      guideBackground: const Color(0x1AFAFAF2),
      guideBorder: const Color(0xFFFAFAF2),
      matchedGradient: _solidGradient(const Color(0xFFF3E7D4)),
      highlightBackgroundLine: const Color(0x33FF2725),
      highlightBorderLine: const Color(0xFFFF2725),
      highlightGradientFill: _solidGradient(const Color(0xFFFF2725)),
      receiptScanGradient: _solidGradient(const Color(0xFF009BE3)),
      thankYouColor: const Color(0xFFFFFFFF),
    ),
  };
}
