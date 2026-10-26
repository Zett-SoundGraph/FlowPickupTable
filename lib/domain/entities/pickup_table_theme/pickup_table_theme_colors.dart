import 'package:flutter/material.dart';

/// Color set for the Pickup Table Theme feature — needs translucent tints
/// and a real gradient, not just plain [Color]s.
///
/// - [guideBackground]/[guideBorder]: the guide slot has an actual
///   translucent background fill now (previously guide slots were always
///   fully transparent) — same in both line and fill style (confirmed:
///   this design doesn't distinguish line/fill for the guide slot at all).
/// - [matchedGradient]: the matched slot's look — a real gradient now (not
///   just a solid [Color]) so it can be unified with the timeout/receipt-
///   scan squares' fill1/fill2 palette editing in FlowHub; a single-color
///   theme just repeats the same color twice (see `_solidGradient`).
/// - [highlightBackgroundLine]/[highlightBorderLine]: the timeout/
///   highlighted slot's LINE-style look — a translucent full-card
///   background wash (not just the corner triangle) plus a solid border
///   and corner tag.
/// - [highlightGradientFill]: the timeout/highlighted slot's FILL-style
///   look — replaces highlightBackgroundLine/highlightBorderLine entirely;
///   used as BOTH the full-card fill shader AND the border stroke shader
///   (confirmed identical gradient for both in the given spec).
/// - [receiptScanGradient]: the receipt-scan slot's own look — until now
///   this used the exact same look as the timeout slot
///   ([highlightGradientFill]), only visually distinguished by blinking
///   (see BlinkingVisibility at the call site). Now its own gradient (a
///   single-color theme just repeats the same color twice — see
///   PickupTableThemeRegistry's `_solidGradient` helper) so receipt-scan
///   and timeout read as different states even before the blink is
///   visible; timeout keeps its own gradient unchanged.
class PickupTableThemeColors {
  final Color background;
  final Color guideBackground;
  final Color guideBorder;
  final Gradient matchedGradient;
  final Color highlightBackgroundLine;
  final Color highlightBorderLine;
  final Gradient highlightGradientFill;
  final Gradient receiptScanGradient;
  final Color thankYouColor;
  // Null (default, all themes but MAMMOTH/MAGA): the timeout square's
  // diagonal divider + order number are knocked out to reveal the
  // background underneath (PlacedSlotPainter's usual fill-style
  // technique). Non-null: draw the divider/number in this color instead —
  // MAMMOTH/MAGA's timeout square specifically wants an explicit color
  // there, not a background cutout (see PickupTableThemeRegistry).
  final Color? highlightDividerColor;

  const PickupTableThemeColors({
    required this.background,
    required this.guideBackground,
    required this.guideBorder,
    required this.matchedGradient,
    required this.highlightBackgroundLine,
    required this.highlightBorderLine,
    required this.highlightGradientFill,
    required this.receiptScanGradient,
    required this.thankYouColor,
    this.highlightDividerColor,
  });
}
